import 'package:flutter/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

class VectorIconPainter extends CustomPainter {
  final double size;
  final String icon;
  Paint fill;
  Paint stroke;

  VectorIconPainter(this.icon, this.size, {this.fill, this.stroke}) {
    if (fill == null) {
      fill = Graph.blackPaint;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var pos = Offset(size.width / 2, size.height / 2);
    VectorIcons.paint(canvas, this.icon, pos, this.size,
        fill: this.fill, stroke: stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
