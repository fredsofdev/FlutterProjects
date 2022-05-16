part of 'authentication_bloc.dart';


enum AuthenticationStatus {authenticated, unauthenticated, unknown, authenticatedAnonymously}

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = UserData.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(UserData user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  const AuthenticationState.authenticatedAnonymously()
      : this._(status: AuthenticationStatus.authenticatedAnonymously);

  final AuthenticationStatus status;
  final UserData user;

  @override
  List<Object> get props => [status, user];
}


