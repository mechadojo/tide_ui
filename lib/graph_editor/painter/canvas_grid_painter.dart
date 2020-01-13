import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';

class CanvasGridPainter {
  Offset pos;
  double scale;

  final majorStep = 100;
  final minorStep = 25;
  final ratio = 4;

  final backFill = Graph.CanvasColor;

  void paint(Canvas canvas, Size size, Offset pos, double scale) {
    this.pos = pos;
    this.scale = scale;

    final minorStroke = Paint()
      ..color = Color.fromARGB(200, 211, 211, 211)
      ..strokeWidth = scale < .5 ? scale : .5
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final originPaint = Paint()..color = Color.fromARGB(50, 211, 211, 211);

    final originStroke = Paint()
      ..color = Color.fromARGB(50, 211, 211, 211)
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final majorStroke = Paint()
      ..color = Color.fromARGB(240, 128, 128, 128)
      ..strokeWidth = scale < 1 ? scale : .75
      ..isAntiAlias = true;

    final originSize = scale < 1 ? 25.0 * scale : 25;

    // We are going to be drawing outside the clip rect
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPaint(backFill);

    var dx = pos.dx * scale;
    var dy = pos.dy * scale;

    var majorOffset = majorStep * scale;
    var minorOffset = minorStep * scale;

    var centerX = pos.dx * scale;
    var centerY = pos.dy * scale;

    var origin = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: originSize,
        height: originSize);

    canvas.drawArc(origin, -pi / 2, pi / 2, true, originPaint);
    canvas.drawArc(origin, pi / 2, pi / 2, true, originPaint);
    canvas.drawCircle(Offset(centerX, centerY), originSize / 2, originStroke);

    // Calculate the origin of the major grid in the top left corner of the canvas
    // This ensures we always draw a full grid, but draw as little as possible offscreen

    var stepsX = (dx / majorOffset).abs().ceil() * dx.sign;
    var stepsY = (dy / majorOffset).abs().ceil() * dy.sign;
    double originX = dx - stepsX * majorOffset;
    double originY = dy - stepsY * majorOffset;
    if (originY > 0) originY -= majorOffset;
    if (originX > 0) originX -= majorOffset;

    //print("Origin: $originX, $originY");

    double delta = originY;
    int idx = 0;
    while (delta < size.height) {
      if (idx % ratio > 0) {
        canvas.drawLine(
          Offset(0, delta),
          Offset(size.width, delta),
          minorStroke,
        );
      }
      delta += minorOffset;
      idx++;
    }

    delta = originX;
    idx = 0;
    while (delta < size.width) {
      if (idx % ratio > 0) {
        canvas.drawLine(
          Offset(delta, 0),
          Offset(delta, size.height),
          minorStroke,
        );
      }
      idx++;
      delta += minorOffset;
    }

    delta = originY;
    while (delta < size.height) {
      canvas.drawLine(
        Offset(0, delta),
        Offset(size.width, delta),
        majorStroke,
      );
      delta += majorOffset;
    }

    delta = originX;
    while (delta < size.width) {
      canvas.drawLine(
        Offset(delta, 0),
        Offset(delta, size.height),
        majorStroke,
      );
      delta += majorOffset;
    }

    //print("Repaint Canvas: ${size.width}, ${size.height}");
  }
}
