"""
Selenium test harness for the Support Sphere Flutter web application.

=== Architecture overview ===

Support Sphere is a Flutter app that compiles to web. Selenium drives a real
Chrome browser against the running web build. This file provides pytest
fixtures that handle browser lifecycle, app connectivity, and authentication.

=== Flutter web + Selenium: how the DOM works ===

Flutter web (CanvasKit renderer, the default since 3.22) draws all visible UI
onto a single <canvas> element inside a shadow DOM. The visible pixels are
not queryable DOM nodes. However, Flutter maintains a parallel accessibility
/semantics tree that IS exposed as real DOM elements:

  <flutter-view>
    <flt-glass-pane>  (shadow root: canvas-only rendering)
    <flt-semantics-host>
      <flt-semantics role="button" ...>Login</flt-semantics>
      …
    </flt-semantics-host>

These <flt-semantics> elements are in the regular DOM (not shadow DOM) and
are queryable with standard Selenium locators.

Critically, Flutter only builds this semantics tree AFTER it detects an
assistive technology or receives a specific activation signal. The helper
`_enable_flutter_semantics()` clicks the hidden `flt-semantics-placeholder`
button via the Chrome DevTools Protocol (CDP), which is the trigger Flutter
uses to switch on the semantics tree.

For text inputs, Flutter creates real <input> elements positioned over the
canvas when a text field is active. These appear in the regular DOM with
aria-label attributes matching the Flutter TextField's labelText, and are
the most reliable targets for Selenium typing:

  input[aria-label="Email"]
  input[aria-label="Password"]

=== App navigation flow ===

Unauthenticated app load:
  / → OnboardingFlow → LandingView   (logo + "Login" / "Sign Up" buttons)
                     → LoginPage     (email + password form)
                     → SignupPage

Authenticated app load:
  / → AuthSelect → main app shell (BottomNavigationBar with Home / Resources /
                                   Checklist / Messages / Profile tabs)

=== Running tests locally ===

1. Build the Flutter web app (production build avoids DDC/DWDS complexity):
     cd src/support_sphere
     flutter build web --dart-define-from-file=../../.env

2. Serve it:
     python3 -m http.server 42000 --directory build/web

3. Run the tests:
     pixi run -e selenium pytest tests/selenium/ -v

   Headed (watch the browser):
     SELENIUM_HEADLESS=false pixi run -e selenium pytest tests/selenium/ -v

   Against a deployed build:
     APP_URL=https://staging.example.com pixi run -e selenium pytest tests/selenium/ -v

   One-shot build + serve + test:
     pixi run -e selenium selenium-test-ci

=== Environment variables ===

  APP_URL             Base URL of the running app  (default: http://localhost:42000)
  SELENIUM_HEADLESS   "true"/"false" — run Chrome headless  (default: true)
  SELENIUM_TIMEOUT    Implicit wait / WebDriverWait timeout in seconds  (default: 15)
  TEST_USER_EMAIL     Email for a seeded test account (required by authenticated_driver)
  TEST_USER_PASSWORD  Password for the test account  (required by authenticated_driver)

=== Fixture hierarchy ===

  app_url (session)       — base URL string, resolved once per run
  driver (function)       — fresh Chrome WebDriver per test, quit after
  wait (function)         — WebDriverWait bound to the current driver
  authenticated_driver    — driver after completing the full login flow;
                            skips if TEST_USER_EMAIL / TEST_USER_PASSWORD absent

=== Locator reference (confirmed via DOM inspection) ===

  Landing page "Login" button:   flt-semantics[role="button"] (text="Login")
  Email input (login form):      input[aria-label="Email"]
  Password input (login form):   input[aria-label="Password"]
  Login submit button:           flt-semantics[role="button"] (text="Login",
                                   on the form page — disambiguate by waiting
                                   for the input fields first)
  "Sign Up" link:                flt-semantics[role="button"] containing "Sign Up"

See test_auth.py for a working implementation of the full flow.
"""

import os
import time
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


