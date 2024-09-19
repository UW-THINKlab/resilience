part of 'signup_cubit.dart';

class SignupState extends Equatable {
  const SignupState({
    this.email = '',
    this.password = '',
    this.confirmedPassword = '',
    this.signupCode = '',
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.showPassword = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final String confirmedPassword;
  final String signupCode;
  final FormzSubmissionStatus status;
  final bool isValid;
  final bool showPassword;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        email,
        password,
        confirmedPassword,
        signupCode,
        status,
        isValid,
        errorMessage,
        showPassword,
      ];

  SignupState copyWith({
    String? email,
    String? password,
    String? confirmedPassword,
    String? signupCode,
    FormzSubmissionStatus? status,
    bool? isValid,
    bool? showPassword,
    String? errorMessage,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      signupCode: signupCode ?? this.signupCode,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      showPassword: showPassword ?? this.showPassword,
    );
  }
}
