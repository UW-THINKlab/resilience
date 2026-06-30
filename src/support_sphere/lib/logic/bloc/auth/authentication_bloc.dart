import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:support_sphere/data/repositories/authentication.dart';
import 'package:support_sphere/data/models/auth_user.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authRepository = authenticationRepository,
        super(const AuthenticationState.initial()) {
    on<AuthOnCurrentUserChanged>(_onCurrentUserChanged);
    on<AuthOnLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteMyUserRequested>(_onDeleteMyUserRequested);

    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthOnCurrentUserChanged(user)),
    );
  }

  final AuthenticationRepository _authRepository;
  late final StreamSubscription<MyAuthUser> _userSubscription;

  void _onCurrentUserChanged(
      AuthOnCurrentUserChanged event, Emitter<AuthenticationState> emit) {
    emit(
      event.user.isNotEmpty
          ? AuthenticationState.authenticated(event.user)
          : const AuthenticationState.unauthenticated(),
    );
  }

  void _onLogoutRequested(
      AuthOnLogoutRequested event, Emitter<AuthenticationState> emit) {
    unawaited(_authRepository.logOut());
  }

  Future<void> _onDeleteMyUserRequested(
      AuthDeleteMyUserRequested event, Emitter<AuthenticationState> emit) async {
    await _authRepository.deleteMyAccount();
    await _authRepository.logOut();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
