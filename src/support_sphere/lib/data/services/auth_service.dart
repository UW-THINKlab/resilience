import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:support_sphere/utils/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:support_sphere/constants/string_catalog.dart';
// TODO: ADD API Handling in here for exceptions

final _log = Logger('AuthService');

class AuthService extends Equatable{
  static final GoTrueClient _supabaseAuth = supabase.auth;
  final SupabaseClient _supabaseClient = supabase;

  User? getSignedInUser() => _supabaseAuth.currentUser;
  Session? getUserSession() => _supabaseAuth.currentSession;

  Future<Map<String, dynamic>?> isSignupCodeValid(String code) async {
    return await _supabaseClient.from('signup_codes').select().eq('code', code).maybeSingle();
  }

  Future<void> invalidateSignupCode(String code) async {
    await _supabaseClient.rpc('invalidate_signup_code', params: {'input_code': code});
  }

  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async {
    // TODO: Add email verification in the future
    final response = await _supabaseAuth.signUp(email: email, password: password);
    return response;
  }

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    _log.fine("login: $email, $_supabaseAuth");
    final response = await _supabaseAuth.signInWithPassword(email: email, password: password);
    _log.fine("login response: $response");
    return response;
  }

  Stream<Session?> getCurrentSession() => _supabaseAuth.onAuthStateChange.map((data) => data.session);

  Future<void> signOut() async => await _supabaseAuth.signOut();

  Future<UserResponse> updateUserPhone(String? phone) async {
    if (_supabaseAuth.currentUser == null) {
      throw Exception(ErrorMessageStrings.noUserIsSignedIn);
    }

    if (phone == null || phone.isEmpty) {
      // Currently, there is a bug in Supabase (see: https://github.com/supabase/supabase-js/issues/1008)
      // where updateUser() does not clear the phone field correctly when the “new” phone value is empty.
      // As a workaround, we can use Supabase RPC (see: https://www.restack.io/docs/supabase-knowledge-supabase-rpc-guide)
      // or develop a separate API to implement this functionality.
      // For now, I will ignore this issue, leaving the problem unresolved when a user has a phone number and wants to clear it.

      // RPC Workaround:
      // await _supabaseClient.rpc('clear_user_phone', params: { 'user_id': _supabaseAuth.currentUser?.id });
      return Future.value(UserResponse.fromJson(_supabaseAuth.currentUser?.toJson() ?? {}));
    } else {
      return await _supabaseAuth.updateUser(
        UserAttributes(
          phone: phone,
        ),
      );
    }
  }

  @override
  List<Object?> get props => [];
}
