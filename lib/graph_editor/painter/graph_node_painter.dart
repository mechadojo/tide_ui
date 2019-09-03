import 'package:flutter_web/material.dart';

import '../data/graph.dart';
import '../data/graph_node.dart';
import '../fonts/vector_font.dart';
import '../icons/vector_icons.dart';

import 'node_port_painter.dart';

class GraphNodePainter {
  NodePortPainter portPainter = NodePortPainter();

  GraphNode node;
  double scale;

  Paint get borderPaint => Graph.NodeBorder;
  Paint get shadowPaint =>
      node.hovered ? Graph.NodeHoverShadow : Graph.NodeShadow;

  Paint get fillPaint {
    if (darkNode) return Graph.NodeDarkColor;
    if (node.selected) return Graph.NodeSelectedColor;
    if (node.hovered) return Graph.NodeHoverColor;
    return Graph.NodeColor;
  }

  bool get darkNode =>
      node.type == GraphNodeType.inport ||
      node.type == GraphNodeType.outport ||
      node.type == GraphNodeType.event ||
      node.type == GraphNodeType.trigger;

  bool get zoomedIn => Graph.isZoomedIn(scale);
  bool get zoomedOut => Graph.isZoomedOut(scale);
  VectorFont get font => Graph.font;

  void paint(Canvas canvas, double scale, GraphNode node) {
    this.node = node;
    this.scale = scale;

    var body = Rect.fromCenter(
      center: node.pos,
      width: node.size.width,
      height: node.size.height,
    );

    if (node.isNotType(Trigger_Event)) {
      drawNameLabel(canvas);
    }

    drawBody(canvas, body, shadowPaint);

    drawBody(canvas, body, fillPaint);
    drawBody(canvas, body, borderPaint);

    drawIcon(canvas);

    if (node.isAnyType(Trigger_Event)) {
      drawTriggerEventLabel(canvas);
    } else {
      drawStatusIcons(canvas);
      drawMethodLabel(canvas);
    }

    for (var port in node.inports) {
      portPainter.paint(canvas, scale, port);
    }

    for (var port in node.outports) {
      portPainter.paint(canvas, scale, port);
    }
  }

  void drawNameLabel(Canvas canvas) {
    if (zoomedOut) return;

    var label = node.hasTitle ? node.title : node.name;
    if (node.isAnyType(Inport_Outport)) {
      label = node.method;
    }

    var pos = Offset(node.pos.dx, node.pos.dy + node.size.height / 2 + 4);

    var rect = font.limits(label, pos, 8, alignment: Alignment.topCenter);
    rect = Rect.fromCenter(
        center: rect.center, width: rect.width + 4, height: rect.height + 2);
    var rrect = RRect.fromRectXY(rect, 4, 4);

    canvas.drawRRect(rrect, Graph.NodeLabelShadow);

    font.paint(canvas, label, pos, 8,
        fill: Graph.blackPaint, alignment: Alignment.topCenter);
  }

  void drawMethodLabel(Canvas canvas) {
    if (!zoomedIn) return;

    if (node.isAnyType(Action_Behavior) && node.hasMethod) {
      var label = node.method;

      if (label.isNotEmpty) {
        if (node.type == GraphNodeType.behavior) {
          label = "#$label";
        }

        var pt = Offset(node.pos.dx, node.pos.dy + node.size.height / 2 - 3);

        font.paint(canvas, label, pt, 5,
            width: node.size.width - Graph.NodeCornerRadius * 2 - 10,
            alignment: Alignment.bottomCenter,
            fill: Graph.blackPaint);
      }
    }
  }

