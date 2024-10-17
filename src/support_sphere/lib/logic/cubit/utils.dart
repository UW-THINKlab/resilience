/// Abstract class for cubits that can be validated
abstract class ValidatableCubit {
  void setValid();
  void setInvalid();
}

void changeShowPassword(emit, state) {
    emit(state.copyWith(showPassword: !state.showPassword));
}
