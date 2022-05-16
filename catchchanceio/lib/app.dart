import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/screen/home/main_screen.dart';
import 'package:catchchanceio/screen/login/login_screen.dart';
import 'package:catchchanceio/screen/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/authentication_bloc/authentication_bloc.dart';

class App extends StatelessWidget {
  const App({

    required this.authenticationRepository,
  });

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;
  final RouteObserver<PageRoute> _routeObserver = RouteObserver();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Provider.value(
      value: _routeObserver,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.yellow.shade700, primarySwatch: Colors.yellow),
        navigatorKey: _navigatorKey,
        navigatorObservers: [_routeObserver],
        builder: (context, child) {
          return BlocListener<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              switch (state.status) {
                case AuthenticationStatus.unauthenticated:
                  _navigator.pushAndRemoveUntil<void>(
                    LoginScreen.route(),
                    (route) => false,
                  );
                  break;
                case AuthenticationStatus.authenticated:
                  _navigator.pushAndRemoveUntil<void>(
                    MainScreen.route(),
                    (route) => false,
                  );
                  break;
                default:
                  break;
              }
            },
            child: child,
          );
        },
        onGenerateRoute: (_) => SplashScreen.route(),
      ),
    );
  }
}
