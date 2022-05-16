import 'dart:io';


class AppConfig{
  static String admobAppID='ca-app-pub-1747473266862389~6965919986';
  static String admobNativeAdUnitID='ca-app-pub-3940256099942544/2247696110';//'ca-app-pub-1747473266862389/6872945869';
  static String firebaseGameResourceFileName='osgame_20200706_01.zip';
  static Directory appDocDirectory;

  static Setting setting = Setting();
}


class Setting {
  Setting();
  bool _backgroundSound=false;
  bool _soundEffect=false;
  bool _vibrate=false;
  bool _lowPower=false;
  bool _lightingEffect=false;
  bool _highResolution=false;

  // ignore: unnecessary_getters_setters
  bool get backgroundSound => _backgroundSound;
  // ignore: unnecessary_getters_setters
  bool get soundEffect => _soundEffect;
  // ignore: unnecessary_getters_setters
  bool get vibrate => _vibrate;
  // ignore: unnecessary_getters_setters
  bool get lowPower => _lowPower;
  // ignore: unnecessary_getters_setters
  bool get lightingEffect => _lightingEffect;
  // ignore: unnecessary_getters_setters
  bool get highResolution => _highResolution;



  // ignore: unnecessary_getters_setters
  set backgroundSound(bool b) => _backgroundSound=b;
  // ignore: unnecessary_getters_setters
  set soundEffect(bool b) => _soundEffect=b;
  // ignore: unnecessary_getters_setters
  set vibrate(bool b) => _vibrate=b;
  // ignore: unnecessary_getters_setters
  set lowPower(bool b) => _lowPower=b;
  // ignore: unnecessary_getters_setters
  set lightingEffect(bool b) => _lightingEffect=b;
  // ignore: unnecessary_getters_setters
  set highResolution(bool b) => _highResolution=b;
}