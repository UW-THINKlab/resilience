import 'dart:async';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/utils.dart';

class AuthenticationRepository {
  final _authService = AuthService();

  /// Stream of [AuthUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthUser.empty] if the user is not authenticated.
  Stream<AuthUser> get user {
    // Transform the regular supabase user object to our own User model
    return _authService.getCurrentSession().map((session) {
      String userRole = _parseUserRole(session);
      return _parseUser(session?.user, userRole);
    });
  }

  AuthUser get currentUser {
    supabase_flutter.Session? session = _authService.getUserSession();
    // Transform the regular supabase user object to our own User model
    String userRole = _parseUserRole(session);
    return _parseUser(session?.user, userRole);
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async =>
      _authService.signInWithEmailAndPassword(email, password);

  Future<void> logOut() async => await _authService.signOut();

  Future<supabase_flutter.AuthResponse> signUp({
    required String email,
    required String password,
    required String signupCode,
  }) async {
    bool isCodeValid = await _authService.isSignupCodeValid(signupCode);
    if (!isCodeValid) {
      throw Exception(ErrorMessageStrings.invalidSignUpCode);
    } else {
      return _authService.signUpWithEmailAndPassword(email, password);
    }
  }

  AuthUser _parseUser(supabase_flutter.User? user, String userRole) {
    return user == null
        ? AuthUser.empty
        : AuthUser(
            uuid: user.id,
            userRole: userRole,
            email: user.email,
            phone: user.phone);
  }

  String _parseUserRole(supabase_flutter.Session? session) {
    String defaultReturn = '';
    if (session != null) {
      String token = session.accessToken;
      Map<String, dynamic> decodedToken = Jwtdecode(token);
      String userRole = decodedToken['user_role'] ?? defaultReturn;
      print("User role: ${userRole}");
      return userRole;
    }
    return defaultReturn;
  }

  Future<AuthUser> updateUserPhoneNumber({
    String? phone,
  }) async {
    final response = await _authService.updateUserPhone(phone);
    supabase_flutter.Session? session = _authService.getUserSession();

    return _parseUser(response.user, _parseUserRole(session));
  }
}
