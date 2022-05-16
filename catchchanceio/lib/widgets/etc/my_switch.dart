import 'package:catchchanceio/constants/color.dart';
import 'package:flutter/material.dart';

class MySwitch extends StatefulWidget {
  final bool value;
  final Function onChanged;

  const MySwitch({required this.onChanged, required this.value});

  @override
  _MySwitchState createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  late bool _value;

  @override
  void initState() {
    // TODO: implement initState
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      activeColor: appMainColor,
      activeTrackColor: const Color(0xffffe090),
      inactiveTrackColor: Colors.grey,
      onChanged: (value) {
        setState(() {
          _value = !_value;
          widget.onChanged(_value);
        });
      },
    );
  }
}
