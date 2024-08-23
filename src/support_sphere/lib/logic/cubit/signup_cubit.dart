import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/data/validators/login/email.dart';
import 'package:support_sphere/data/validators/login/password.dart';
import 'package:support_sphere/data/validators/signup/signup_code.dart';
import 'package:support_sphere/data/validators/signup/confirmed_password.dart';
import 'package:formz/formz.dart';
import 'package:support_sphere/logic/cubit/utils.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._authenticationRepository) : super(const SignupState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password, state.confirmedPassword]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password, state.confirmedPassword]),
      ),
    );
  }

  void signupCodeChanged(String value) {
    final signupCode = SignupCode.dirty(value);
    emit(
      state.copyWith(
        signupCode: signupCode,
        isValid: Formz.validate([state.email, state.password, state.confirmedPassword, signupCode]),
      ),
    );
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(password: state.password.value, value: value);
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate([state.email, state.password, confirmedPassword]),
      ),
    );
  }

  void toggleShowPassword() {
    changeShowPassword(emit, state);
  }

  Future<void> signUpWithEmailAndPassword() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // TODO: Add coupon code check for signup
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
        signupCode: state.signupCode.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
