import 'package:intl/intl.dart';
import 'package:support_sphere/constants/appconfig.dart' show AppConfig;

/// Strings used in the app
class AppStrings {
  static final String appName = 'Resilience - ${AppConfig.neighborhood}';
  static final String signUpWelcome =
      'Welcome to ${AppStrings.appName}\nCreate a new account and prepare with your community';
  static const String testEmergencyBannerText =
      "This is a test of emergency mode.";
  static const String emergencyBannerText = "Emergency mode declared.";
}

class EmergencyAlertDialogStrings {
  static const String title = 'Emergency Declared';
  static const String message =
      'An emergency has been declared.\nWould you like to return to normal mode?';
  static const String buttonYes = 'Yes';
  static const String buttonNo = 'No';
}

class NormalAlertDialogStrings {
  static const String title = 'Declare An Emergency';
  static const String message =
      'You are about to declare an emergency.\nWould you like to declare an actual emergency or a test?';
  static const String buttonEmergency = 'Emergency';
  static const String buttonTest = 'Test';
  static const String buttonCancel = 'Cancel';
}

/// Login related strings
class LoginStrings {
  static const String login = 'Login';
  static const String loginIntoExisting = 'Login into an existing account';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String username = 'Username';
  static const String signUpCode = 'Sign Up Code';
  static const String forgotPassword = 'Forgot password?';
  static const String dontHaveAnAccount = 'Don\'t have an account?';
  static const String alreadyHaveAnAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String givenName = 'First Name';
  static const String familyName = 'Last Name';
}

/// User Profile related strings
class UserProfileStrings {
  static const String userProfile = 'User Profile';
  static const String personalInformation = 'Personal Information';
  static const String householdInformation = 'Household Information';
  static const String clusterInformation = 'Cluster Information';
  static const String fullName = 'Name';
  static const String phone = 'Phone';
  static const String email = 'Email';
  static const String givenName = 'Given Name';
  static const String familyName = 'Family Name';
  static const String householdMembers = 'Household Members';
  static const String address = 'Address';
  static const String pets = 'Pets';
  static const String accessibilityNeeds = 'Accessibility Needs';
  static const String accessibilityNeedsDefaultText = 'Not Applicable';
  static const String notes = 'Notes';
  static const String notesWithNote = 'Notes (visible to cluster captain(s))';
  static const String clusterName = 'Name';
  static const String meetingPlace = 'Meeting place';
  static const String captains = 'Captain(s)';
  static const String submit = 'Submit';
  static const String deleteMyAccount = 'Delete My Account';
  static const String manageBlockedUsers = 'Manage Block List';
  static const String confirmPrompt = 'Please Confirm';
  static const String confirmAccountDelete =
      'Are you sure you want to delete your account?';
  static const String destructiveActions = 'Destructive Actions';
  static const String deleteAccountConfirm = 'Delete Account';
  static const String deleteAccountCancel = 'Cancel';
}

/// Checklist messages
class ChecklistStrings {
  static const String toBeDone = 'To be Done';
  static const String completed = 'Completed';
  static const String noCompletedChecklist = 'No completed checklists yet';
  static const String inProgress = 'In Progress';
  static String stepsCount(int count) => '$count Steps';
  static String completedOnDate(String dateStr) => 'Completed on $dateStr';
  static const String allDone = 'All Done! 🎉';
  static const String done = 'Done! 🎉';
  static const String congratulationsAllDone =
      'Congratulations, you\'ve completed all available Preparedness Checklists!';
  static const String congratulations =
      'Congratulations, you\'ve completed this Checklist!';
  static String nextChecklistDue(String dateStr) =>
      " Your next checklist is not due until $dateStr.";
  static String nextDue(String dateStr) =>
      " It should be done again on $dateStr.";
  static const String checkCompletedTab =
      'Check the Completed tab to review your completed checklists.';
  static const String allChecklist = 'All Checklists';
  static String completeFrequency(String frequencyName) =>
      'Complete $frequencyName';
  static const String newChecklist = 'New Checklist';
  static const String manageChecklists = 'Manage Preparedness Checklists';
  static const String addNewPreparednessChecklist =
      'Add New Preparedness Checklist';
  static const String editPreparednessChecklist = 'Edit Preparedness Checklist';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String addNewStep = 'Add New Step';
  static const String titleFieldLabel = 'Title*';
  static const String frequencyFieldLabel = 'Frequency';
  static const String priorityFieldLabel = 'Priority Level*';
  static const String descriptionFieldLabel =
      'Description* (Visible to all users)';
  static const String notesFieldLabel =
      'Notes (Visible only to LEAP steering committee)';
  static const String stepLabelFieldLabel = 'Label*';
  static const String stepDescriptionFieldLabel = 'Step Description';
  static const String pleaseSelect = '-- Please Select --';
}

