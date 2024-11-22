/// Strings used in the app
class AppStrings {
  static const String appName = 'Support Sphere';
  static const String signUpWelcome =
      'Welcome to ${AppStrings.appName}\nCreate a new account and prepare with your community';
  static const String testEmergencyBannerText = "This is a test emergency.";
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
  static const String allChecklist = 'All Checklist';
  static String completeFrequency(String frequencyName) =>
      'Complete $frequencyName';
}

/// Resource messages
class ResourceStrings {
  static const String searchResources = 'Search for a resource';
  static const String selectResourceType = 'Select a resource type';
  static const String noResourcesFound = 'No resources found';
  static const String allResources = 'All Resources';
  static const String addResource = 'Add New Resource or Skill';
  static const String manageResources = 'Manage Resources';
  static const String resourcesInventory = 'Resources Inventory';
}

class AddResourceInventoryFormStrings {
  static String addTitle(String resourceName) =>
      "Add $resourceName to Inventory";
  static const String howManyAdding = 'How many are you adding?';
  static String askSubtype(String resourceName) =>
      "What type of $resourceName is it (if known)?";
  static const String notes = 'Any notes on this item?';
  static String notesHelperText =
      "Notes are always visible to ${AppStrings.appName} admins and your cluster captain, and are visible to a requester if you accept their request.";
  static String thankYouText(String resourceName) =>
      "You have successfully added your $resourceName. You are helping our community be more prepared and resilient! Go to My Resources to update this item at any time. During an emergency, you may receive a request to use your item. The requester won't know your identity until you accept their request. Likewise, you'll be able to request items and skills others have added. To keep our inventory up to date, we'll check in with you in six months to see if the item is still available.";
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
  static const String normal = 'NORMAL';
  static const String emergency = 'EMERGENCY';
  static const String testEmergency = 'TEST';
}

class AppRoles {
  static const String user = 'USER';
  static const String subcommunityAgent = 'SUBCOM_AGENT';
  static const String communityAdmin = 'COM_ADMIN';
  static const String admin = 'ADMIN';
}

class NavRouteLabels {
  static const String home = 'Home';
  static const String profile = 'Me';
  static const String prepare = 'Prepare';
  static const String resources = 'Resources';
  static const String manageResources = 'Manage Resources';
  static const String manageChecklists = 'Manage Checklists';
}
