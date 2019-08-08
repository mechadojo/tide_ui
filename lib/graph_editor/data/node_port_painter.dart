import 'package:flutter_web/material.dart';

import 'graph.dart';
import 'graph_node.dart';

class NodePortPainter {
  NodePort port;
  Offset pos;
  double scale;

  Paint get borderPaint =>
      port.hovered ? Graph.PortHoverBorder : Graph.PortBorder;

  Paint get fillPaint => port.hovered ? Graph.PortHoverColor : Graph.PortColor;

  void paint(
      Canvas canvas, Size size, Offset pos, double scale, NodePort port) {
    this.port = port;
    this.pos = pos;
    this.scale = scale;

    canvas.drawCircle(port.pos, Graph.DefaultPortSize / 2, fillPaint);
    canvas.drawCircle(port.pos, Graph.DefaultPortSize / 2, borderPaint);
  }
}
