import 'dart:math';

import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'graph.dart';
import 'node_port.dart';

const Inport_Outport = [GraphNodeType.inport, GraphNodeType.outport];
const Inport_Trigger = [GraphNodeType.inport, GraphNodeType.trigger];
const Outport_Event = [GraphNodeType.outport, GraphNodeType.event];
const Action_Behavior = [GraphNodeType.action, GraphNodeType.behavior];
const Trigger_Event = [GraphNodeType.trigger, GraphNodeType.event];

enum GraphNodeType {
  action,
  behavior,
  inport,
  outport,
  trigger,
  event,
  gamepad,
}

enum NodePortType { inport, outport }

class GraphObject with CanvasInteractive {}

class GraphNode extends GraphObject {
  GraphNodeType type = GraphNodeType.action;

  String name;
  String title;
  String icon;
  String method;
  String comment;

  bool logging = true;
  bool debugging = true;

  double delay = 0;

  List<NodePort> inports = [];
  List<NodePort> outports = [];
  int version = 0;

  bool get hasMethod => method != null && method.isNotEmpty;
  bool get hasTitle => title != null && title.isNotEmpty;

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

  bool isAnyType(List<GraphNodeType> types) {
    return types.any((x) => x == type);
  }

  bool isNotType(List<GraphNodeType> types) {
    return !isAnyType(types);
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

  @override
  bool moveTo(double dx, double dy) {
    var origin = this.pos;
    var moved = super.moveTo(dx, dy);
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
    py = pos.dy - ((outports.length - 1) * dy) / 2;
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
