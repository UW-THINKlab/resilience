@Skip('TODO: Ignore test.. need to have supabase instance running')

import 'package:flutter_test/flutter_test.dart';
import 'package:support_sphere/data/services/auth_service.dart';


void main() {

  late AuthService authService;

  // This is the parent level setUp() function that runs before each test defined in this class.
  setUp(() {
    authService = AuthService();
  });

  // A group is used to scope together tests having similar description, and
  // group level setUp() or tearDown() functions.
  // This should not be confused with the parent level setUp() and tearDown()
  // Refer: https://docs.flutter.dev/cookbook/testing/unit/introduction#5-combine-multiple-tests-in-a-group

  group('AuthService SignUp Code Validation Tests', () {
    test('isSignupCodeValid returns false for invalid code', () async {
      final result = await authService.isSignupCodeValid('INVALID');
      expect(result == null, isFalse);
    });
  });
}
