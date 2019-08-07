import 'package:flutter_web/material.dart';

class Graph {
  static const double DefaultNodeSize = 75;

  static const double DefaultPortSpacing = 20;
  static const double DefaultPortPadding = 20;
  static const double DefaultPortOffset = 6;
  static const double DefaultPortSize = 10;

  static const double DefaultGamepadWidth = 250;
  static const double DefaultGamepadHeight = 100;

  static double NodeCornerRadius = 10;
  static Paint NodeColor = Paint()..color=Colors.white;
  static Paint NodeDarkColor = Paint()..color=Color(0xFF333333);
  static Paint NodeHoverColor = Paint()..color=Colors.cyan[50];
  static Paint NodeBorder = Paint()..color=Color(0xFF333333)..strokeWidth=2..style=PaintingStyle.stroke;
  static Paint NodeShadow = Paint()..color=Color(0x80FFFFFF)..strokeWidth=4..style=PaintingStyle.stroke;
  static Paint NodeHoverShadow = Paint()..color=Color(0x19000000)..strokeWidth=4..style=PaintingStyle.stroke;
  
}
