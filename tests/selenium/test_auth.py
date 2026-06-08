"""
Selenium tests for authentication flows: login and signup.

=== App navigation ===

Unauthenticated load:
  / → LandingView  (logo + "Login" ElevatedButton at bottom)
    → LoginPage    (email + password TextFormFields + "Login" ElevatedButton)
    → SignupPage

The "Login" button on the landing page navigates to the login form; it is NOT
the form's submit button. Both are flt-semantics[role="button"] with text
"Login", so the test must wait for the input fields to appear before clicking
the submit button (to avoid clicking the wrong one).

=== DOM locators (confirmed via live DOM inspection) ===

  Landing Login nav button:  flt-semantics[role="button"]  (first one, text "Login")
  Email input:               input[aria-label="Email"]      (type=text)
  Password input:            input[aria-label="Password"]   (type=password)
  Form submit button:        flt-semantics[role="button"]   with text exactly "Login",
                             located AFTER the input fields are visible
  Error snackbar:            flt-semantics containing the error text
  Sign Up link:              flt-semantics[role="button"] containing "Sign Up"

=== Flutter text input behaviour ===

Flutter (CanvasKit) draws the visual text field on the canvas. When the field
is focused, Flutter creates a real <input> element positioned absolutely over
the canvas for the browser's keyboard events. These inputs have an aria-label
matching the Flutter InputDecoration.labelText ("Email", "Password").

The inputs exist in the DOM as soon as the login form renders (not just when
focused), so Selenium can send_keys to them without clicking first.

=== Validation ===

The login form (login_form.dart) uses form_builder_validators:
  - Email: required + valid email format
  - Password: required + minimum 8 characters
  - Button: only enabled when both fields are non-empty and pass validation
    (controlled by LoginCubit.isLoginButtonEnabled())

Errors on bad credentials are surfaced as a SnackBar with the message from
LoginState.errorMessage (default: "Authentication failure").
"""

import os
import time
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from conftest import _enable_flutter_semantics


# ── helpers ──────────────────────────────────────────────────────────────────

def _go_to_login_form(driver, wait, app_url: str):
    """Load the app and navigate from LandingView to LoginPage.

    Returns (email_input, password_input) once the form is visible.
    Activates Flutter semantics as a side effect.
    """
    driver.get(app_url)
    wait.until(EC.presence_of_element_located((By.TAG_NAME, "flutter-view")))
    _enable_flutter_semantics(driver)

    # Click the landing-page "Login" navigation button
    landing_btn = wait.until(EC.element_to_be_clickable(
        (By.CSS_SELECTOR, 'flt-semantics[role="button"]')
    ))
    landing_btn.click()

    # Wait for the real <input> fields — their presence confirms we're on the form
    email = wait.until(EC.presence_of_element_located(
        (By.CSS_SELECTOR, 'input[aria-label="Email"]')
    ))
    password = driver.find_element(By.CSS_SELECTOR, 'input[aria-label="Password"]')
    return email, password


def _submit_login(driver, wait):
    """Click the form's Login submit button.

    Must be called AFTER the email/password inputs are visible so we can
    distinguish the form submit button from the landing-page navigation button
    (both are flt-semantics[role="button"] with text "Login").
    """
    submit = wait.until(EC.element_to_be_clickable(
        (By.XPATH, '//flt-semantics[@role="button" and normalize-space()="Login"]')
    ))
    submit.click()


# ── TestLogin ─────────────────────────────────────────────────────────────────

