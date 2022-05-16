import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/simple_bloc_observer.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';




// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  AppConfig.setting.backgroundSound =
      _prefs.getBool("setting_backgroundSound") ?? true;
  await Firebase.initializeApp();


  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  MobileAds.instance.initialize();
  // FacebookAudienceNetwork.init(
  //     testingId: '3f541525-47c1-497d-9618-999175aa350a' //Logan Phone id
  // );
  runApp(App(authenticationRepository: AuthenticationRepository()));
}
