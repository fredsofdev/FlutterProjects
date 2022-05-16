import 'package:audioplayers/audioplayers.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

//todo Background music singleton
class BackgroundMusicPlayer with WidgetsBindingObserver {
  AudioPlayer? player;
  AudioCache? cache;
  String? _path;
  final double maxVolume = 0.9;
  final double minVolume = 0.0;
  Map<String, String> bgmPath = {
    'a_exchange':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_exchange.mp3',
    'a_friend':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_friend.mp3',
    'a_rank': '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_rank.mp3',
    'a_inventory':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_inventory.mp3',
    'a_main': '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_main.mp3',
    'a_shop': '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_shop.mp3',
    'a_stage': '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/a_stage.mp3',
    'etc_fail':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/etc_fail.mp3',
    'etc_loading':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/etc_loading.mp3',
    'etc_success':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/etc_success.mp3',
    'in_game_desert':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_game_desert.mp3',
    'in_game_dia':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_game_dia.mp3',
    'in_game_forest':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_game_forest.mp3',
    'in_game_mine':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_game_mine.mp3',
    'in_game_sea':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_game_sea.mp3',
    'in_wait_desert':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_wait_desert.mp3',
    'in_wait_dia':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_wait_dia.mp3',
    'in_wait_forest':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_wait_forest.mp3',
    'in_wait_mine':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_wait_mine.mp3',
    'in_wait_sea':
        '${AppConfig.appDocDirectory!.path}/osgame/music/bgm/in_wait_sea.mp3',
    'splash_screen': 'res/music/a_splash_loading.mp3',
  };

  BackgroundMusicPlayer._internal() {
    player = AudioPlayer();
    cache = AudioCache();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        AppConfig.setting.backgroundSound) {
      player!.resume();
    } else {
      player!.pause();
    }
  }

  static final BackgroundMusicPlayer instance =
      BackgroundMusicPlayer._internal();

  factory BackgroundMusicPlayer() => instance;

  Future playLoop(String musicName, {String? stage}) async {
    if (musicName == 'roomlist') {
      _path =
          '${AppConfig.appDocDirectory!.path}${'/osgame/music/${AppConfig.stageMapping[stage]}.wma'}';
    } else {
      _path = bgmPath[musicName];
    }

    player?.stop();
    if (AppConfig.setting.backgroundSound) {
      player!.setReleaseMode(ReleaseMode.LOOP);
      await player!.play(
        _path!,
        isLocal: true,
      );
    }
  }

  Future playLoopCash(String musicName, {String? stage}) async {
    if (musicName == 'roomlist') {
      _path =
          '${AppConfig.appDocDirectory!.path}${'/osgame/music/${AppConfig.stageMapping[stage]}.wma'}';
    } else {
      _path = bgmPath[musicName];
    }

    player?.stop();
    if (AppConfig.setting.backgroundSound) {
      player!.setReleaseMode(ReleaseMode.LOOP);
      player = await cache!.play(
        _path!,
      );
    }
  }

  Future playCacheLoop(String filename) async {
    cache!.play(filename);
  }

  void stopLoop() {
    player?.stop();
  }

  void pauseLoop() {
    player?.pause();
  }

  void resumeLoop() {
    if (AppConfig.setting.backgroundSound) {
      player?.resume();
    }
  }

  void mute() {
    player?.stop();
  }

  void unMute() async {
    if (AppConfig.setting.backgroundSound) {
      player!.setReleaseMode(ReleaseMode.LOOP);
      await player!.play(
        _path!,
        isLocal: true,
      );
    }
  }
}
