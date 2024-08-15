import 'dart:async';
import 'package:support_sphere/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:support_sphere/data/models/user.dart';

class AuthenticationRepository {
  final _authService = AuthService();

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    // Transform the regular supabase user object to our own User model
    return _authService.getCurrentUser().map((user) => _parseUser(user));
  }

  User get currentUser {
    supabase_flutter.User? user = _authService.getSignedInUser();
    // Transform the regular supabase user object to our own User model
    return _parseUser(user);
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async => _authService.signInWithEmailAndPassword(username, password);

  Future<void> logOut() async => await _authService.signOut();

  Future<void> signUp({
    required String username,
    required String password,
  }) async => _authService.signUpWithEmailAndPassword(username, password);

  User _parseUser(supabase_flutter.User? user) {
    return user == null ? User.empty : User(uuid: user.id);
  }
}
