void changeShowPassword(emit, state) {
    emit(state.copyWith(showPassword: !state.showPassword));
}
