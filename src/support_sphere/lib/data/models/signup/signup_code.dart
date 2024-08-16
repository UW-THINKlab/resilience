import 'package:formz/formz.dart';
import 'package:support_sphere/constants/auth.dart';
import 'package:support_sphere/constants/string_catalog.dart';

enum SignupCodeValidationError {
  invalid,
}

class SignupCode extends FormzInput<String, SignupCodeValidationError> {
  const SignupCode.pure() : super.pure('');
  const SignupCode.dirty([String value = '']) : super.dirty(value);

  static final _signupCodeRegExp = signupCodeRegExp;

  @override
  SignupCodeValidationError? validator(String value) {
    return _signupCodeRegExp.hasMatch(value) ? null : SignupCodeValidationError.invalid;
  }
}

extension Explanation on SignupCodeValidationError {
  String? get name {
    switch(this) {
      case SignupCodeValidationError.invalid:
        return ErrorMessageStrings.invalidSignUpCode;
      default:
        return null;
    }
  }
}

