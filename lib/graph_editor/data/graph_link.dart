import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'graph_node.dart';
import 'graph_state.dart';
import 'node_port.dart';

class GraphLink extends GraphObject {
  static GraphLink none = GraphLink();

  NodePort outPort = NodePort.none;
  NodePort inPort = NodePort.none;
  int group = GraphNode.nodeRandom.nextInt(Graph.MaxGroupNumber);

  Path path;
  List<Path> arrows = [];

  List<Offset> hitPath = [];
  Offset pathStart;
  Offset pathEnd;
  List<Offset> pathControl = [];
  TideChartLink last;

  bool get changed => outPort.pos != pathStart || inPort.pos != pathEnd;

  GraphLink();
  GraphLink.link(NodePort outPort, NodePort inPort) {
    this.outPort = outPort;
    this.inPort = inPort;
  }

  TideChartLink pack() {
    TideChartLink result = TideChartLink();
    result.outNode = outPort.node.name;
    result.outPort = outPort.name;
    result.inNode = inPort.node.name;
    result.inPort = inPort.name;
    result.group = group;
    return result;
  }

  static GraphLink unpack(TideChartLink packed, GetNodeByName lookup) {
    return GraphLink()
      ..outPort = NodePort.unpackByName(
          packed.outNode, packed.outPort, "outport", lookup)
      ..inPort =
          NodePort.unpackByName(packed.inNode, packed.inPort, "inport", lookup)
      ..group = packed.group;
  }

  bool equalTo(GraphLink other) {
    if (outPort.equalTo(other.outPort)) return false;
    if (inPort.equalTo(other.inPort)) return false;
    return true;
  }

  void update() {
    pathStart = outPort.pos;
    pathEnd = inPort.pos;
    pathControl = getControlPoints(pathStart, pathEnd);

    path = getPath(pathStart, pathEnd, pathControl);
    arrows = [getArrowPath(.5, pathStart, pathEnd, pathControl)];

    hitPath.clear();

    var top = min(pathStart.dy, pathEnd.dy);
    var left = min(pathStart.dx, pathEnd.dx);
    var bottom = max(pathStart.dy, pathEnd.dy);
    var right = max(pathStart.dx, pathEnd.dx);

    int steps = Graph.LinkPathSteps;
    var dt = 1.0 / steps;
    var t = 0.0;
    for (var i = 0; i <= steps; i++) {
      if (i == 0) {
        hitPath.add(pathStart);
      } else {
        if (i == steps) {
          hitPath.add(pathEnd);
        } else {
          var pt = getPointOnBezierCurve(t, pathStart, pathEnd, pathControl);
          hitPath.add(pt);
          if (pt.dx < left) left = pt.dx;
          if (pt.dy < top) top = pt.dy;
          if (pt.dx > right) right = pt.dx;
          if (pt.dy > bottom) bottom = pt.dy;
        }
      }
      t += dt;
    }

    hitbox =
        Rect.fromLTRB(left, top, right, bottom).inflate(Graph.LinkPathWidth);
    pos = hitbox.center;
    size = hitbox.size;
  }

  @override
  String toString() {
    return "$outPort -> $inPort";
  }

  @override
  bool isHovered(Offset pt) {
    //print("Check link hover @$pt");
    if (!hitbox.contains(pt)) return false;
    if (hitPath.length < 2) return false;

    double delta = Graph.LinkPathHitWidth;
    double hitSize = delta / 2;

    var last = hitPath[0];
    for (int i = 1; i < hitPath.length; i++) {
      var next = hitPath[i];
      double left = min(next.dx, last.dx) - delta;
      double right = max(next.dx, last.dx) + delta;
      double top = min(next.dy, last.dy) - delta;
      double bottom = max(next.dy, last.dy) + delta;

      if (pt.dx >= left && pt.dx <= right && pt.dy >= top && pt.dy <= bottom) {
        if (distanceToLine(pt, last, next) < hitSize) {
          return true;
        }
      }

      last = next;
    }

    return false;
  }

  //  ************************************************************
  //
  //              Static Path and Arrow functions
  //
  //  ***********************************************************

