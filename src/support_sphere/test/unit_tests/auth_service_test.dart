import 'package:flutter_test/flutter_test.dart';


void main() {


  // This is the parent level setUp() function that runs before each test defined in this class.
  setUp(() {
  });

  // A group is used to scope together tests having similar description, and
  // group level setUp() or tearDown() functions.
  // This should not be confused with the parent level setUp() and tearDown()
  // Refer: https://docs.flutter.dev/cookbook/testing/unit/introduction#5-combine-multiple-tests-in-a-group

  group('AuthService SignUp Code Validation Tests', () {
    // TODO: Ignore test.. need to have supabase instance running
    // test('isSignupCodeValid returns false for invalid code', () async {
    //   final result = await authService.isSignupCodeValid('INVALID');
    //   expect(result == null, isFalse);
    // });
  });
}