/// Resource messages
class ResourceStrings {
  static const String searchResources = 'Search for a resource';
  static const String selectResourceType = 'Select a resource type';
  static const String noResourcesFound = 'No resources found';
  static const String allResources = 'All Resources';
  static const String addResource = 'New Resource';
  static const String manageResources = 'Manage Resources';
  static const String resourcesInventory = 'Resources Inventory';
  static const String noUserResources = 'You have not added any resources yet';
  static String addedOnDate(DateTime date) =>
      "Added on ${DateFormat.yMMMd('en').format(date)}";
  static const String markUpToDate = 'Up-to-date';
  static const String delete = 'Delete';
  static const String quantity = 'Quantity';
  static const String notes = 'Notes';
  static const String update = 'Update';
  static const String whoCanRequestLabel = 'Who can request:';
  static const String whoCanRequestEmergencyLabel = 'In an emergency:';
  static const String updateSuccess = 'Item updated successfully';
  static String bulkUpdateSuccess(int count) =>
      '$count item(s) updated successfully';
  static const String deleteSuccess = 'Item deleted successfully';
  static String bulkDeleteSuccess(int count) =>
      '$count item(s) deleted successfully';
  static const String resourceRemovedMessage =
      'This resource has been removed.';
  static String itemLabel(int number) => '$number)';
  static String deleteConfirm(List<int> itemNumbers) {
    return itemNumbers.length == 1
        ? 'Delete Item ${itemNumbers.first}?'
        : 'Delete ${itemNumbers.length} items?';
  }

  static String deleteConfirmWithReservations(
      List<int> itemNumbersWithReservations) {
    final itemsText = itemNumbersWithReservations.length == 1
        ? 'Item ${itemNumbersWithReservations.first} has a reservation on it.'
        : 'Items ${itemNumbersWithReservations.join(', ')} have reservations on them.';
    return '$itemsText Still delete?';
  }
}

class SharingScopeStrings {
  static const String clusterOnly = 'My Cluster Only';
  static const String neighborhood = 'All Clusters in Neighborhood';
  static const String everyone = 'Everyone';
}

class SelectionToolbarStrings {
  static const String select = 'Select';
  static const String delete = 'Delete';
  static String selectedCount(int count) => '$count selected';
}

class AddResourceInventoryFormStrings {
  static String thankYou = "Thank you";
  static String done = "Done";
  static String addTitle(String resourceName) =>
      "Add $resourceName to Inventory";
  static const String howManyAdding = 'How many are you adding?';
  static const String setSharingScopeNormal = 'Who can request this item?';
  static const String setSharingScopeEmergency =
      'Who can request this in an emergency?';
  static String askSubtype(String resourceName) =>
      "What type of $resourceName is it (if known)?";
  static const String notes = 'Any notes on this item?';
  static String notesHelperText =
      "Notes are always visible to ${AppStrings.appName} admins and your cluster captain, and are visible to a requester if you accept their request.";
  static String thankYouText(String resourceName) =>
      "You have successfully added your $resourceName. Thanks for helping our community be more prepared and resilient! Go to My Resources to update this item at any time. During an emergency, you may receive a request to use your item. The requester won't know your identity until you accept their request. Likewise, you'll be able to request items and skills others have added. To keep our inventory up to date, we'll check in with you in six months to see if the item is still available.";
}

class AddResourceFormStrings {
  static const String nameOfResource = 'Name of Resource';
  static const String typeOfResource = 'Resource Type';
  static const String totalNumberNeeded = 'Total number needed';
  static const String numberAvailable = 'Number currently available';
  static const String description = 'Description (visible to all users)';
  static const String subtype = 'Subtype, if applicable';
  static const String notes =
      'Notes (visible only to neighborhood steering committee)';
}

