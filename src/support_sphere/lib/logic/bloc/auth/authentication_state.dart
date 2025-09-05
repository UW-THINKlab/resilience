part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated }

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unauthenticated,
    this.user = MyAuthUser.empty,
  });

  const AuthenticationState.initial() : this._();

  const AuthenticationState.authenticated(MyAuthUser user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final MyAuthUser user;

  @override
  List<Object> get props => [status, user];
}
