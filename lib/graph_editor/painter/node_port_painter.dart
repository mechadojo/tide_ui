import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

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

  Paint getFlagPaint() {
    if (port.flag.hovered) return Graph.NodeHoverColor;

    if (port.hasValue) return Graph.PortValueLabelColor;
    if (port.hasTrigger) return Graph.PortTriggerLabelColor;
    if (port.hasLink) return Graph.PortLinkLabelColor;
    if (port.hasEvent) return Graph.PortEventLabelColor;

    return Graph.whitePaint;
  }

  String getFlagIcon() {
    if (port.hasValue) return "hashtag";
    if (port.hasTrigger) return "bolt";
    if (port.hasLink) return "link";
    if (port.hasEvent) return "bolt";
    return "";
  }

  void drawFlag(Canvas canvas, NodePort port) {
    var direction = port.type == NodePortType.inport ? -1.0 : 1.0;
    var label = port.flagLabel;

    if (port.pos != port.flag.pos ||
        direction != port.flag.direction ||
        label != port.flag.text) {
      port.flag.pos = port.pos;
      port.flag.direction = direction;
      port.flag.text = label;
      port.flag.update();
    }

    canvas.drawPath(port.flag.path, getFlagPaint());
    canvas.drawPath(port.flag.path, Graph.PortValueBorder);

    var p1 = port.flag.leader.first;
    var p2 = port.flag.leader.last;
    canvas.drawLine(p1, p2, Graph.PortValueBorder);

    Graph.font.paint(canvas, label, port.flag.textPos, Graph.PortValueLabelSize,
        fill: Graph.NodeDarkColor, alignment: Alignment.center);
    var icon = getFlagIcon();
    VectorIcons.paint(canvas, icon, port.flag.iconPos, Graph.PortValueIconSize,
        fill: Graph.NodeDarkColor);
  }

  void paint(Canvas canvas, double scale, NodePort port) {
    this.port = port;

    this.scale = scale;

    var sz = Graph.DefaultPortSize / 2;
    if (port.hovered) sz *= 1.5;

    if (port.showFlag && (Graph.isZoomedIn(scale) || !port.hovered)) {
      drawFlag(canvas, port);
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