class RequestResourceFormStrings {
  static const String numberNeeded = 'Number needed';
  static const String timeNeeded = 'Time needed';
  static const String notes =
      'Details or special notes on this request (optional)';
  static String reqTitle(String resourceName) => "Request $resourceName";
  static const String requestCancelled = 'Request canceled';
  static String insufficientInventoryWarning(
          int totalAvailable, int requested) =>
      'Insufficient Quantity: $totalAvailable of the $requested requested unit(s) are '
      'currently available to request. Continue anyway?';
  static const String requestScope = 'Who to ask for this item?';
}

/// Error messages
class ErrorMessageStrings {
  static const String invalidEmail = 'Invalid email';
  static const String invalidPassword = 'Invalid password';
  static const String invalidConfirmPassword = 'Passwords do not match';
  static const String invalidSignUpCode = 'Invalid sign up code';
  static const String mustNotContainSpecialCharacters =
      'Must not contain any special characters';
  static const String noUserIsSignedIn =
      'No user is currently signed in, please try re-login';
}

/// App Modes Strings
class AppModes {
  static const String normal = 'normal';
  static const String emergency = 'emergency';
  static const String testEmergency = 'test';
}

class AppRoles {
  static const String user = 'user';
  static const String subcommunityAgent = 'subcom_agent';
  static const String communityAdmin = 'com_admin';
  static const String admin = 'admin';
}

class NavRouteLabels {
  static const String home = 'Map';
  static const String profile = 'My Profile';
  static const String prepare = 'My Checklists';
  static const String resources = 'My Resources';
  static const String messages = 'Messages';
  static const String manageResources = 'Manage Resources';
  static const String manageChecklists = 'Manage Checklists';
  static const String adminCluster = 'Cluster Admin';
  static const String adminNeighborhood = 'Neighborhood Admin';
}

class ClusterAdminStrings {
  static const String addHousehold = 'Add Household';
  static const String selectFilter = 'Filter households';
  static const String clusterFilterAll = "All households";
  static const String clusterFilterAssist = "Needs assisstance";
  static const String clusterFilterResources = "Has resources";
  static const String clusterFilterParticipate = "Low participation";
  static const String searchHouseholds = "Search households";
  static const String noHouseholdsFound = 'No households found';
}

class NeighborhoodStrings {
  static const String addCluster = 'New cluster';
  static const String selectFilter = 'Filter clusters';
  static const String clusterFilterAll = "All clusters";
  static const String clusterFilterNeedCaptain = "Needs captain";
  static const String clusterFilterParticipate = "Low participation";
  static const String searchClusters = "Search clusters";
  static const String noClustersFound = 'No Cluster found';
  static const String captainNeeded = 'Captain needed';

  static final String manageNeighborhood = "Manage ${AppConfig.neighborhood}";
}

class MessagesStrings {
  static const String blockedCommunication = "Chat disabled with this user.";
  static const String block = 'Block User';
  static const String unblock = 'Unblock User';
  static const String acceptRequest = 'Accept';
  static const String rejectRequest = 'Reject';
  static const String tentativeAccept = 'Tentative';
  static const String statusPending = 'Pending';
  static const String statusTentative = 'Tentative';
  static const String statusAccepted = 'Accepted';
  static const String statusRejected = 'Rejected';
  static const String statusReleased = 'Released';
  static const String statusExpired = 'Expired';
  static String acceptMessage(int accepted, int total) => accepted == total
      ? 'Accepted all $total requested item(s).'
      : 'Accepted $accepted of $total requested item(s). '
          'The remaining ${total - accepted} item(s) could not be fulfilled by this supplier.';
  static String tentativeAcceptMessage(int accepted, int total) => accepted ==
          total
      ? 'Tentatively accepting all $total requested item(s).'
      : 'Tentatively accepting $accepted of $total requested item(s). '
          'The remaining ${total - accepted} item(s) could not be fulfilled by this supplier.';
  static String rejectMessage(int total) =>
      'Rejected the request for $total item(s).';
  static const String cancelRequest = 'Cancel Request';
  static String cancelRequestMessage(int total) =>
      'Canceled the request for $total item(s).';
}
