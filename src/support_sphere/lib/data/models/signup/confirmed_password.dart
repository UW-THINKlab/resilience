import 'package:formz/formz.dart';
import 'package:support_sphere/constants/auth.dart';
import '../../../constants/string_catalog.dart';

enum ConfirmedPasswordValidationError {
  invalid,
  mismatch,
}

class ConfirmedPassword extends FormzInput<String, ConfirmedPasswordValidationError> {
  final String password;

  const ConfirmedPassword.pure({
    this.password = ''
  }) : super.pure('');

  const ConfirmedPassword.dirty({
    required this.password,
    String value = ''
  }) : super.dirty(value);

  static final _passwordRegExp = passwordRegExp;
  

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (!_passwordRegExp.hasMatch(password)) {
      return ConfirmedPasswordValidationError.invalid;
    }
    if (password != value) {
      return ConfirmedPasswordValidationError.mismatch;
    }
    return null;
  }
}

extension Explanation on ConfirmedPasswordValidationError {
  String? get name {
    switch(this) {
      case ConfirmedPasswordValidationError.mismatch:
        return ErrorMessageStrings.invalidConfirmPassword;
      case ConfirmedPasswordValidationError.invalid:
        return ErrorMessageStrings.invalidPassword;
      default:
        return null;
    }
  }
}
