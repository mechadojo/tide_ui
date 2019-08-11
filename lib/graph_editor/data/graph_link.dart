import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'graph_node.dart';
import 'graph_state.dart';
import 'node_port.dart';

class PackedGraphLink {
  PackedNodePort outPort;
  PackedNodePort inPort;
  int group = 0;

  PackedGraphLink.link(GraphLink link) {
    outPort = link.outPort.pack();
    inPort = link.inPort.pack();
    group = link.group;
  }

  GraphLink unpack(GetNodeByName lookup) {
    return GraphLink()
      ..outPort = outPort.unpack(lookup)
      ..inPort = inPort.unpack(lookup)
      ..group = group;
  }
}

class GraphLink extends GraphObject {
  static GraphLink none = GraphLink();

  NodePort outPort = NodePort.none;
  NodePort inPort = NodePort.none;
  int group = GraphNode.nodeRandom.nextInt(Graph.MaxGroupNumber);

  Path path;

  List<Offset> hitPath = [];
  double hitSize = 5;

  Offset pathStart;
  Offset pathEnd;
  List<Offset> pathControl = [];

  bool get changed => outPort.pos != pathStart || inPort.pos != pathEnd;

  GraphLink();
  GraphLink.link(NodePort fromPort, NodePort toPort) {
    this.outPort = fromPort;
    this.inPort = toPort;
  }

  PackedGraphLink pack() {
    return PackedGraphLink.link(this);
  }

  bool equalTo(GraphLink other) {
    if (outPort.equalTo(other.outPort)) return false;
    if (inPort.equalTo(other.inPort)) return false;
    return true;
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

  void update() {
    pathStart = outPort.pos;
    pathEnd = inPort.pos;
    pathControl = getControlPoints(pathStart, pathEnd);

    path = getPath(pathStart, pathEnd, pathControl);
  }

  @override
  String toString() {
    return "$outPort -> $inPort";
  }

  @override
  bool isHovered(Offset pt) {
    if (!hitbox.contains(pt)) return false;
    if (hitPath.length < 2) return false;

    var last = hitPath[0];
    for (int i = 1; i < hitPath.length; i++) {
      var next = hitPath[1];
      if (distanceToLine(pt, last, next) < hitSize) {
        return true;
      }
      last = next;
    }

    return false;
  }

  // https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line

  double distanceToLine(Offset pt, Offset l1, Offset l2) {
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

  // See http://en.wikipedia.org/wiki/File:Bezier_3_big.gif
  Offset findPointOnCurve(double p, double sx, double sy, double c1x,
      double c1y, double c2x, double c2y, double ex, double ey) {
    // p is percentage from 0 to 1
    double op = 1 - p;
    // 3 green points between 4 points that define curve
    double g1x = sx * p + c1x * op;
    double g1y = sy * p + c1y * op;
    double g2x = c1x * p + c2x * op;
    double g2y = c1y * p + c2y * op;
    double g3x = c2x * p + ex * op;
    double g3y = c2y * p + ey * op;
    // 2 blue points between green points
    double b1x = g1x * p + g2x * op;
    double b1y = g1y * p + g2y * op;
    double b2x = g2x * p + g3x * op;
    double b2y = g2y * p + g3y * op;
    // Point on the curve between blue points
    double x = b1x * p + b2x * op;
    double y = b1y * p + b2y * op;
    return Offset(x, y);
  }

  Offset findPointOnLine(
      double x, double y, double m, double b, double offset, double flip) {
    double x1 = x + offset / sqrt(1 + m * m);
    double y1;
    if (m.abs() == double.infinity) {
      y1 = y + (flip == 0 ? 1 : flip) * offset;
    } else {
      y1 = (m * x1) + b;
    }

    return Offset(x1, y1);
  }

  List<Offset> orthoToLine(double x, double y, double slope, double l) {
    double m = -1 / slope;
    double b = y - m * x;
    Offset p0 = findPointOnLine(x, y, m, b, l / 2, 0);
    Offset p1 = findPointOnLine(x, y, m, b, l / -2, 0);
    return [p0, p1];
  }
}
