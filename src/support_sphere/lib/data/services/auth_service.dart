import 'package:equatable/equatable.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: ADD API Handling in here for exceptions

List<String> _validSignupCodes = const [
  'SUPPRT',
  'SPHERE',
  'SIGNUP',
];

class AuthService extends Equatable {
  static final GoTrueClient _supabaseAuth = supabase.auth;

  User? getSignedInUser() => _supabaseAuth.currentUser;

  Future<bool> isSignupCodeValid(String code) async {
    // TODO: Replace with API call to check if code is valid
    return Future.delayed(const Duration(milliseconds: 300),
        () => _validSignupCodes.contains(code));
  }

  Future<AuthResponse> signUpWithEmailAndPassword(
      String email, String password) async {
    // TODO: Add email verification in the future
    final response =
        await _supabaseAuth.signUp(email: email, password: password);
    return response;
  }

  Future<void> updateUser(
      String? email, String? phone, String? password) async {
    await _supabaseAuth.updateUser(
      UserAttributes(
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }

  Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    final response = await _supabaseAuth.signInWithPassword(
        email: email, password: password);
    return response;
  }

  Stream<User?> getCurrentUser() =>
      _supabaseAuth.onAuthStateChange.map((data) => data.session?.user);

  Future<void> signOut() async => await _supabaseAuth.signOut();

  @override
  List<Object?> get props => [];
}
