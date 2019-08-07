import 'package:flutter_web/material.dart';

import 'data/graph_node.dart';

class GraphNodePainter extends CustomPainter {
  GraphNode node;

  GraphNodePainter(this.node);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