  static Path getArrowPath(
      double t, Offset p1, Offset p2, List<Offset> control) {
    Path result = Path();

    Offset c = getPointOnBezierCurve(t, p1, p2, control);

    double epsilon = Graph.LinkArrowEpsilon;
    Offset pt0 = getPointOnBezierCurve(t + epsilon, p1, p2, control);
    Offset pt1 = getPointOnBezierCurve(t - epsilon, p1, p2, control);

    double m = 1 * (pt1.dy - pt0.dy) / (pt1.dx - pt0.dx);
    double b = c.dy - (m * c.dx);

    double arrowLength = Graph.LinkArrowSize;
    if (pt1.dx > pt0.dx) {
      arrowLength *= -1;
    }

    var center = findPointOnLine(c.dx, c.dy, m, b, -1.0 * arrowLength / 2);
    var pts = orthoToLine(center.dx, center.dy, m, arrowLength * 0.9);
    // For m === 0, figure out if arrow should be straight up or down
    double flip = p1.dy > pt0.dy ? -1 : 1;

    var tip = findPointOnLine(center.dx, center.dy, m, b, arrowLength, flip);
    pts.add(tip);

    result.moveTo(pts[0].dx, pts[0].dy);
    result.lineTo(pts[1].dx, pts[1].dy);
    result.lineTo(pts[2].dx, pts[2].dy);
    result.close();

    return result;
  }

  static Iterable<Path> getArrows(
      Iterable<double> pts, Offset p1, Offset p2, List<Offset> control) sync* {
    yield* pts.map((pt) => getArrowPath(pt, p1, p2, control));
  }

  static List<Offset> getControlPoints(Offset p1, Offset p2) {
    double x0 = p1.dx;
    double y0 = p1.dy;
    double x1 = p2.dx;
    double y1 = p2.dy;

    double cx0 = (x0 + x1) / 2;
    double cy0 = y0;
    double cx1 = cx0;
    double cy1 = y1;

    if (x1 - 5 < x0) {
      var size = Graph.DefaultNodeSize;

      var curve = (x0 - x1) * 100 / 200;

      if ((y1 - y0).abs() < size) {
        cx0 = x0 + curve;
        cy0 = y0 - curve;
        cx1 = x1 - curve;
        cy1 = y1 - curve;
      } else {
        cx0 = x0 + curve;
        cy0 = y0 + (y1 > y0 ? curve : -curve);
        cx1 = x1 - curve;
        cy1 = y1 + (y1 > y0 ? -curve : curve);
      }
    }

    List<Offset> result = [Offset(cx0, cy0), Offset(cx1, cy1)];

    return result;
  }

  static Path getPath(Offset p1, Offset p2, List<Offset> control) {
    var result = Path();
    result.moveTo(p1.dx, p1.dy);

    if (control.isEmpty) {
      result.lineTo(p2.dx, p2.dy);
    } else if (control.length == 1) {
      var c1 = control[0];
      result.quadraticBezierTo(c1.dx, c1.dy, p2.dx, p2.dy);
    } else {
      var c1 = control[0];
      var c2 = control[1];
      result.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return result;
  }

  static Offset getPointOnBezierCurve(
      double t, Offset p0, Offset p3, List<Offset> control) {
    Offset p1 = control[0];
    Offset p2 = control[1];

    double u = 1.0 - t;
    double t2 = t * t;
    double u2 = u * u;
    double u3 = u2 * u;
    double t3 = t2 * t;

    double dx = (u3) * p0.dx +
        (3.0 * u2 * t) * p1.dx +
        (3.0 * u * t2) * p2.dx +
        (t3) * p3.dx;

    double dy = (u3) * p0.dy +
        (3.0 * u2 * t) * p1.dy +
        (3.0 * u * t2) * p2.dy +
        (t3) * p3.dy;

    return Offset(dx, dy);
  }

  // https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line

  static double distanceToLine(Offset pt, Offset l1, Offset l2) {
    double x0 = pt.dx;
    double y0 = pt.dy;
    double x1 = l1.dx;
    double y1 = l1.dy;
    double x2 = l2.dx;
    double y2 = l2.dy;

    double dx = x2 - x1;
    double dy = y2 - y1;
    double n = (dy * x0 - dx * y0 + x2 * y1 - y2 * x1).abs();
    double d = sqrt(dy * dy + x2 * x2);

    double result = n / d;
    return result;
  }

  static Offset findPointOnLine(
      double x, double y, double m, double b, double offset,
      [double flip = 0]) {
    double x1 = x + offset / sqrt(1 + m * m);
    double y1;
    if (m.abs() == double.infinity) {
      y1 = y + (flip == 0 ? 1 : flip) * offset;
    } else {
      y1 = (m * x1) + b;
    }

    return Offset(x1, y1);
  }

  static List<Offset> orthoToLine(double x, double y, double slope, double l) {
    double m = -1 / slope;
    double b = y - m * x;
    Offset p0 = findPointOnLine(x, y, m, b, l / 2, 0);
    Offset p1 = findPointOnLine(x, y, m, b, l / -2, 0);
    return [p0, p1];
  }
}
