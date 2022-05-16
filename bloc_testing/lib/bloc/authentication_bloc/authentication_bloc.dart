import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:/authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:pedantic/pedantic.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    @required AuthenticationRepository authenticationRepository,
  })  : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        super(const AuthenticationState.unknown()) {
    _resourceSubscription = _authenticationRepository.getResources().listen(
            (resourceState) => add(AuthenticationResourceChanges(resourceState))
    );
  }

  void _startUserSubscription(){
    _userSubscription = _authenticationRepository.user.listen(
          (user) => add(AuthenticationUserChanged(user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  StreamSubscription<UserData> _userSubscription;
  StreamSubscription<String> _resourceSubscription;

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if(event is AuthenticationUserChanged){
      yield _mapAuthenticationUserChangedToState(event);
    }else if (event is AuthenticationResourceChanges){
      if(event.resourceState == "Done" || event.resourceState == "Downloaded"){
        _resourceSubscription.cancel();
        _startUserSubscription();
      }
    }else if (event is AuthenticationLogoutRequested){
      unawaited(_authenticationRepository.logOut());
    }
  }
  @override
  Future<Function> close() {
    _userSubscription?.cancel();
    _resourceSubscription?.cancel();
    return super.close();
  }


  AuthenticationState _mapAuthenticationUserChangedToState(
      AuthenticationUserChanged event,
      ){
    if(event.user == UserData.empty){
      return AuthenticationState.unauthenticated();
    }else{
      if(event.user.uAuthType == "provider"){
        return AuthenticationState.authenticated(event.user);
      }else{
        return AuthenticationState.authenticatedAnonymously();
      }
    }
  }
}
