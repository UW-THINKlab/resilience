part of 'signup_cubit.dart';

class SignupState extends Equatable {
  const SignupState({
    this.givenName = '',
    this.familyName = '',
    this.email = '',
    this.password = '',
    this.confirmedPassword = '',
    this.signupCode = '',
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.showPassword = false,
    this.isAllFieldsFilled = false,
    this.errorMessage,
  });

  final String givenName;
  final String familyName;
  final String email;
  final String password;
  final String confirmedPassword;
  final String signupCode;
  final FormzSubmissionStatus status;
  final bool isValid;
  final bool showPassword;
  final bool isAllFieldsFilled;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        givenName,
        familyName,
        email,
        password,
        confirmedPassword,
        signupCode,
        status,
        isValid,
        isAllFieldsFilled,
        errorMessage,
        showPassword,
      ];

  SignupState copyWith({
    String? givenName,
    String? familyName,
    String? email,
    String? password,
    String? confirmedPassword,
    String? signupCode,
    FormzSubmissionStatus? status,
    bool? isValid,
    bool? isAllFieldsFilled,
    bool? showPassword,
    String? errorMessage,
  }) {
    return SignupState(
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      signupCode: signupCode ?? this.signupCode,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      isAllFieldsFilled: isAllFieldsFilled ?? this.isAllFieldsFilled,
      errorMessage: errorMessage ?? this.errorMessage,
      showPassword: showPassword ?? this.showPassword,
    );
  }

  // Check if all fields are filled
  bool checkAllFieldsFilled() {
    return givenName.isNotEmpty &&
        familyName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmedPassword.isNotEmpty &&
        signupCode.isNotEmpty;
  }
}
