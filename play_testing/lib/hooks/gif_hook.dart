import 'package:flutter/cupertino.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

GifController useGifController({TickerProvider provider, int duration}) {
  return use(_GifController(
    provider: provider,
    duration: duration,
  ));
}

class _GifController extends Hook<GifController> {
  final TickerProvider provider;
  final int duration;

  const _GifController({this.provider, this.duration});

  @override
  _GifControllerState createState() => _GifControllerState();
}

class _GifControllerState extends HookState<GifController, _GifController> {
  GifController _gifController;

  @override
  GifController build(BuildContext context) => _gifController;

  @override
  void initHook() {
    super.initHook();
    _gifController = GifController(
        vsync: hook.provider, duration: Duration(milliseconds: hook.duration));
  }

  @override
  void dispose() {
    _gifController?.dispose();
    super.dispose();
  }
}
