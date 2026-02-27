import 'package:flutter_test/flutter_test.dart';
import 'package:support_sphere/data/models/user_role_record.dart';
import 'package:support_sphere/constants/string_catalog.dart';

void main() {
  group('UserRoleRecord Tests', () {
    test('displayName returns fullName when not empty', () {
      const record = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: 'Doe',
        role: AppRoles.user,
      );
      expect(record.displayName, 'John Doe');
    });

    test('displayName falls back to userProfileId when fullName is empty', () {
      const record = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: '',
        familyName: '',
        role: AppRoles.user,
      );
      expect(record.displayName, 'test-id');
    });

    test('fullName returns concatenated given and family name', () {
      const record = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: 'Doe',
        role: AppRoles.user,
      );
      expect(record.fullName, 'John Doe');
    });

    test('fullName trims whitespace when familyName is empty', () {
      const record = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: '',
        role: AppRoles.user,
      );
      expect(record.fullName, 'John');
    });

    test('copyWith returns updated record', () {
      const record = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: 'Doe',
        role: AppRoles.user,
      );
      final updated = record.copyWith(role: AppRoles.subcommunityAgent);
      expect(updated.role, AppRoles.subcommunityAgent);
      expect(updated.givenName, 'John');
      expect(updated.familyName, 'Doe');
    });

    test('props equality works correctly', () {
      const record1 = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: 'Doe',
        role: AppRoles.user,
      );
      const record2 = UserRoleRecord(
        userProfileId: 'test-id',
        givenName: 'John',
        familyName: 'Doe',
        role: AppRoles.user,
      );
      expect(record1, equals(record2));
    });
  });

  group('ManageUserRolesStrings Tests', () {
    test('all string constants are non-empty', () {
      expect(ManageUserRolesStrings.pageTitle, isNotEmpty);
      expect(ManageUserRolesStrings.grantRole, isNotEmpty);
      expect(ManageUserRolesStrings.revokeRole, isNotEmpty);
      expect(ManageUserRolesStrings.currentRole, isNotEmpty);
      expect(ManageUserRolesStrings.confirmGrant, isNotEmpty);
      expect(ManageUserRolesStrings.confirmRevoke, isNotEmpty);
      expect(ManageUserRolesStrings.buttonConfirm, isNotEmpty);
      expect(ManageUserRolesStrings.buttonCancel, isNotEmpty);
      expect(ManageUserRolesStrings.noUsers, isNotEmpty);
    });
  });

  group('AppRoles Constants Tests', () {
    test('subcommunityAgent role value is SUBCOM_AGENT', () {
      expect(AppRoles.subcommunityAgent, 'SUBCOM_AGENT');
    });

    test('communityAdmin role value is COM_ADMIN', () {
      expect(AppRoles.communityAdmin, 'COM_ADMIN');
    });

    test('user role value is USER', () {
      expect(AppRoles.user, 'USER');
    });
  });
}
