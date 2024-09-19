import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_sphere/logic/cubit/utils.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

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

  void setValid() => emit(state.copyWith(isValid: true));
  void setInvalid() => emit(state.copyWith(isValid: false));

  void toggleShowPassword() {
    changeShowPassword(emit, state);
  }

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logIn(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
