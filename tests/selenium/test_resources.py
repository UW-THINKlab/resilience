"""
Selenium tests for the resource management pages.

=== Domain context ===

Resources in Support Sphere represent physical items or services that
community members can offer or request during a disaster response event.
The domain models live in:
  src/support_sphere_py/src/support_sphere/models/public/resource.py

Key concepts:
  Resource         — a type of resource (e.g. "Generator", "First Aid Kit")
  ResourceRequest  — a user's request to borrow or receive a resource
  PointOfInterest  — a mapped location where a resource is available

The Flutter UI has separate views for browsing resources (available to all
authenticated users) and managing requests (role-dependent: regular users
submit requests; admin/cluster-captain users fulfill them).

=== Page locations ===

  lib/presentation/pages/main_app/resource/    — browsing and request forms
  lib/presentation/pages/main_app/manage_resources/  — admin management view

=== Admin role requirement ===

TestAdminResourceManagement tests require a user with admin or cluster-captain
privileges. Until the `authenticated_driver` fixture is extended to support
role-based logins, create a separate `admin_driver` fixture in conftest.py
that logs in with TEST_ADMIN_EMAIL / TEST_ADMIN_PASSWORD.
"""

import pytest


class TestResourceBrowsing:
    @pytest.mark.skip(reason="Add locators: resources nav tab, resource list container")
    def test_resources_tab_navigates(self, authenticated_driver):
        """Tapping the Resources tab should show the resource list view.

        After login the user is on the home tab. This test clicks the Resources
        nav item and asserts that the resource list container appears, confirming
        that navigation and the resource list widget both render correctly.
        """
        # TODO: click the Resources tab in the bottom nav bar
        # TODO: wait for the resource list container to appear

    @pytest.mark.skip(reason="Add locator: individual resource list item")
    def test_resource_list_not_empty(self, authenticated_driver):
        """The resource list should show at least one item when seed data exists.

        Requires the database to be initialised with seed resources (via the
        db-init pixi task). If the list is legitimately empty in the test
        environment, this test should be marked xfail or skipped conditionally
        rather than removed — an empty list may indicate a data-loading bug.
        """
        # TODO: navigate to Resources tab
        # TODO: find all resource list item elements
        # TODO: assert len(items) > 0

    @pytest.mark.skip(reason="Add locators: first resource item, detail view heading")
    def test_resource_detail_opens(self, authenticated_driver):
        """Tapping a resource item should open its detail view.

        The detail view should display the resource name, description, and
        availability. It should also expose a way to request the resource
        (button or link) that the TestResourceRequests tests cover.
        """
        # TODO: navigate to Resources tab, click the first list item
        # TODO: wait for a detail view heading or unique detail element
        # TODO: assert the heading text is non-empty


class TestResourceRequests:
    @pytest.mark.skip(reason="Add locators: request button, form fields")
    def test_request_resource_form_opens(self, authenticated_driver):
        """Tapping the request button should open the resource request form.

        The form collects: which resource, quantity, and any notes. Verify
        that the form fields are present and interactable before attempting
        to submit (test_submit_resource_request covers the full flow).
        """
        # TODO: navigate to Resources tab, open a resource detail
        # TODO: find and click the "Request" button
        # TODO: wait for form fields (resource selector, quantity, notes) to appear

    @pytest.mark.skip(reason="Add locators: form fields, submit button, confirmation indicator")
    def test_submit_resource_request(self, authenticated_driver):
        """A completed resource request form should create a ResourceRequest row.

        After submission the UI should show a confirmation (toast, banner, or
        redirect). To verify persistence without querying the DB directly, check
        that the user's request appears in their request history if the app
        exposes one, or assert the confirmation element is visible.

        Clean up: consider deleting the created ResourceRequest row in teardown
        via the Supabase REST API using a service-role key so the test is
        repeatable without accumulating junk data.
        """
        # TODO: navigate to Resources, open detail, click Request
        # TODO: fill form fields with valid data
        # TODO: click submit button
        # TODO: wait for confirmation element or redirect


class TestAdminResourceManagement:
    @pytest.mark.skip(reason="Requires admin-role authenticated_driver; add locators for request list")
    def test_admin_can_view_all_requests(self, authenticated_driver):
        """Admin users should see the full list of pending resource requests.

        This test requires an admin-role driver. Until the admin login fixture
        exists, this test will skip via the authenticated_driver credential
        check. When implementing, replace `authenticated_driver` with an
        `admin_driver` fixture and navigate to the manage_resources page.
        """
        # TODO: switch to admin_driver fixture once it exists in conftest.py
        # TODO: navigate to the manage_resources admin view
        # TODO: assert at least one pending request is listed (needs seed data)

    @pytest.mark.skip(reason="Add locators: request item, fulfill action, status update")
    def test_admin_can_fulfill_request(self, authenticated_driver):
        """An admin should be able to mark a resource request as fulfilled.

        Flow: navigate to manage_resources → find a pending request → click
        the fulfill/approve action → assert the request's status updates in
        the UI (e.g. moves to a "fulfilled" section or its status label changes).

        Seed a specific ResourceRequest row in a fixture so the test has a
        known target and can clean up afterwards.
        """
        # TODO: switch to admin_driver fixture
        # TODO: navigate to admin resource management page
        # TODO: find the seeded pending request, click fulfill
        # TODO: assert the status element reflects the fulfilled state
