import 'dart:io';

import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/widgets/etc/route_widget.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? defaultImageFilePath;
  final String? pressedImageFilePath;
  final Function? onPressed;
  final double? width;
  final double? height;
  final Widget? text;

  const CustomButton(
      { this.defaultImageFilePath,
       this.pressedImageFilePath,
       this.onPressed,
       this.width,
       this.height,
       this.text});

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  int _index = 0;
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IndexedStack(
          index: _index, // 0 or 1
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
                onTapDown: (TapDownDetails details) {
                  setState(() {
                    _index = 1;
                  });
                  effectMusicPlayer.playOnce('click_main_ui');
                },
                onPanEnd: (DragEndDetails details) {
                  setState(() {
                    _index = 0;
                  });
                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  }
                },
                onTap: () {
                  setState(() {
                    _index = 1;
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    setState(() {
                      _index = 0;
                    });
                    if (widget.onPressed != null) {
                      widget.onPressed!();
                    }
                  });
                },
                child: !widget.defaultImageFilePath!.contains('.gif') ? Image.file(
                  File(widget.defaultImageFilePath!),
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.contain,
                ): RoutWidget(
                  child: Image.file(
                    File(widget.defaultImageFilePath!),
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.contain,
                  ),
                )
            ),
            Image.file(
              File(widget.pressedImageFilePath!),
              width: widget.width,
              height: widget.height,
              fit: BoxFit.contain,
            )
          ],
        ),
        IgnorePointer(child: widget.text ?? const Text(''))
      ],
    );
  }
}

class CustomButtonAsset extends StatefulWidget {
  final String defaultImageFilePath;
  final String pressedImageFilePath;
  final Function onPressed;
  final double width;
  final double? height;
  final Widget text;

  const CustomButtonAsset(
      {required this.defaultImageFilePath,
      required this.pressedImageFilePath,
      required this.onPressed,
      required this.width,
       this.height,
      required this.text});

  @override
  _CustomButtonAssetState createState() => _CustomButtonAssetState();
}

class _CustomButtonAssetState extends State<CustomButtonAsset> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IndexedStack(
          index: _index, // 0 or 1
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
                onTapDown: (TapDownDetails details) {
                  setState(() {
                    _index = 1;
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  setState(() {
                    _index = 0;
                  });
                  if (widget.onPressed != null) {
                    widget.onPressed();
                  }
                },
                onTap: () {
                  setState(() {
                    _index = 1;
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    setState(() {
                      _index = 0;
                    });
                    if (widget.onPressed != null) {
                      widget.onPressed();
                    }
                  });
                },
                child: Image.asset(
                  widget.defaultImageFilePath,
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.contain,
                )),
            Image.asset(
              widget.pressedImageFilePath,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.contain,
            )
          ],
        ),
        IgnorePointer(child: widget.text)
      ],
    );
  }
}

class NavigationButton extends StatefulWidget {
  final String defaultImageFilePath;
  final String enableImageFilePath;
  final Function onPressed;
  final bool enable;
  final double width;
  final double height;

  const NavigationButton(
      {required this.width,
      required this.height,
      required this.defaultImageFilePath,
      required this.enableImageFilePath,
      required this.onPressed,
      required this.enable});

  @override
  _NavigationButtonState createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  int _index = 0; //0 -> disable 1-> enable

  @override
  Widget build(BuildContext context) {
    if (widget.enable) {
      _index = 1;
    } else {
      _index = 0;
    }

    return IndexedStack(
      index: _index, // 0 or 1
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed();
            }
            setState(() {
              _index = 1;
            });
          },
          child: Image.file(
            File(widget.defaultImageFilePath),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
          ),
        ),
        GestureDetector(
          child: Image.file(
            File(widget.enableImageFilePath),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
