import 'package:flutter/material.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import '../data/graph.dart';
import '../data/graph_node.dart';
import '../data/node_port.dart';
import '../fonts/vector_font.dart';

class NodePortPainter {
  static List<Paint> groupPaints = [
    Paint()..color = Colors.green[100],
    Paint()..color = Colors.red[100],
    Paint()..color = Colors.purple[100],
    Paint()..color = Colors.yellow[100],
    Paint()..color = Colors.orange[100],
  ];

  NodePort port;

  double scale;

  Paint get borderPaint =>
      port.hovered ? Graph.PortHoverBorder : Graph.PortBorder;

  Paint get fillPaint =>
      port.hovered ? Graph.PortHoverColor : getSyncGroupPaint();

  Paint getSyncGroupPaint() {
    if (!port.hasSyncGroup) return Graph.PortColor;
    return groupPaints[port.syncGroupIndex % groupPaints.length];
  }

  VectorFont get font => Graph.font;

  Paint getFlagPaint() {
    if (port.flag.hovered) return Graph.NodeHoverColor;

    if (port.hasValue) return Graph.PortValueLabelColor;
    if (port.hasTrigger) return Graph.PortTriggerLabelColor;
    if (port.hasLink) return Graph.PortLinkLabelColor;
    if (port.hasEvent) return Graph.PortEventLabelColor;

    if (port.hasFilter) {
      return port.filter.startsWith("~")
          ? port.node.props.contains(port.filter.substring(1))
              ? Graph.PortTriggerLabelColor
              : Graph.PortErrorLabelColor
          : Graph.PortValueLabelColor;
    }

    return Graph.whitePaint;
  }

  String getFlagIcon() {
    if (port.hasValue) return "hashtag";
    if (port.hasTrigger) return "bolt";
    if (port.hasLink) return "link";
    if (port.hasEvent) return "bolt";
    return "";
  }

  void drawFilterFlag(Canvas canvas, NodePort port) {
    var direction = port.type == NodePortType.inport ? 1.0 : -1.0;
    var label = port.filter;

    drawPortFlag(canvas, port.filterFlag, port.pos, direction, label);
  }

  void drawPortFlag(
      Canvas canvas, PortFlag flag, Offset pos, double direction, String text,
      {String icon}) {
    if (pos != flag.pos || direction != flag.direction || text != flag.text) {
      flag.pos = port.pos;
      flag.direction = direction;
      flag.text = text;
      flag.update();
    }

    canvas.drawPath(flag.path, getFlagPaint());
    canvas.drawPath(flag.path, Graph.PortValueBorder);

    var p1 = flag.leader.first;
    var p2 = flag.leader.last;
    canvas.drawLine(p1, p2, Graph.PortValueBorder);

    Graph.font.paint(canvas, flag.text, flag.textPos, Graph.PortValueLabelSize,
        fill: Graph.NodeDarkColor, alignment: Alignment.center);

    if (icon != null) {
      VectorIcons.paint(canvas, icon, flag.iconPos, Graph.PortValueIconSize,
          fill: Graph.NodeDarkColor);
    }
  }

  void drawFlag(Canvas canvas, NodePort port) {
    var direction = port.type == NodePortType.inport ? -1.0 : 1.0;
    var label = port.flagLabel;

    drawPortFlag(canvas, port.flag, port.pos, direction, label,
        icon: getFlagIcon());
  }

  void paint(Canvas canvas, double scale, NodePort port) {
    if (port.isLocal &&
        (port.isInport
            ? port.node.hideLocalInports
            : port.node.hideLocalOutports)) {
      return;
    }

    this.port = port;

    this.scale = scale;

    var sz = Graph.DefaultPortSize / 2;
    if (port.hovered) sz *= 1.5;

    if (port.showFlag && (Graph.isZoomedIn(scale) || !port.hovered)) {
      drawFlag(canvas, port);
    }

    if (port.hasFilter) {
      drawFilterFlag(canvas, port);
    }

    if (port.isBlocking) {
      var rect = Rect.fromCircle(center: port.pos, radius: sz);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    } else if (port.isDefault) {
      sz *= 1.125;
      var path = Path();
      path.moveTo(port.pos.dx, port.pos.dy - sz);
      path.lineTo(port.pos.dx + sz, port.pos.dy);
      path.lineTo(port.pos.dx, port.pos.dy + sz);
      path.lineTo(port.pos.dx - sz, port.pos.dy);
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    } else {
      canvas.drawCircle(port.pos, sz, fillPaint);
      canvas.drawCircle(port.pos, sz, borderPaint);
    }

    if (port.isQueuing && !Graph.isZoomedOut(scale)) {
      VectorIcons.paint(canvas, "plus", port.pos, 5, fill: Graph.PortIconColor);
    }

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

      var width = port.node.size.width / 2;

      if (!zoomedIn && !isBehavior) {
        width = double.infinity;
        var rect =
            font.limits(port.name, pt, fsz, alignment: alignment, width: width);
        var rrect = RRect.fromRectXY(rect.inflate(2), 4, 4);
        canvas.drawRRect(rrect, Graph.PortLabelShadow);
      }
      font.paint(canvas, port.name, pt, fsz,
          fill: Graph.blackPaint, alignment: alignment, width: width);
    }
  }
}
