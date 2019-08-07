import 'dart:math';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'graph.dart';

enum GraphNodeType {
  action,
  behavior,
  inport,
  outport,
  trigger,
  event,
  gamepad,
}

enum NodePortType { input, output }

class GraphObject with CanvasInteractive {}

class NodePort extends GraphObject {
  NodePortType type = NodePortType.input;
  GraphNode node;

  String name = "";
  int ordinal = 0;

  NodePort.input(this.node, this.ordinal, [this.name]) {
    type = NodePortType.input;
    if (name == null || name.isEmpty) {
      name = ordinal == 0 ? "in" : "in$ordinal";
    }
    if (ordinal == 0) ordinal = 1;
    size = Size(Graph.DefaultPortSize, Graph.DefaultPortSize);
  }

  NodePort.output(this.node, this.ordinal, [this.name]) {
    type = NodePortType.output;
    if (name == null || name.isEmpty) {
      name = ordinal == 0 ? "out" : "out$ordinal";
    }
    if (ordinal == 0) ordinal = 1;
    size = Size(Graph.DefaultPortSize, Graph.DefaultPortSize);
  }

  bool equalTo(NodePort other) {
    if (node.name != other.node.name) return false;
    if (type != other.type) return false;
    if (ordinal != other.ordinal) return false;
    if (name != other.name) return false;
    if (pos != other.pos) return false;

    return true;
  }
}

class GraphLink extends GraphObject {
  NodePort fromPort;
  NodePort toPort;
  Path path;

  List<Offset> hitPath = [];
  double hitSize = 5;

  Offset pathStart;
  Offset pathEnd;

  bool equalTo(GraphLink other) {
    if (fromPort.equalTo(other.fromPort)) return false;
    if (toPort.equalTo(other.toPort)) return false;
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

class GraphNode extends GraphObject {
  String name;
  String title;
  String icon;
  GraphNodeType type = GraphNodeType.action;
  List<NodePort> inports = [];
  List<NodePort> outports = [];
  int version = 0;

  static Random nodeRandom = Random();
  static randomName() {
    int number = (nodeRandom.nextInt(58786560)).floor() + 1679617;
    return number.toRadixString(36);
  }

  GraphNode.action(
      {this.name,
      this.title,
      this.icon,
      List<String> inputs,
      List<String> outputs}) {
    type = GraphNodeType.action;

    inputs = inputs ?? ["in"];
    outputs = outputs ?? ["out"];

    for (int i = 0; i < inputs.length; i++) {
      this.inports.add(NodePort.input(this, i + 1, inputs[i]));
    }

    for (int i = 0; i < outputs.length; i++) {
      this.outports.add(NodePort.output(this, i + 1, outputs[i]));
    }

    if (icon == null) {
      icon = VectorIcons.nameOf(nodeRandom.nextInt(VectorIcons.names.length));
    }

    if (name == null) {
      name = randomName();
    }

    resize();
  }

  bool equalTo(GraphNode other) {
    if (name != other.name) return false;
    if (version != other.version) return false;

    // Lets try to just have version be the only check
    //
    // if (title != other.title) return false;
    // if (icon != other.icon) return false;
    // if (type != other.type) return false;
    // if (pos != other.pos) return false;
    // if (size != other.size) return false;

    // if (inports.length != other.inports.length) return false;
    // if (outports.length != other.outports.length) return false;

    // for (int i = 0; i < inports.length; i++) {
    //   if (!inports[i].equalTo(other.inports[i])) return false;
    // }

    // for (int i = 0; i < outports.length; i++) {
    //   if (!outports[i].equalTo(other.outports[i])) return false;
    // }

    return true;
  }

  @override
  Iterable<CanvasInteractive> interactive() sync* {
    yield* inports;
    yield* outports;
    yield this;
  }

  bool move(Offset pos) {
    var origin = this.pos;
    var moved = moveTo(pos.dx, pos.dy);
    if (moved) {
      double dx = pos.dx - origin.dx;
      double dy = pos.dy - origin.dy;

      for (var port in inports) {
        port.moveBy(dx, dy);
      }

      for (var port in outports) {
        port.moveBy(dx, dy);
      }
    }

    if (moved) version++;
    return moved;
  }

  bool resize() {
    double width = size.width;
    double height = size.height;
    var ports = max(inports.length, outports.length);

    if (type == GraphNodeType.action || type == GraphNodeType.behavior) {
      height = max(Graph.DefaultNodeSize,
          ports * Graph.DefaultPortSpacing + Graph.DefaultPortPadding);
      width = type == GraphNodeType.action
          ? Graph.DefaultNodeSize
          : Graph.DefaultNodeSize * 2.5;
    } else if (type == GraphNodeType.trigger || type == GraphNodeType.action) {
      width = Graph.DefaultNodeSize * 2.5;
      height = Graph.DefaultNodeSize * .25;
    } else if (type == GraphNodeType.gamepad) {
      width = Graph.DefaultGamepadWidth;
      height = Graph.DefaultGamepadHeight;
    } else {
      width = Graph.DefaultNodeSize;
      height = Graph.DefaultNodeSize;
    }

    bool changed = false;

    //
    // update position of inports
    //
    var dy = (height - Graph.DefaultPortPadding) / inports.length;
    if (dy < Graph.DefaultPortSpacing) dy = Graph.DefaultPortSpacing;
    var px = pos.dx - (width / 2 + Graph.DefaultPortOffset);
    var py = pos.dy - ((inports.length - 1) * dy) / 2;

    for (var port in inports) {
      changed |= port.moveTo(px, py);
      py += dy;
    }

    //
    // update position of outports
    //
    dy = (height - Graph.DefaultPortPadding) / outports.length;
    if (dy < Graph.DefaultPortSpacing) dy = Graph.DefaultPortSpacing;
    py = pos.dy - ((inports.length - 1) * dy) / 2;
    px = pos.dx + (width / 2 + Graph.DefaultPortOffset);
    for (var port in outports) {
      changed |= port.moveTo(px, py);
      py += dy;
    }

    changed |= resizeTo(width, height);
    if (changed) version++;
    return changed;
  }
}
