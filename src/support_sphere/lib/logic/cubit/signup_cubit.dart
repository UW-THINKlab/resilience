import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:formz/formz.dart';
import 'package:support_sphere/logic/cubit/utils.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._authenticationRepository) : super(const SignupState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
      ),
    );
  }

  void signupCodeChanged(String value) {
    emit(
      state.copyWith(
        signupCode: value,
      ),
    );
  }

  void confirmedPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmedPassword: value,
      ),
    );
  }

  void toggleShowPassword() => changeShowPassword(emit, state);
  void setValid() => emit(state.copyWith(isValid: true));
  void setInvalid() => emit(state.copyWith(isValid: false));

  Future<void> signUpWithEmailAndPassword() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // TODO: Add coupon code check for signup
      await _authenticationRepository.signUp(
        email: state.email,
        password: state.password,
        signupCode: state.signupCode,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
