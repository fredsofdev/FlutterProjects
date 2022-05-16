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

class AuthenticationLogoutRequested extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class StartAuthenticationListener extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationDelete extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TickerEvent extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TimeAdRewardEvent extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ChargeAdRewardEvent extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TimeAdRewardTickerEvent extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ChargeAdRewardTickerEvent extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetNotice extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetQNA extends AuthenticationEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PostQNA extends AuthenticationEvent {
  final String title;
  final String question;

  @override
  // TODO: implement props
  List<Object> get props => [title, question];

  const PostQNA(this.title, this.question);
}

