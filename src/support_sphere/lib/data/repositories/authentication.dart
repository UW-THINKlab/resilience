import 'dart:async';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/constants/string_catalog.dart';

class AuthenticationRepository {
  final _authService = AuthService();

  /// Stream of [AuthUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthUser.empty] if the user is not authenticated.
  Stream<AuthUser> get user {
    // Transform the regular supabase user object to our own User model
    return _authService.getCurrentUser().map((user) => _parseUser(user));
  }

  supabase_flutter.User? getRawUser() {
    return _authService.getSignedInUser();
  }

  AuthUser get currentUser {
    supabase_flutter.User? user = _authService.getSignedInUser();
    // Transform the regular supabase user object to our own User model
    return _parseUser(user);
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async => _authService.signInWithEmailAndPassword(email, password);

  Future<void> logOut() async => await _authService.signOut();

  Future<void> signUp({
    required String email,
    required String password,
    required String signupCode,
  }) async {
    bool isCodeValid = await _authService.isSignupCodeValid(signupCode);
    if (!isCodeValid) {
      throw Exception(ErrorMessageStrings.invalidSignUpCode);
    } else {
      await _authService.signUpWithEmailAndPassword(email, password);
    }
  }

  Future<void> updateUser({
    String? email,
    String? phone,
    String? password,
  }) async {
    await _authService.updateUser(email, phone, password);
  }

  AuthUser _parseUser(supabase_flutter.User? user) {
    return user == null ? AuthUser.empty : AuthUser(uuid: user.id);
  }
}