APP_URL = os.environ.get("APP_URL", "http://localhost:42000")
HEADLESS = os.environ.get("SELENIUM_HEADLESS", "true").lower() == "true"
TIMEOUT = int(os.environ.get("SELENIUM_TIMEOUT", "15"))

# Ubuntu snap packages Chromium together with a version-matched chromedriver.
# Using the snap chromedriver avoids the version mismatch that occurs when the
# system chromedriver lags behind the snap-managed Chromium release.
_SNAP_CHROMEDRIVER = "/snap/bin/chromium.chromedriver"
_SNAP_CHROME = "/snap/bin/chromium"


def _chrome_options() -> Options:
    opts = Options()
    if HEADLESS:
        opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")  # avoids /dev/shm exhaustion in CI containers
    opts.add_argument("--window-size=1280,900")
    # SwiftShader: software WebGL required for Flutter's CanvasKit renderer in
    # headless Chrome. Chrome 116+ deprecated the automatic software fallback;
    # --enable-unsafe-swiftshader re-enables it explicitly.
    opts.add_argument("--enable-unsafe-swiftshader")
    # Expose the full Chrome accessibility tree so Flutter's semantics
    # placeholder is visible to CDP queries (needed by _enable_flutter_semantics).
    opts.add_argument("--force-renderer-accessibility")
    # Do NOT set binary_location when using the snap chromedriver. The snap
    # chromedriver wrapper resolves its own paired Chromium binary internally;
    # pointing it at /snap/bin/chromium directly causes Chrome to exit
    # immediately (session not created error).
    return opts


def _chrome_service() -> Service:
    # On Ubuntu systems with snap Chromium, use the bundled snap chromedriver
    # so the driver and browser versions are always in sync. On CI runners
    # (GitHub Actions ubuntu-latest) or other systems, fall back to whatever
    # chromedriver is on PATH (installed via apt or webdriver-manager).
    if os.path.exists(_SNAP_CHROMEDRIVER):
        return Service(executable_path=_SNAP_CHROMEDRIVER)
    return Service()


def _enable_flutter_semantics(driver: webdriver.Chrome) -> None:
    """Activate Flutter's accessibility/semantics DOM overlay.

    Flutter does not build the <flt-semantics> tree by default — it only does
    so when it detects an assistive technology is present. The detection
    mechanism is a hidden <flt-semantics-placeholder role="button"> element
    that assistive tech (or this function) clicks to signal "I am a screen
    reader, please enable semantics."

    We trigger it via the Chrome DevTools Protocol (CDP) because the element
    is not directly reachable by Selenium's regular find_element (it's inside
    the <flt-glass-pane> shadow root, which we can't pierce with CSS selectors
    in the same way). CDP lets us resolve the element's backend node ID from
    the accessibility tree and dispatch a click event on it.

    After calling this function, wait briefly (~3 s) before querying for
    <flt-semantics> elements — Flutter rebuilds the tree asynchronously.

    Raises RuntimeError if the placeholder is not found within the AX tree,
    which typically means Flutter has not finished initializing yet.
    """
    driver.execute_cdp_cmd("Accessibility.enable", {})
    ax = driver.execute_cdp_cmd("Accessibility.getFullAXTree", {})
    placeholder = next(
        (n for n in ax.get("nodes", [])
         if n.get("name", {}).get("value") == "Enable accessibility"),
        None,
    )
    if placeholder is None:
        raise RuntimeError(
            "flt-semantics-placeholder not found in AX tree. "
            "Flutter may not have finished initializing."
        )
    obj = driver.execute_cdp_cmd(
        "DOM.resolveNode", {"backendNodeId": placeholder["backendDOMNodeId"]}
    )
    driver.execute_cdp_cmd("Runtime.callFunctionOn", {
        "objectId": obj["object"]["objectId"],
        "functionDeclaration": """function() {
            this.dispatchEvent(new FocusEvent('focus', {bubbles: true, composed: true}));
            this.dispatchEvent(new MouseEvent('click', {bubbles: true, composed: true}));
        }""",
        "returnByValue": True,
    })
    time.sleep(3)  # Flutter rebuilds the semantics tree asynchronously