  void drawStatusIcons(Canvas canvas) {
    if (zoomedOut) return;
    var paint =
        zoomedIn ? Graph.NodeZoomedStatusIconColor : Graph.NodeStatusIconColor;

    if (node.type == GraphNodeType.action) {
      var sz = 12.0;
      var cx = node.pos.dx + (node.size.width / 2 - sz);
      var cy = node.pos.dy + (node.size.height / 2 - sz);

      if (zoomedIn && node.hasMethod) cy -= 6;

      //
      // Logging Icon
      //
      if (node.isLogging) {
        if (zoomedIn) {
          cx = node.pos.dx + (node.isDebugging ? sz - 3 : 0);
        }

        VectorIcons.paint(
          canvas,
          "pencil-alt",
          Offset(cx, cy),
          sz,
          fill: paint,
        );
      }

      //
      // Debugging Icon
      //
      cx = node.pos.dx - (node.size.width / 2 - sz);
      if (node.isDebugging) {
        if (zoomedIn) {
          cx = node.pos.dx - (node.isLogging ? sz - 3 : 0);
        }

        VectorIcons.paint(
          canvas,
          "bug",
          Offset(cx, cy),
          sz,
          fill: paint,
        );
      }

      //
      // Delay Icon and Text
      //
      cy = node.pos.dy - (node.size.height / 2 - sz);
      cx = node.pos.dx + (node.size.width / 2 - sz);
      if (node.delay != 0) {
        if (zoomedIn) {
          cx = node.pos.dx;
        }

        VectorIcons.paint(
          canvas,
          "clock",
          Offset(cx, cy),
          sz,
          fill: paint,
        );
        if (scale >= .75) {
          var label = "${(node.delay * 100).round() / 100}";
          if (zoomedIn) {
            cy += sz / 2 + 1;
          } else {
            cx -= sz / 2 + 2;
          }

          font.paint(canvas, label, Offset(cx, cy), zoomedIn ? 6.0 : sz * .75,
              fill: paint,
              style: zoomedIn ? "Bold" : "Regular",
              alignment:
                  zoomedIn ? Alignment.topCenter : Alignment.centerRight);
        }
      }
    }
  }

  void drawBody(Canvas canvas, Rect rect, Paint paint) {
    if (zoomedOut) {
      canvas.drawRect(rect, paint);
    } else {
      var r = Graph.NodeCornerRadius;
      var rrect = RRect.fromRectXY(rect, r, r);
      canvas.drawRRect(rrect, paint);
    }
  }

  void drawTriggerEventLabel(Canvas canvas) {
    var right = node.type == GraphNodeType.trigger
        ? node.pos.dx + node.size.width / 2 - Graph.NodeTriggerPaddingRight
        : node.pos.dx + node.size.width / 2 - Graph.NodeTriggerPaddingLeft;
    var left = node.type == GraphNodeType.trigger
        ? node.pos.dx - node.size.width / 2 + Graph.NodeTriggerPaddingLeft
        : node.pos.dx - node.size.width / 2 + Graph.NodeTriggerPaddingRight;

    var cx = (right + left) / 2;
    var cy = node.pos.dy;
    var hh = (node.size.height - Graph.NodeTriggerPaddingVertical) / 2;
    var top = node.pos.dy - hh;
    var bottom = node.pos.dy + hh;
    var r = Rect.fromLTRB(left, top, right, bottom);
    var radius = Graph.NodeTriggerRadius;

    if (zoomedOut) {
      canvas.drawRect(r, Graph.NodeTriggerLabelColor);
    } else {
      var rr = RRect.fromRectXY(r, radius, radius);
      canvas.drawRRect(rr, Graph.NodeTriggerLabelColor);
    }
    var label = node.hasMethod ? node.method : "";

    Graph.font.paint(canvas, label, Offset(cx, cy), Graph.NodeTriggerLabelSize,
        fill: Graph.NodeDarkColor, alignment: Alignment.center);
  }

  void drawIcon(Canvas canvas) {
    var sz = Graph.DefaultNodeSize;
    var cx = node.pos.dx;
    var cy = node.pos.dy;

    if (node.isAnyType(Inport_Outport)) {
      sz /= 1.5;
    } else if (node.isAnyType(Action_Behavior)) {
      sz = sz / (zoomedIn ? 3 : zoomedOut ? 1.5 : 2);
    } else if (node.type == GraphNodeType.trigger) {
      sz = Graph.NodeTriggerIconSize;

      cx = node.pos.dx -
          node.size.width / 2 +
          sz / 2 +
          Graph.NodeTriggerIconPadding;
    } else if (node.type == GraphNodeType.event) {
      sz = Graph.NodeTriggerIconSize;

      cx = node.pos.dx +
          node.size.width / 2 -
          sz / 2 -
          Graph.NodeTriggerIconPadding;
    }

    VectorIcons.paint(canvas, node.icon, Offset(cx, cy), sz, fill: iconPaint);
  }

  Paint get iconPaint {
    if (node.hovered) {
      return darkNode
          ? Graph.NodeHoverDarkIconColor
          : zoomedIn ? Graph.NodeZoomedIconColor : Graph.NodeIconColor;
    }

    if (node.isAnyType(Inport_Trigger)) {
      return node.selected
          ? Graph.NodeHoverDarkIconColor
          : Graph.NodeInportIconColor;
    }

    if (node.isAnyType(Outport_Event)) {
      return node.selected
          ? Graph.NodeHoverDarkIconColor
          : Graph.NodeOutportIconColor;
    }

    return zoomedIn ? Graph.NodeZoomedIconColor : Graph.NodeIconColor;
  }
}
