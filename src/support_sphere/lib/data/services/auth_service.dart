import 'package:equatable/equatable.dart';
import 'package:support_sphere/utils/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: ADD API Handling in here for exceptions

class AuthService extends Equatable{

  static final GoTrueClient _supabaseAuth = supabase.auth;
  static const String _redirectUrl = 'io.supabase.flutterexample://signup-callback';

  User? getSignedInUser() => _supabaseAuth.currentUser;

  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async {
    final response = await _supabaseAuth.signUp(email: email, password: password, emailRedirectTo: _redirectUrl);
    return response;
  }

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    final response = await _supabaseAuth.signInWithPassword(email: email, password: password);
    return response;
  }

  Stream<User?> getCurrentUser() => _supabaseAuth.onAuthStateChange.map((data) => data.session?.user);

  Future<void> signOut() async => await _supabaseAuth.signOut();

  @override
  List<Object?> get props => [];
}
