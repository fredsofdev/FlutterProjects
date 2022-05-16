
import 'dart:ui';

import 'package:dogfeed/connection_cubit.dart';
import 'package:dogfeed/connection_repo.dart';
import 'package:dogfeed/control.dart';
import 'package:dogfeed/login.dart';
import 'package:dogfeed/simple_bloc_observer.dart';
import 'package:dogfeed/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp();
  runApp( App(connectionRepo: ConnectionRepository(),));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

class App extends StatelessWidget {
  const App({
     Key? key,
    required this.connectionRepo,
  })  : assert(connectionRepo != null),
        super(key: key);

  final ConnectionRepository connectionRepo;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: connectionRepo,
      child: BlocProvider(
        create: (_) => ConnectionCubit(
          connectionRepo,
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

  NavigatorState? get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            brightness: Brightness.light
          ),
          primaryColor: Colors.green.shade700,
          primarySwatch: Colors.green),
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<ConnectionCubit, ConnectionsState>(
          listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
          listener: (context, state) {
            switch (state.isLoggedIn) {
              case AuthState.login:
                _navigator?.pushAndRemoveUntil<void>(
                  Control.route(),
                      (route) => false,
                );
                break;
              case AuthState.logout:
              // _navigator.pushAndRemoveUntil<void>(
              //     PageTransition(
              //         type: PageTransitionType
              //             .fade,
              //         child: PlayScreen(
              //           user: state.user,stage: "stage2",)),
              //     (route)=> false,
              // );
              //   _navigator?.pushAndRemoveUntil<void>(
              //     Control.route(),
              //         (route) => false,
              //   );
                _navigator?.pushAndRemoveUntil<void>(
                  Login.route(),
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
      onGenerateRoute: (_) => Splash.route(),
    );
  }
}