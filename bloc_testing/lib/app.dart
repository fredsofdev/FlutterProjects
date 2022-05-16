


import 'package:bloc_testing/screen/home/home_screen.dart';
import 'package:bloc_testing/screen/login/login_screen.dart';
import 'package:bloc_testing/screen/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:/authentication_repository/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/authentication_bloc/authentication_bloc.dart';


class App extends StatelessWidget {
  const App ({
   Key key,
   @required this.authenticationRepository,
  }) : assert(authenticationRepository != null),
       super(key: key);

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        child: AppView(),
      ),

    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {

  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      navigatorKey: _navigatorKey,
      builder: (context, child){
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status){
              case AuthenticationStatus.unknown:
                _navigator.pushAndRemoveUntil<void>(
                  SplashScreen.route(),
                    (route) => false,
                );
                break;

              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginScreen.route(),
                      (route) => false,
                );
                break;

              case AuthenticationStatus.authenticatedAnonymously:
                _navigator.pushAndRemoveUntil<void>(
                  LoginScreen.route(),
                      (route) => false,
                );
                break;
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomeScreen.route(),
                      (route) => false,
                );
                break;
            }
          },
        );
      },

    );
  }
}
