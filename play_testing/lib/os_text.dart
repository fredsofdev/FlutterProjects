import 'package:flutter/material.dart';

class TextWithOutline extends StatefulWidget {
  final Color innerColor;
  final Color outerColor;
  final String text;
  final double fontSize;
  final double strokeWidth;

  const TextWithOutline(
      {@required this.text,
      @required this.fontSize,
      @required this.innerColor,
      @required this.outerColor,
      @required this.strokeWidth});

  @override
  _TextWithOutlineState createState() => _TextWithOutlineState();
}

class _TextWithOutlineState extends State<TextWithOutline> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'rk',
            fontSize: widget.fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = widget.strokeWidth
              ..color = widget.outerColor,
          ),
        ),
        // Solid text as fill.
        Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'rk',
            fontWeight: FontWeight.bold,
            fontSize: widget.fontSize,
            color: widget.innerColor,
          ),
        ),
      ],
    );
  }
}
