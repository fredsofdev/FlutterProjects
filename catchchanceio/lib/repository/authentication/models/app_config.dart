import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class AppConfig {
  static String lang = 'kor'; //todo kor, en
  static bool isGif=false;
  static var adColonyZones=['vz3c37ada2f5c4463095','vzfde07255c0a94914b3'];
  static String adColonyAppId='appc334a4c8f443496ba2';

  static var adColonyZonesTest=['vz579db1f63ff34448b8'];
  static String adColonyAppIdTest='app9e5896a21fda4f7192';

  static String fileName = 'src_112';
  static String appVersionName = '1.0.0';
  static String admobAppID = 'ca-app-pub-1747473266862389~1165762922';

  //todo admob nativeAD test:  ca-app-pub-3940256099942544/1044960115 , release : ca-app-pub-1747473266862389/2095701218
  //todo admob reward video AD test:  ca-app-pub-3940256099942544/5224354917 , release : ca-app-pub-1747473266862389/1065674661


  //todo TEST
  static String admobNativeAdUnitID = 'ca-app-pub-3940256099942544/1044960115';
  static String admobRewardedAdUnitID = 'ca-app-pub-3940256099942544/5224354917';


  //todo RELEASE
  // static String admobNativeAdUnitID   = 'ca-app-pub-1747473266862389/2095701218';
  // static String admobRewardedAdUnitID = 'ca-app-pub-1747473266862389/1065674661';


  static String gifAuthCode = 'REAL2c2b18785a7c4b199ca5aa793cc3e8fb';
  static String gifAuthToken = 'bxRTe/4sgYutzSInYTVPXg==';
  static String kakaoKey = '645251b26ed36e78c2b20e894da52617';
  static String lineID = '1655266024';
  static Directory? appDocDirectory;
  static Setting setting = Setting();


  //todo stage 관리
  static Map networkImageJson = {
    'stage': {
      'forest':
          'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/in_game_resources%2Fstage_bg%2Fforest_bg.gif?alt=media&token=64393aa1-504b-4c1d-b86e-de426c395211',
      'desert':
          'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/in_game_resources%2Fstage_bg%2Fdesert_bg.gif?alt=media&token=ba2e0f1d-c6d7-4194-a07e-99f71117af26',
      'mine':
          'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/in_game_resources%2Fstage_bg%2Fmine_bg.gif?alt=media&token=a2d18fa7-cffa-469f-a798-490f8f7eba2a',
      'sea':
          'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/in_game_resources%2Fstage_bg%2Fsea_bg.gif?alt=media&token=895865c5-70d5-423e-ab43-16f1345a494e',
    }
  };


  static Map<String, int> stageDifficultyLevel = {
    'stage1': 1,
    'stage2': 1,
    'stage3': 1,
    'stage4': 2,
    'stage5': 2,
    'stage6': 5,
  };

  static Map stageMapping = {
    'stage1': 'forest',
    'stage2': 'desert',
    'stage3': 'mine',
    'stage4': 'sea',
    'stage5': 'dia',
    'stage6': 'cube',
  };

  static Map stageMappingKorean = {
    'stage1': '과일의 숲',
    'stage2': '사막의 중심',
    'stage3': '끝없는 광산',
    'stage4': '꿈꾸는 바다',
    'stage5': '다이아 궁전',
    'stage6': '큐브',
  };

  static Map<String, String> stageNameMappingKorean = {
    'forest': '과일의 숲',
    'desert': '사막의 중심',
    'mine': '끝없는 광산',
    'sea': '꿈꾸는 바다',
    'dia': '다이아 궁전',
    'cube': '큐브',
  };

  static Map<String, String> stageNameMappingEnglish = {
    'forest': 'Forest',
    'desert': 'Desert',
    'mine': 'Mine',
    'sea': 'Sea',
    'dia': 'Palace',
    'cube': 'Cube',
  };


  //todo 보상 이름
  static Map prizeMappingKorean = {
    'forest': '사과',
    'desert': '사막큐브',
    'mine': '광물',
    'sea': '소라',
    'dia': '다이아',
    'cube': '큐브',
  };


  static Map stageColor = {
    'forest': const Color(0xff6ca672),
    'desert': const Color(0xffd5a669),
    'mine': const Color(0xffbfbfbf),
    'sea': const Color(0xff4087a2),
    'dia': const Color(0xffd3b36d),
  };


  static int getMyRank(int rankPoint){
    int result=0;
    if(0<=rankPoint && rankPoint <=99){
      result=1;
    }else if(100<=rankPoint && rankPoint <=499){
      result=2;
    }else if(500<=rankPoint && rankPoint <=999){
      result=3;
    }else if(1000<=rankPoint && rankPoint <=1499){
      result=4;
    }else if(1500<=rankPoint && rankPoint <=1999){
      result=5;
    }else{
      result=6;
    }
    return result;
  }
}

class Setting {
  Setting();

  bool _backgroundSound = true;
  bool _soundEffect = false;
  bool _vibrate = false;
  bool _lowPower = false;
  bool _lightingEffect = false;
  bool _highResolution = false;
  bool _push = false;
  bool _sms = false;
  bool _email = false;

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
  bool get push => _push;

  // ignore: unnecessary_getters_setters
  bool get sms => _sms;

  // ignore: unnecessary_getters_setters
  bool get email => _email;

  // ignore: unnecessary_getters_setters
  set backgroundSound(bool b) => _backgroundSound = b;

  // ignore: unnecessary_getters_setters
  set soundEffect(bool b) => _soundEffect = b;

  // ignore: unnecessary_getters_setters
  set vibrate(bool b) => _vibrate = b;

  // ignore: unnecessary_getters_setters
  set lowPower(bool b) => _lowPower = b;

  // ignore: unnecessary_getters_setters
  set lightingEffect(bool b) => _lightingEffect = b;

  // ignore: unnecessary_getters_setters
  set highResolution(bool b) => _highResolution = b;

  // ignore: unnecessary_getters_setters
  set push(bool b) => _push = b;

  // ignore: unnecessary_getters_setters
  set sms(bool b) => _sms = b;

  // ignore: unnecessary_getters_setters
  set email(bool b) => _email = b;
}





String makeFilename(String filename){
  String lang = AppConfig.lang;
  if(lang=='kor'){
    return filename;
  }else if(lang=='en'){
    return filename.split('.')[0]+'_en.'+filename.split('.')[1];
  }else{
    return filename;
  }
}














