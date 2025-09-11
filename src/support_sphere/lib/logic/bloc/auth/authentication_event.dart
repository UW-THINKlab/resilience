part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthOnCurrentUserChanged extends AuthenticationEvent {
  AuthOnCurrentUserChanged(this.user);

  final MyAuthUser user;
}

class AuthOnLogoutRequested extends AuthenticationEvent {}
