import 'dart:io';

import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

class GoGachaButton extends StatefulWidget {
  final Function onPressed;

  //todo constructor
  const GoGachaButton({required this.onPressed});

  @override
  _GoGachaButtonState createState() => _GoGachaButtonState();
}

class _GoGachaButtonState extends State<GoGachaButton>
    with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main/ui/';
  AnimationController? ringController;
  EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ringController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    ringController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    ringController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        effectMusicPlayer.playOnce('click_main_ui');
      },
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  File('${_imagePath}gc_light.png'),
                  width: 135,
                  fit: BoxFit.contain,
                ),
                ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.0).animate(ringController!),
                    child: Image.file(
                      File('${_imagePath}gc_ring.png'),
                      width: 142,
                      fit: BoxFit.contain,
                    )),
                Image.file(
                  File('${_imagePath}gc_btn.png'),
                  width: 135,
                  fit: BoxFit.contain,
                )
              ],
            ),
            Positioned(
                bottom: 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File('${_imagePath}gc_txtbox.png'),
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      '아이템 조합',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
