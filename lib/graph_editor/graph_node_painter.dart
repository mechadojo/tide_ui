import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/node_port_painter.dart';
import 'package:tide_ui/graph_editor/fonts/SourceSansPro.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'data/graph_node.dart';

class GraphNodePainter {
  NodePortPainter portPainter = NodePortPainter();

  GraphNode node;
  Offset pos;
  double scale;
  var font = SourceSansProFont;

  Paint blackPaint = Paint()..color = Colors.black;
  Paint redPen = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  Paint get borderPaint => Graph.NodeBorder;
  Paint get shadowPaint =>
      node.hovered ? Graph.NodeHoverShadow : Graph.NodeShadow;
  Paint get fillPaint => node.hovered
      ? Graph.NodeHoverColor
      : darkNode ? Graph.NodeDarkColor : Graph.NodeColor;

  bool get darkNode =>
      node.type == GraphNodeType.inport || node.type == GraphNodeType.outport;

  bool get zoomedIn => scale > 2.0;
  bool get zoomedOut => scale < .5;

  void paint(
      Canvas canvas, Size size, Offset pos, double scale, GraphNode node) {
    this.node = node;
    this.pos = pos;
    this.scale = scale;

    var body = Rect.fromCenter(
      center: node.pos,
      width: node.size.width,
      height: node.size.height,
    );

    drawNameLabel(canvas);

    drawBody(canvas, body, shadowPaint);

    drawBody(canvas, body, fillPaint);
    drawBody(canvas, body, borderPaint);

    drawIcon(canvas);
    drawStatusIcons(canvas);
    drawMethodLabel(canvas);

    for (var port in node.inports) {
      portPainter.paint(canvas, size, pos, scale, port);
    }

    for (var port in node.outports) {
      portPainter.paint(canvas, size, pos, scale, port);
    }
  }

  void drawNameLabel(Canvas canvas) {
    if (zoomedOut) return;

    var label = node.hasTitle ? node.title : node.name;
    var pos = Offset(node.pos.dx, node.pos.dy + node.size.height / 2 + 4);

    var rect = font.limits(label, pos, 8, alignment: Alignment.topCenter);
    rect = Rect.fromCenter(
        center: rect.center, width: rect.width + 4, height: rect.height + 2);
    var rrect = RRect.fromRectXY(rect.inflate(2), 4, 4);

    canvas.drawRRect(rrect, Graph.NodeLabelShadow);

    font.paint(canvas, label, pos, 8,
        fill: blackPaint, alignment: Alignment.topCenter);
  }

  void drawMethodLabel(Canvas canvas) {
    if (!zoomedIn) return;

    if (node.isAnyType(Action_Behavior) && node.hasMethod) {
      var label = node.method;

      if (label.isNotEmpty) {
        var pt = Offset(node.pos.dx, node.pos.dy + node.size.height / 2 - 3);

        font.paint(canvas, label, pt, 5,
            width: node.size.width - Graph.NodeCornerRadius * 2 - 10,
            alignment: Alignment.bottomCenter,
            fill: blackPaint);
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
      if (node.logging) {
        if (zoomedIn) {
          cx = node.pos.dx + (node.debugging ? sz - 3 : 0);
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
      if (node.debugging) {
        if (zoomedIn) {
          cx = node.pos.dx - (node.logging ? sz - 3 : 0);
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

  void drawIcon(Canvas canvas) {
    var sz = Graph.DefaultNodeSize;
    var cx = node.pos.dx;
    var cy = node.pos.dy;

    if (node.isAnyType(Inport_Outport)) {
      sz /= 1.5;
    } else if (node.isAnyType(Action_Behavior)) {
      sz = sz / (zoomedIn ? 3 : zoomedOut ? 1.5 : 2);
    } else if (node.isAnyType(Trigger_Event)) {
      sz = node.size.height / 1.5;
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
      return Graph.NodeInportIconColor;
    }

    if (node.isAnyType(Outport_Event)) {
      return Graph.NodeOutportIconColor;
    }

    return zoomedIn ? Graph.NodeZoomedIconColor : Graph.NodeIconColor;
  }
}
