import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class OSMarquee extends StatelessWidget {
  final String text;

  const OSMarquee({required this.text});

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
      blankSpace: 20.0,
      pauseAfterRound: const Duration(seconds: 1),
      startPadding: 10.0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
