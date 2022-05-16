import 'dart:io';

import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController useVideoController({
  required String videoUrl,

}) =>
    use(_VideoController(videoUrl: videoUrl));

class _VideoController extends Hook<VideoPlayerController> {
  final String videoUrl;

  const _VideoController({required this.videoUrl});

  @override
  _VideoControllerState createState() => _VideoControllerState();
}

class _VideoControllerState
    extends HookState<VideoPlayerController, _VideoController> {
  VideoPlayerController? _controller;

  @override
  VideoPlayerController build(BuildContext context) => _controller!;

  @override
  void initHook() {
    super.initHook();
    _controller = VideoPlayerController.file(
        File('${AppConfig.appDocDirectory!.path}${hook.videoUrl}'));
    _controller!.setLooping(true);
    _controller!.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
