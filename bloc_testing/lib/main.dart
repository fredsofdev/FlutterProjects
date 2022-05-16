import 'package:bloc/bloc.dart';
import 'package:bloc_testing/app.dart';
import 'package:bloc_testing/simple_bloc_observer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:/authentication_repository/authentication_repository.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  runApp(App(authenticationRepository: AuthenticationRepository()));
}


