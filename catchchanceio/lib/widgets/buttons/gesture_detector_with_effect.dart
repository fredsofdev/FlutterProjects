import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:flutter/material.dart';

class GestureDetectorWithEffect extends StatelessWidget {
  final Widget child;
  final Function onTap;

  const GestureDetectorWithEffect({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
        effectMusicPlayer.playOnce('click_main_ui');
        onTap();
      },
      child: child,
    );
  }
}
