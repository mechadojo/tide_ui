import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import 'data/radial_menu_state.dart';
import 'painter/radial_menu_painter.dart';

class GraphMenu extends StatefulWidget {
  GraphMenu({Key key}) : super(key: key);

  _GraphMenuState createState() => _GraphMenuState();
}

class _GraphMenuState extends State<GraphMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RadialMenuState>(
      builder: (context, RadialMenuState menu, widget) {
        return CustomPaint(painter: GraphMenuPainter(menu), child: Container());
      },
    );
  }
}

class GraphMenuPainter extends CustomPainter {
  final RadialMenuState menu;
  final RadialMenuPainter menuPainter = RadialMenuPainter();

  GraphMenuPainter(this.menu);

  @override
  void paint(Canvas canvas, Size size) {
    menuPainter.paint(canvas, menu);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
