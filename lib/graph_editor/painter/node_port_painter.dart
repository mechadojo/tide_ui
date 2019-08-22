import 'package:flutter_web/material.dart';

import '../data/graph.dart';
import '../data/graph_node.dart';
import '../data/node_port.dart';
import '../fonts/vector_font.dart';

class NodePortPainter {
  NodePort port;

  double scale;

  Paint get borderPaint =>
      port.hovered ? Graph.PortHoverBorder : Graph.PortBorder;

  Paint get fillPaint => port.hovered ? Graph.PortHoverColor : Graph.PortColor;
  VectorFont get font => Graph.font;

  void drawValue(Canvas canvas, NodePort port) {
    var cx = port.pos.dx - Graph.DefaultPortSize / 2 - Graph.PortValueLeader;
    var cy = port.pos.dy;

    var label = port.value;
    var rect = Graph.font.limits(label, Offset.zero, Graph.PortValueLabelSize);

    var path = Path();
    path.moveTo(cx, cy);

    cy += Graph.PortValueHeight / 2;
    cx -= Graph.PortValueFlagWidth;
    path.lineTo(cx, cy);
    cx -= Graph.PortValuePaddingRight;
    var right = cx;
    cx -= rect.width;
    var left = cx;
    cx -= Graph.PortValuePaddingLeft;
    path.lineTo(cx, cy);
    cy -= Graph.PortValueHeight;
    path.lineTo(cx, cy);
    cx = right + Graph.PortValuePaddingRight;
    path.lineTo(cx, cy);
    path.close();

    canvas.drawPath(path, Graph.PortValueLabelColor);
    canvas.drawPath(path, Graph.PortValueBorder);

    cx = port.pos.dx - Graph.DefaultPortSize / 2;
    cy = port.pos.dy;
    var p1 = Offset(cx, cy);
    var p2 = Offset(cx - Graph.PortValueLeader, cy);
    canvas.drawLine(p1, p2, Graph.PortValueBorder);
    Graph.font.paint(canvas, label, Offset((left + right) / 2, port.pos.dy),
        Graph.PortValueLabelSize,
        fill: Graph.NodeDarkColor, alignment: Alignment.center);
  }

  void paint(Canvas canvas, double scale, NodePort port) {
    this.port = port;

    this.scale = scale;

    var sz = Graph.DefaultPortSize / 2;
    if (port.hovered) sz *= 1.5;

    if (port.hasValue && (Graph.isZoomedIn(scale) || !port.hovered)) {
      drawValue(canvas, port);
    }

    canvas.drawCircle(port.pos, sz, fillPaint);
    canvas.drawCircle(port.pos, sz, borderPaint);

    if (Graph.ShowHitBox) canvas.drawRect(port.hitbox, Graph.redPen);

    if (Graph.isZoomedOut(scale) || port.node.isNotType(Action_Behavior)) {
      return;
    }

    var zoomedIn = Graph.isZoomedIn(scale);
    bool isBehavior = port.node.type == GraphNodeType.behavior;

    // Draw node label
    if (zoomedIn || port.hovered || isBehavior) {
      double offset = Graph.DefaultPortSize + 1;

      if (!zoomedIn && !isBehavior) offset = -offset;

      if (port.type == NodePortType.outport) {
        offset = -offset;
      }

      Alignment alignment =
          offset < 0 ? Alignment.centerRight : Alignment.centerLeft;

      var pt = port.pos.translate(offset, -0.5);
      var fsz = (zoomedIn || isBehavior) ? 6 : 10 / scale;

      if (!zoomedIn && !isBehavior) {
        var rect = font.limits(port.name, pt, fsz, alignment: alignment);
        var rrect = RRect.fromRectXY(rect.inflate(2), 4, 4);
        canvas.drawRRect(rrect, Graph.PortLabelShadow);
      }
      font.paint(canvas, port.name, pt, fsz,
          fill: Graph.blackPaint, alignment: alignment);
    }
  }
}