@pytest.fixture(scope="session")
def app_url() -> str:
    """Base URL of the running Support Sphere web app.

    Override via the APP_URL environment variable to point at a deployed
    environment instead of localhost.
    """
    return APP_URL


@pytest.fixture
def driver():
    """Yields a fresh Chrome WebDriver instance for a single test.

    The driver is created with function scope so each test starts from a clean
    browser state — no cookies, local storage, or navigation history carried
    over from a previous test. This is intentional: Selenium tests that share
    browser state become order-dependent and hard to debug.

    Chrome flags used:
      --enable-unsafe-swiftshader  allows software WebGL for CanvasKit in headless
      --force-renderer-accessibility  makes the CDP AX tree visible for semantics
    """
    d = webdriver.Chrome(service=_chrome_service(), options=_chrome_options())
    d.implicitly_wait(TIMEOUT)
    yield d
    d.quit()


@pytest.fixture
def wait(driver):
    """WebDriverWait bound to the current test's driver.

    Use this for explicit waits on conditions that require polling:

      from selenium.webdriver.support import expected_conditions as EC
      from selenium.webdriver.common.by import By

      element = wait.until(
          EC.element_to_be_clickable((By.CSS_SELECTOR, 'flt-semantics[role="button"]'))
      )

    Prefer explicit waits over time.sleep() — they fail fast when something
    goes wrong and pass as soon as the condition is met, keeping the suite fast.
    """
    return WebDriverWait(driver, TIMEOUT)


@pytest.fixture
def authenticated_driver(driver, app_url, wait):
    """Yields a driver that has completed the full login flow.

    Sequence:
      1. Load app_url (shows LandingView)
      2. Activate Flutter semantics via CDP
      3. Click the landing-page "Login" button → navigates to LoginPage
      4. Fill email + password inputs
      5. Click the login submit button
      6. Wait for the main app shell (BottomNavigationBar) to confirm auth

    Requires TEST_USER_EMAIL and TEST_USER_PASSWORD environment variables
    pointing to a seeded test account in the Supabase database. Skips the
    calling test automatically when these are absent.

    To add a test account:
      - Use the Supabase dashboard or `flutter run` signup flow
      - Or insert a row via the db-init seed scripts
      - Disable email confirmation in the local Supabase config so the
        account is immediately usable without an email round-trip
    """
    email = os.environ.get("TEST_USER_EMAIL")
    password = os.environ.get("TEST_USER_PASSWORD")
    if not email or not password:
        pytest.skip("TEST_USER_EMAIL / TEST_USER_PASSWORD not set")

    driver.get(app_url)
    # Wait for Flutter/CanvasKit to mount (~3–8 s for a production build)
    wait.until(EC.presence_of_element_located((By.TAG_NAME, "flutter-view")))
    _enable_flutter_semantics(driver)

    # Click landing-page Login button → navigates to the login form
    landing_login = wait.until(EC.element_to_be_clickable(
        (By.CSS_SELECTOR, 'flt-semantics[role="button"]')
    ))
    landing_login.click()

    # Wait for the real <input> fields to appear (Flutter creates them for text editing)
    email_input = wait.until(EC.presence_of_element_located(
        (By.CSS_SELECTOR, 'input[aria-label="Email"]')
    ))
    email_input.send_keys(email)

    password_input = driver.find_element(By.CSS_SELECTOR, 'input[aria-label="Password"]')
    password_input.send_keys(password)

    # Submit — find the Login button on the form page (distinct from landing button
    # because the email/password inputs are now present)
    submit = wait.until(EC.element_to_be_clickable(
        (By.XPATH, '//flt-semantics[@role="button" and normalize-space()="Login"]')
    ))
    submit.click()

    # TODO: replace with a reliable post-login landmark once the home page
    # semantic tree has been inspected (e.g. the nav bar tab for "Home")
    wait.until(EC.presence_of_element_located(
        (By.CSS_SELECTOR, 'flt-semantics[role="tab"]')
    ))
    yield driver
