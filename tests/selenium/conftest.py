"""
Selenium test harness for the Support Sphere Flutter web application.

=== Architecture overview ===

Support Sphere is a Flutter app that compiles to web. Selenium drives a real
Chrome browser against the running web build. This file provides pytest
fixtures that handle browser lifecycle, app connectivity, and authentication.

=== Flutter web + Selenium: renderer choice ===

Flutter web has two rendering modes, and the choice determines what Selenium
can see in the DOM:

  CanvasKit (default): Flutter draws to a <canvas> element. The visible UI
  exists only as pixels — no semantic HTML. Selenium cannot click buttons,
  read text, or find form fields, because none of those DOM nodes exist.

  HTML renderer: Flutter emits real DOM nodes. CSS, text, and some interactive
  elements are queryable. This is required for Selenium testing.

  WASM renderer (Flutter 3.22+): Similar to CanvasKit — avoid for Selenium.

To run the app in HTML renderer mode:
  flutter run -d web-server --web-port 42000 --web-renderer html \\
    --dart-define-from-file=../../.env

For a built artifact:
  flutter build web --web-renderer html --dart-define-from-file=../../.env

Even with the HTML renderer, Flutter wraps the semantic tree in custom
elements (flt-semantics, flt-text, etc.) inside a shadow DOM. Useful
locator strategies:

  - Flutter renders accessible labels as aria-label attributes:
      driver.find_element(By.CSS_SELECTOR, '[aria-label="Email"]')

  - Text content lives in <flt-semantics> or spans inside shadow roots.
    Use JavaScript to pierce shadow roots when needed:
      driver.execute_script("return document.querySelector('flt-glass-pane')"
                            ".shadowRoot.querySelector('[aria-label=\"Login\"]')")

  - Material buttons often expose a role="button" attribute.

  - Prefer aria-label over class names — Flutter classes are mangled at build
    time and change across releases.

  - Flutter's semantic tree is only enabled when the OS accessibility APIs
    request it, OR when you call:
      WidgetsFlutterBinding.ensureInitialized();
      SemanticsBinding.instance.ensureSemantics();
    Consider adding a --dart-define flag (e.g. ENABLE_SEMANTICS=true) that
    your main.dart checks to force-enable semantics in test builds.

=== Running tests locally ===

1. Start the app with the HTML renderer:
     cd src/support_sphere
     flutter run -d web-server --web-port 42000 --web-renderer html \\
       --dart-define-from-file=../../.env

2. In a second terminal, run the tests:
     pixi run -e selenium pytest tests/selenium/ -v

   Or with a headed browser so you can watch what happens:
     SELENIUM_HEADLESS=false pixi run -e selenium pytest tests/selenium/ -v

   Or against a different URL (e.g. a deployed staging build):
     APP_URL=https://staging.example.com pixi run -e selenium pytest tests/selenium/ -v

=== Environment variables ===

  APP_URL             Base URL of the running app  (default: http://localhost:42000)
  SELENIUM_HEADLESS   "true"/"false" — run Chrome headless  (default: true)
  SELENIUM_TIMEOUT    Implicit wait / WebDriverWait timeout in seconds  (default: 15)
  TEST_USER_EMAIL     Email for a seeded test account (required by authenticated_driver)
  TEST_USER_PASSWORD  Password for the test account  (required by authenticated_driver)

=== Fixture hierarchy ===

  app_url (session)
      The base URL string. Session-scoped so it is resolved once per run.

  driver (function)
      A fresh Chrome WebDriver. Created before each test, quit after. Using
      function scope intentionally: tests must not share browser state.

  wait (function)
      A WebDriverWait bound to the current driver. Use for explicit waits:
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "...")))

  authenticated_driver (function)
      A driver that has completed the login flow before yielding. Skips the
      test automatically if TEST_USER_EMAIL / TEST_USER_PASSWORD are not set,
      so the suite still runs partially in environments without a test account.

=== Adding new fixtures ===

For admin-specific tests, add an admin_driver fixture that logs in with a
second set of env vars (TEST_ADMIN_EMAIL / TEST_ADMIN_PASSWORD) and has an
admin role in the Supabase user table. Mirror the pattern of authenticated_driver.
"""

import os
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait


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
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=1280,900")
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

    The implicit wait (d.implicitly_wait) tells Selenium to poll for up to
    TIMEOUT seconds when looking for an element before raising NoSuchElement.
    Prefer explicit waits (the `wait` fixture) for conditions that need a
    specific expected state rather than mere presence.
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
          EC.element_to_be_clickable((By.CSS_SELECTOR, '[aria-label="Login"]'))
      )

    Prefer explicit waits over time.sleep() — they fail fast when something
    goes wrong and pass as soon as the condition is met, keeping the suite fast.
    """
    return WebDriverWait(driver, TIMEOUT)


@pytest.fixture
def authenticated_driver(driver, app_url):
    """Yields a driver that has completed the login flow before the test runs.

    Requires TEST_USER_EMAIL and TEST_USER_PASSWORD to be set in the
    environment. These should correspond to a seeded test account in the
    Supabase database (create one via the db-init scripts or a migration
    fixture). The account needs to exist across test runs — do not rely on
    Supabase's email-confirmation flow unless you mock it.

    Skips the calling test automatically if credentials are absent. This lets
    the unauthenticated tests (e.g. login page loads) still run in environments
    that do not have a test account configured.

    Implementation note: once login locators are known, replace the
    pytest.skip() below with the actual Selenium login steps:

      driver.get(app_url)
      driver.find_element(By.CSS_SELECTOR, '[aria-label="Email"]').send_keys(email)
      driver.find_element(By.CSS_SELECTOR, '[aria-label="Password"]').send_keys(password)
      driver.find_element(By.CSS_SELECTOR, '[aria-label="Login"]').click()
      wait.until(EC.url_contains("/home"))  # or whatever the post-login route is
      yield driver
    """
    email = os.environ.get("TEST_USER_EMAIL")
    password = os.environ.get("TEST_USER_PASSWORD")
    if not email or not password:
        pytest.skip("TEST_USER_EMAIL / TEST_USER_PASSWORD not set")
    driver.get(app_url)
    # TODO: replace this skip with the actual login interaction once the
    # Flutter app's DOM locators have been confirmed via browser inspection.
    pytest.skip("authenticated_driver login steps not yet implemented")
    yield driver
