import 'dart:math';

import 'package:flutter_web/material.dart';
import 'graph_node.dart';
import 'graph_state.dart';
import 'node_port.dart';

class PackedGraphLink {
  PackedNodePort fromPort;
  PackedNodePort toPort;

  PackedGraphLink.link(GraphLink link) {
    fromPort = link.fromPort.pack();
    toPort = link.toPort.pack();
  }

  GraphLink unpack(GetNodeByName lookup) {
    return GraphLink()
      ..fromPort = fromPort.unpack(lookup)
      ..toPort = toPort.unpack(lookup);
  }
}

class GraphLink extends GraphObject {
  static GraphLink none = GraphLink();

  NodePort fromPort = NodePort.none;
  NodePort toPort = NodePort.none;
  Path path;

  List<Offset> hitPath = [];
  double hitSize = 5;

  Offset pathStart;
  Offset pathEnd;

  GraphLink();
  GraphLink.link(NodePort fromPort, NodePort toPort) {
    this.fromPort = fromPort;
    this.toPort = toPort;
  }

  PackedGraphLink pack() {
    return PackedGraphLink.link(this);
  }

  bool equalTo(GraphLink other) {
    if (fromPort.equalTo(other.fromPort)) return false;
    if (toPort.equalTo(other.toPort)) return false;
    return true;
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
