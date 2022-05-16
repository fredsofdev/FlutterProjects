import 'package:flutter/material.dart';

//todo clipper...
class ProfileImageClipper extends CustomClipper<Path> {
  final double width;
  final double distance;

  ProfileImageClipper({required this.width, required this.distance});

  @override
  Path getClip(Size size) {
    final height = width / 1.12834226;
    final smallWidth = (width - distance) / 2;
    final path = Path()
      ..moveTo(0.0, height / 2)
      ..lineTo(smallWidth, 0.0)
      ..lineTo(smallWidth + distance, 0.0)
      ..lineTo(width, height / 2)
      ..lineTo(smallWidth + distance, height)
      ..lineTo(smallWidth, height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(ProfileImageClipper oldClipper) => false;
}

class Chamfer14Clipper extends CustomClipper<Path> {
  int ratio = 5;

  Chamfer14Clipper({required this.ratio}) {
    ratio = ratio;
  }

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final path = Path();
    path.moveTo(w / ratio, 0.0);
    path.lineTo(w, 0.0);
    path.lineTo(w, h * ((ratio - 1) / ratio));
    path.lineTo(w * ((ratio - 1) / ratio), h);
    path.lineTo(0.0, h);
    path.lineTo(0.0, h / ratio);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(Chamfer14Clipper oldClipper) => false;
}

class OnlyRightFullChamferClipper extends CustomClipper<Path> {
  double ratio;

  OnlyRightFullChamferClipper({this.ratio = 5});

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(w * ((ratio - 1) / ratio), 0.0);
    path.lineTo(w, h);
    path.lineTo(0.0, h);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(OnlyRightFullChamferClipper oldClipper) => false;
}

class EQTriangle1Clipper extends CustomClipper<Path> {
  double trSize;

  EQTriangle1Clipper({required this.trSize});

  @override
  Path getClip(Size size) {
    final double w = trSize;
    final double h = trSize;
    final path = Path();
    path.moveTo(w, 0.0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(EQTriangle1Clipper oldClipper) => false;
}

class EQTriangle2Clipper extends CustomClipper<Path> {
  double trSize;

  EQTriangle2Clipper({required this.trSize});

  @override
  Path getClip(Size size) {
    final double w = trSize;
    final double h = trSize;
    final path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(EQTriangle2Clipper oldClipper) => false;
}

class EQTriangle3Clipper extends CustomClipper<Path> {
  double trSize;

  EQTriangle3Clipper({required this.trSize});

  @override
  Path getClip(Size size) {
    final double w = trSize;
    final double h = trSize;
    final path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(w, 0.0);
    path.lineTo(w, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(EQTriangle3Clipper oldClipper) => false;
}

class EQTriangle4Clipper extends CustomClipper<Path> {
  double trSize;

  EQTriangle4Clipper({required this.trSize});

  @override
  Path getClip(Size size) {
    final double w = trSize;
    final double h = trSize;
    final path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(w, 0.0);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(EQTriangle4Clipper oldClipper) => false;
}

class IsoscelesTriangleClipper extends CustomClipper<Path> {
  double trSize;

  IsoscelesTriangleClipper({required this.trSize});

  @override
  Path getClip(Size size) {
    final double w = trSize;
    final double h = trSize / 2;
    final path = Path();
    path.moveTo(w / 2, 0.0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(IsoscelesTriangleClipper oldClipper) => false;
}
