
import 'package:flutter/material.dart';
import 'dart:io';
import '../../rout_aware_state.dart';

class RoutWidget extends StatefulWidget {
  
  final Widget child;
  
  const RoutWidget({required this.child});
  @override
  _RoutWidgetState createState() => _RoutWidgetState();
}
class _RoutWidgetState extends RouteAwareState<RoutWidget> {
  
  
  bool isVisible = false;
  @override
  void onEnterScreen() async {
    // print('on enter chart screen');
    // set orientation to landscape
    setState(() {
      isVisible = true;
    });
  }
  @override
  void onLeaveScreen() async {
    // print('on leave chart screen');
    // set orientation back to portrait
    setState(() {
      isVisible = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: widget.child
    );
  }
}