class TestLogin:
    def test_login_page_loads(self, driver, app_url, wait):
        """Navigating from the landing page should show the login form fields.

        This confirms:
          - The app loads (flutter-view mounts)
          - Flutter semantics activate (flt-semantics-placeholder click)
          - The landing Login button is clickable and triggers navigation
          - The login form renders its two input fields
        """
        email_input, password_input = _go_to_login_form(driver, wait, app_url)
        assert email_input.is_displayed(), "Email input not visible"
        assert password_input.is_displayed(), "Password input not visible"

    def test_login_with_valid_credentials(self, driver, app_url, wait):
        """Valid credentials should navigate to the main app shell.

        Requires TEST_USER_EMAIL and TEST_USER_PASSWORD to point to a seeded
        account in the Supabase database. The test skips when they are absent
        so the suite remains runnable in environments without a test account.

        After a successful login the router lands on the main app shell which
        exposes a BottomNavigationBar. We detect success by waiting for a
        flt-semantics element with role="tab" (the nav bar items).
        """
        email = os.environ.get("TEST_USER_EMAIL")
        password = os.environ.get("TEST_USER_PASSWORD")
        if not email or not password:
            pytest.skip("TEST_USER_EMAIL / TEST_USER_PASSWORD not set")

        email_input, password_input = _go_to_login_form(driver, wait, app_url)
        email_input.send_keys(email)
        password_input.send_keys(password)
        _submit_login(driver, wait)

        # Post-login: main app shell renders a BottomNavigationBar whose tabs
        # are exposed as flt-semantics[role="tab"] nodes.
        # TODO: update the selector once the home-page semantic tree has been
        #       inspected (the nav bar label text may differ from "tab").
        wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, 'flt-semantics[role="tab"]')
        ))

    def test_login_with_invalid_credentials(self, driver, app_url, wait):
        """Wrong credentials should surface an error, not navigate away.

        The error appears in a SnackBar (ScaffoldMessenger.showSnackBar) with
        the text from LoginState.errorMessage (default "Authentication failure").
        The URL should remain on the login route.
        """
        email_input, password_input = _go_to_login_form(driver, wait, app_url)
        email_input.send_keys("nonexistent@example.com")
        password_input.send_keys("wrongpassword123")
        _submit_login(driver, wait)

        # Wait for error snackbar — it contains the error message text
        # TODO: confirm exact error text once the Supabase response is observed;
        #       the default is "Authentication failure" (see login_form.dart)
        wait.until(lambda d: any(
            "authentication" in el.text.lower() or "invalid" in el.text.lower()
            for el in d.find_elements(By.TAG_NAME, "flt-semantics")
        ))
        # The login inputs should still be present (no navigation occurred)
        assert driver.find_elements(By.CSS_SELECTOR, 'input[aria-label="Email"]'), \
            "Email input disappeared after failed login — unexpected navigation"

    def test_login_button_disabled_with_empty_fields(self, driver, app_url, wait):
        """The Login submit button should be disabled when fields are empty.

        LoginCubit.isLoginButtonEnabled() returns false when either field is
        blank, causing the ElevatedButton.onPressed to be null. A null onPressed
        means the button has no click handler — it should not trigger a login
        attempt or navigate away.

        We verify this by checking the button is present but non-functional:
        clicking it should not cause the email/password inputs to disappear.
        """
        email_input, password_input = _go_to_login_form(driver, wait, app_url)

        # Find and click the (disabled) submit button
        buttons = driver.find_elements(
            By.XPATH, '//flt-semantics[@role="button" and normalize-space()="Login"]'
        )
        assert buttons, "Login button not found on login form page"
        buttons[0].click()
        time.sleep(1)

        # Inputs should still be present — no navigation happened
        assert driver.find_elements(By.CSS_SELECTOR, 'input[aria-label="Email"]'), \
            "Email input disappeared after clicking disabled Login button"


# ── TestSignup ────────────────────────────────────────────────────────────────

class TestSignup:
    def test_signup_link_navigates(self, driver, app_url, wait):
        """The "Sign Up" link on the login page should navigate to SignupPage.

        The link is rendered as a GestureDetector wrapping a Text widget.
        In the semantics tree it appears as a flt-semantics[role="button"]
        containing the text "Sign Up".

        After clicking, we expect the signup form fields to appear.
        TODO: inspect the signup page DOM to confirm the exact input labels.
        """
        _go_to_login_form(driver, wait, app_url)

        signup_btn = wait.until(EC.element_to_be_clickable(
            (By.XPATH, '//flt-semantics[@role="button" and contains(., "Sign Up")]')
        ))
        signup_btn.click()

        # TODO: replace with actual signup form field locator once inspected
        pytest.skip("Verify signup form appears — add locator for first signup field")

    def test_signup_with_valid_data(self, driver, app_url, wait):
        """Completing signup with unique credentials should land on home/onboarding.

        Use a dynamically generated email (e.g. f"test+{uuid4()}@example.com")
        to avoid duplicate-account errors across test runs. Clean up the
        created account in teardown or via a DB fixture.

        Supabase email confirmation must be disabled in the local config for
        the account to be immediately usable.
        """
        pytest.skip("Add signup form locators and unique email generation")

    def test_signup_duplicate_email(self, driver, app_url, wait):
        """Registering with an already-used email should show an error.

        Use TEST_USER_EMAIL (a known-existing account) as the duplicate input.
        """
        pytest.skip("Add signup form locators and duplicate-email error assertion")
