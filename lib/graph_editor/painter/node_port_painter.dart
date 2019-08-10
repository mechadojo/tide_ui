import 'package:flutter_web/material.dart';

import '../data/graph.dart';
import '../data/graph_node.dart';
import '../data/node_port.dart';
import '../fonts/vector_font.dart';

class NodePortPainter {
  NodePort port;
  Offset pos;
  double scale;

  Paint get borderPaint =>
      port.hovered ? Graph.PortHoverBorder : Graph.PortBorder;

  Paint get fillPaint => port.hovered ? Graph.PortHoverColor : Graph.PortColor;
  VectorFont get font => Graph.font;

  void paint(
      Canvas canvas, Size size, Offset pos, double scale, NodePort port) {
    this.port = port;
    this.pos = pos;
    this.scale = scale;

    var sz = Graph.DefaultPortSize / 2;
    if (port.hovered) sz *= 1.5;

    canvas.drawCircle(port.pos, sz, fillPaint);
    canvas.drawCircle(port.pos, sz, borderPaint);

    if (Graph.ShowHitBox) canvas.drawRect(port.hitbox, Graph.redPen);

    if (Graph.isZoomedOut(scale) || port.node.isNotType(Action_Behavior)) {
      return;
    }

    var zoomedIn = Graph.isZoomedIn(scale);

    // Draw node label
    if (zoomedIn || port.hovered) {
      double offset = Graph.DefaultPortSize + 1;

      if (!zoomedIn) offset = -offset;

      if (port.type == NodePortType.outport) {
        offset = -offset;
      }

      Alignment alignment =
          offset < 0 ? Alignment.centerRight : Alignment.centerLeft;

      var pt = port.pos.translate(offset, -0.5);
      var fsz = zoomedIn ? 6 : 10 / scale;

      if (!zoomedIn) {
        var rect = font.limits(port.name, pt, fsz, alignment: alignment);
        var rrect = RRect.fromRectXY(rect.inflate(2), 4, 4);
        canvas.drawRRect(rrect, Graph.PortLabelShadow);
      }
      font.paint(canvas, port.name, pt, fsz,
          fill: Graph.blackPaint, alignment: alignment);
    }
  }
}
