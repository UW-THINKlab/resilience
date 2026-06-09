"""
Selenium tests for the main home/dashboard page (app_page.dart).

=== Page context ===

After a successful login the Flutter router lands the user on the main app
shell (lib/presentation/pages/main_app/app_page.dart). This shell contains:
  - A bottom navigation bar with tabs: Home, Resources, Checklist, Messages,
    and Profile (exact labels may vary — check app_page.dart).
  - A body that swaps content based on the selected tab.
  - An optional operational-event banner when an active OperationalEvent
    exists in the database (see the OperationalEvent domain model).

These tests use the `authenticated_driver` fixture which handles login before
the test body runs. See conftest.py for the implementation plan.

=== Navigation bar locator strategy ===

Flutter's BottomNavigationBar emits <flt-semantics> nodes with role="tab" or
aria-label matching the tab label text. Once the app is running in HTML
renderer mode, inspect the shadow DOM under <flt-glass-pane> to confirm.

Example (once confirmed):
  tabs = driver.find_elements(By.CSS_SELECTOR, '[role="tab"]')
  labels = [t.get_attribute("aria-label") for t in tabs]
  assert "Home" in labels
  assert "Resources" in labels
"""

import pytest


class TestHomePage:
    @pytest.mark.skip(reason="Add locator: home page root / navigation element")
    def test_home_page_loads_after_login(self, authenticated_driver, app_url):
        """An authenticated user should land on the home dashboard after login.

        The authenticated_driver fixture navigates to app_url and completes
        login before yielding, so this test only needs to assert that a
        home-page landmark is present — it should not repeat the login flow.

        Look for a heading, greeting, or structural element unique to the home
        tab content to confirm the correct page loaded.
        """
        # TODO: assert a home-page-specific element is present, e.g.:
        #   assert authenticated_driver.find_element(
        #       By.CSS_SELECTOR, '[aria-label="Home"]'
        #   ).is_displayed()

    @pytest.mark.skip(reason="Add locators: nav bar items (Home, Resources, Checklist, Profile, Messages)")
    def test_navigation_bar_visible(self, authenticated_driver):
        """The bottom navigation bar should be visible with all expected tabs.

        Validates that the app shell renders correctly after login. Checks for
        all primary navigation destinations so that a routing regression
        (missing tab) is caught early.

        Expected tabs (verify against app_page.dart): Home, Resources,
        Checklist, Messages, Profile.
        """
        # TODO: find all tab elements, e.g. driver.find_elements(By.CSS_SELECTOR, '[role="tab"]')
        # TODO: collect their aria-label values
        # TODO: assert the expected set is a subset of the found labels

    @pytest.mark.skip(reason="Add locator: operational event banner element")
    def test_operational_event_banner(self, authenticated_driver):
        """When an active OperationalEvent exists it should surface in the UI.

        The home page shows contextual information about the current disaster
        response event. This test requires the test database to have at least
        one active OperationalEvent row — seed this via the db-init scripts or
        a pytest fixture that inserts and rolls back the row using Supabase's
        REST API with a service-role key.

        If no active event exists, the banner may simply not appear; decide
        whether to assert absence or to skip when the DB lacks seed data.
        """
        # TODO: assert presence of the operational event banner/card element
        # TODO: optionally verify the event name text matches what was seeded
