part of 'login_cubit.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.showPassword = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final bool showPassword;
  final String? errorMessage;

  @override
  List<Object?> get props => [email, password, status, isValid, errorMessage, showPassword];

  LoginState copyWith({
    String? email,
    String? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    bool? showPassword,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      showPassword: showPassword ?? this.showPassword,
    );
  }
}