part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthOnCurrentUserChanged extends AuthenticationEvent {
  AuthOnCurrentUserChanged(this.user);

  final AuthUser user;
}

class AuthOnLogoutRequested extends AuthenticationEvent {}
