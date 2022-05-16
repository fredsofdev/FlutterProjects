import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PressButtonImage extends HookWidget {
  final Image depressImg;
  final Image pressImg;
  final Alignment alignment;
  final Function press;
  final Function depress;

  const PressButtonImage(
      {required this.depressImg,
      required this.pressImg,
      required this.alignment,
      required this.press,
      required this.depress});

  @override
  Widget build(BuildContext context) {
    final index = useState(0);
    return Stack(
      alignment: alignment,
      children: [
        IgnorePointer(
          child: IndexedStack(
            index: index.value,
            children: [
              pressImg,
              depressImg,
            ],
          ),
        ),
        GestureDetector(
          // onPanCancel: (){depress(); index.value = 0;},
          onPanDown: (d) {
            final EffectMusicPlayer ef = EffectMusicPlayer();
            ef.playOnce('click_play');
            press();
            index.value = 1;
          },

          // onTapDown: (d){press(); index.value = 1;},
          // onTapUp: (d){
          //   print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&"+d.localPosition.toString());
          //   depress(); index.value = 0;},
          onPanEnd: (d) {
            depress();
            index.value = 0;
          },

          child: Container(
              padding: const EdgeInsets.all(23),
              color: Colors.transparent,
              child: const SizedBox()),
        ),
      ],
    );
  }
}
