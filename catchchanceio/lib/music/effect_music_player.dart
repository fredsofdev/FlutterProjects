import 'package:audioplayers/audioplayers.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

class EffectMusicPlayer with WidgetsBindingObserver {
  AudioPlayer? player;
  String? _path;

  final double maxVolume = 0.9;
  final double minVolume = 0.0;

  Map<String, String> effectPath = {
    'click_ingame':
        '${AppConfig.appDocDirectory!.path}/osgame/music/effect/click_ingame.mp3',
    'click_main_ui':
        '${AppConfig.appDocDirectory!.path}/osgame/music/effect/click_main_ui.mp3',
    'slide_stage':
        '${AppConfig.appDocDirectory!.path}/osgame/music/effect/slide_stage.mp3',
    'crane_sound':
        '${AppConfig.appDocDirectory!.path}/osgame/music/effect/crane_sound.mp3',
    'click_play':
        '${AppConfig.appDocDirectory!.path}/osgame/music/effect/click_play.mp3',
  };

  EffectMusicPlayer._internal() {
    player = AudioPlayer();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && AppConfig.setting.soundEffect) {
      player!.resume();
    } else {
      player!.pause();
    }
  }

  factory EffectMusicPlayer() => instance;

  static final EffectMusicPlayer instance = EffectMusicPlayer._internal();

  Future playOnce(String musicName) async {
    _path = effectPath[musicName];
    player?.stop();

    if (AppConfig.setting.soundEffect) {
      await player!.play(
        _path!,
        isLocal: true,
      );
    }
  }

  void stopLoop() {
    player?.stop();
  }

  void pauseLoop() {
    player?.pause();
  }

  void resumeLoop() {
    player?.resume();
  }

  void mute() {
    player?.stop();
  }

  void unMute() async {
    if (AppConfig.setting.soundEffect) {
      await player!.play(
        _path!,
        isLocal: true,
      );
    }
  }
}
