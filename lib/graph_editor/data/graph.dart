import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/fonts/SourceSansPro.dart';

class Graph {
  static const double DefaultNodeSize = 80;

  static const double DefaultPortSpacing = 20;
  static const double DefaultPortPadding = 20;
  static const double DefaultPortOffset = 6;
  static const double DefaultPortSize = 8;

  static const double DefaultGamepadWidth = 250;
  static const double DefaultGamepadHeight = 100;

  //
  // Canvas Styling

  static Paint CanvasColor = Paint()..color = Color(0xfffffff0);

  //
  //
  // Node Styling
  //
  static double NodeCornerRadius = 10;
  static Paint NodeColor = Paint()..color = Colors.white;
  static Paint NodeDarkColor = Paint()..color = Color(0xFF333333);
  static Paint NodeHoverColor = Paint()..color = Color(0xFFDFFEFE);
  static Paint NodeSelectedColor = Paint()..color = Color(0xFFDEFCE9);

  static Paint NodeBorder = Paint()
    ..color = Color(0xFF333333)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  static Paint NodeShadow = Paint()
    ..color = Color(0x80FFFFFF)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  static Paint NodeHoverShadow = Paint()
    ..color = Color(0x19000000)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  static Paint NodeIconColor = Paint()..color = Colors.black;
  static Paint NodeZoomedIconColor = Paint()
    ..color = Colors.black.withAlpha(64);
  static Paint NodeInportIconColor = Paint()..color = Color(0xFF2ecc40);
  static Paint NodeOutportIconColor = Paint()..color = Color(0xFFff851b);
  static Paint NodeHoverDarkIconColor = Paint()..color = Color(0xFFDFFEFE);

  static Paint NodeStatusIconColor = Paint()..color = Color(0xFF333333);
  static Paint NodeZoomedStatusIconColor = Paint()..color = Color(0x40333333);

  static Paint NodeLabelShadow = Paint()
    ..color = CanvasColor.color.withAlpha(200);

  //
  //  Port Styling
  //
  static Paint PortColor = Paint()..color = Colors.white;
  static Paint PortHoverColor = Paint()..color = Colors.cyan[50];
  static Paint PortBorder = Paint()
    ..color = Color(0xFF333333).withAlpha(128)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  static Paint PortHoverBorder = Paint()
    ..color = Color(0xFF333333).withAlpha(128)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  static Paint PortLabelShadow = Paint()
    ..color = CanvasColor.color.withAlpha(200);

  //
  //  Other Styles
  //
  static var font = SourceSansProFont;
  static Paint blackPaint = Paint()..color = Colors.black;
  static Paint redPen = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  static Paint SelectionBorder = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0;

  static double SelectDashSize = 10;

  //
  // Utlitity methods
  //
  static bool isZoomedIn(double scale) => scale > 2.0;
  static bool isZoomedOut(double scale) => scale < .5;
}
