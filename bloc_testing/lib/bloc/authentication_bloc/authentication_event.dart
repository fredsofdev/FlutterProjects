part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();


}

class AuthenticationUserChanged extends AuthenticationEvent {
  const AuthenticationUserChanged(this.user);

  final UserData user;


  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class AuthenticationResourceChanges extends AuthenticationEvent {
  const AuthenticationResourceChanges(this.resourceState);

  final String resourceState;

  @override
  // TODO: implement props
  List<Object> get props => [resourceState];

}


class AuthenticationLogoutRequested extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}