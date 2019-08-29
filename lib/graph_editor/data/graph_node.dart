import 'dart:math';
import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'graph.dart';
import 'graph_property_set.dart';
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
  unknown,
}

enum NodePortType {
  inport,
  outport,
  unknown,
}

class GraphObject with CanvasInteractive {
  static GraphObject none = GraphObject();
}

class GraphNode extends GraphObject {
  static GraphNode none = GraphNode()..name = "<none>";

  GraphNodeType type = GraphNodeType.action;

  String name;
  String title;
  String icon;
  String method;
  String library;
  String script;

  bool isLogging = false;
  bool isDebugging = false;
  bool isPaused = false;
  bool isDisabled = false;

  double delay = 0;

  List<NodePort> inports = [];
  List<NodePort> outports = [];

  bool get hideLocalInports => !showLocalInports;
  bool get hideLocalOutports => !showLocalOutports;

  bool get showLocalInports => settings.getBool("show_local_inports");
  bool get showLocalOutports => settings.getBool("show_local_outports");

  set showLocalInports(bool value) {
    if (value != showLocalInports) {
      settings.replace(GraphProperty.asBool("show_local_inports", value));
      resize();
    }
  }

  set showLocalOutports(bool value) {
    if (value != showLocalOutports) {
      settings.replace(GraphProperty.asBool("show_local_outports", value));
      resize();
    }
  }

  String get typeName {
    var result = type.toString().split(".").last;
    result = result[0].toUpperCase() + result.substring(1);
    return result;
  }

  int version = 0;

  TideChartNode last;

  GraphPropertySet props = GraphPropertySet();
  GraphPropertySet settings = GraphPropertySet();

  bool get hasLibrary => library != null && library.isNotEmpty;
  bool get hasMethod => method != null && method.isNotEmpty;
  bool get hasTitle => title != null && title.isNotEmpty;
  bool get hasScript => script != null && script.isNotEmpty;

  static Random nodeRandom = Random();
  static randomName() {
    int number = (nodeRandom.nextInt(58786560)).floor() + 1679617;
    return number.toRadixString(36);
  }

  NodePort get defaultInport {
    if (inports.isEmpty) return null;
    return inports.firstWhere((x) => x.isDefault, orElse: () => inports.first);
  }

  NodePort get defaultOutport {
    if (outports.isEmpty) return null;
    return outports.firstWhere((x) => x.isDefault,
        orElse: () => outports.first);
  }

  GraphNode();

  static GraphNode unpack(TideChartNode packed, GetNodeByName lookup) {
    var node = lookup(packed.name) as GraphNode;

    node.type = GraphNode.parseNodeType(packed.type);
    node.name = packed.name;
    node.title = packed.title;
    node.icon = packed.icon;
    node.method = packed.method;
    node.library = packed.library;
    node.script = packed.script;

    node.isLogging = packed.isLogging;
    node.isDebugging = packed.isDebugging;
    node.isPaused = packed.isPaused;
    node.isDisabled = packed.isDisabled;

    node.delay = packed.delay / 100.0;

    node.props = GraphPropertySet.unpack(packed.props);
    node.settings = GraphPropertySet.unpack(packed.settings);

    node.inports = [...packed.inports.map((x) => NodePort.unpack(x, lookup))];
    node.outports = [...packed.outports.map((x) => NodePort.unpack(x, lookup))];
    node.resize();
    node.moveTo(packed.posX.toDouble(), packed.posY.toDouble());

    return node;
  }

  GraphNode.outport([String method]) {
    name = GraphNode.randomName();
    this.method = method ?? name;
    icon = "sign-out-alt";
    type = GraphNodeType.outport;

    this.inports.add(NodePort.input(this, 1, "in"));
    resize();
  }

  GraphNode.event([String method]) {
    name = GraphNode.randomName();
    this.method = method ?? name;
    icon = "bolt";
    type = GraphNodeType.event;

    this.inports.add(NodePort.input(this, 1, "in"));
    resize();
  }

  GraphNode.inport([String method]) {
    name = GraphNode.randomName();
    this.method = method ?? name;
    icon = "sign-in-alt";
    type = GraphNodeType.inport;

    this.outports.add(NodePort.output(this, 1, "out"));
    resize();
  }

  GraphNode.trigger([String method]) {
    name = GraphNode.randomName();
    this.method = method ?? name;
    icon = "bolt";
    type = GraphNodeType.trigger;

    this.outports.add(NodePort.output(this, 1, "out"));
    resize();
  }

  GraphNode.behavior(GraphState graph) {
    name = GraphNode.randomName();
    icon = graph.icon;
    title = graph.title;
    type = GraphNodeType.behavior;
    method = graph.name;

    List<String> inputs = [];
    List<String> outputs = [];

    for (var node in graph.nodes) {
      if (node.type == GraphNodeType.inport) {
        inputs.add(node.method);
      }

      if (node.type == GraphNodeType.outport) {
        outputs.add(node.method);
      }
    }

    for (int i = 0; i < inputs.length; i++) {
      this.inports.add(NodePort.input(this, i + 1, inputs[i]));
    }

    for (int i = 0; i < outputs.length; i++) {
      this.outports.add(NodePort.output(this, i + 1, outputs[i]));
    }

    resize();
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

  @override
  String toString() {
    return "$name";
  }

  Iterable<GraphObject> walkNode() sync* {
    for (var port in inports) {
      if (port.showFlag) yield port.flag;
      yield port;
    }

    for (var port in outports) {
      if (port.showFlag) yield port.flag;
      yield port;
    }

    yield this;
  }

  bool get allowAddInport {
    return isAnyType(Action_Behavior);
  }

  bool get allowAddOutport {
    return isAnyType(Action_Behavior);
  }

  static GraphNodeType parseNodeType(String type) {
    switch (type) {
      case "action":
        return GraphNodeType.action;
      case "behavior":
        return GraphNodeType.behavior;
      case "inport":
        return GraphNodeType.inport;
      case "outport":
        return GraphNodeType.outport;
      case "trigger":
        return GraphNodeType.trigger;
      case "event":
        return GraphNodeType.event;
      case "gamepad":
        return GraphNodeType.gamepad;
    }

    return GraphNodeType.unknown;
  }

  void setDefaultPort(NodePort port, {bool toggle = false}) {
    var ports = port.isInport ? inports : outports;

    for (var p in ports) {
      if (!p.equalTo(port)) {
        p.isDefault = false;
        continue;
      }

      p.isDefault = toggle ? !p.isDefault : true;
    }
  }

  void movePortUp(NodePort port) {
    var ports = port.isInport ? inports : outports;

    var idx = ports.indexWhere((x) => x.equalTo(port));
    if (idx <= 0) return;

    var last = ports.removeAt(idx);
    ports.insert(idx - 1, last);
    int i = 1;
    for (var p in ports) {
      p.ordinal = i++;
    }
    resize();
  }

  void movePortDown(NodePort port) {
    var ports = port.isInport ? inports : outports;

    var idx = ports.indexWhere((x) => x.equalTo(port));
    if (idx < 0 || idx >= ports.length - 1) return;

    var last = ports.removeAt(idx);
    ports.insert(idx + 1, last);
    int i = 1;
    for (var p in ports) {
      p.ordinal = i++;
    }

    resize();
  }

  NodePort getInport(String name) {
    return inports.firstWhere((x) => x.name == name, orElse: () => null);
  }

  NodePort getOutport(String name) {
    return outports.firstWhere((x) => x.name == name, orElse: () => null);
  }

  NodePort getOrAddPort(String name, NodePortType type,
      {bool autoResize = true}) {
    bool added = false;
    NodePort result;

    switch (type) {
      case NodePortType.inport:
        result = getInport(name);
        if (result == null) {
          result = NodePort.input(this, inports.length + 1, name);
          inports.add(result);
          added = true;
        }
        break;
      case NodePortType.outport:
        result = getOutport(name);
        if (result == null) {
          result = NodePort.output(this, outports.length + 1, name);
          outports.add(result);
          added = true;
        }
        break;
      case NodePortType.unknown:
        break;
    }

    if (added && autoResize) resize();
    return result;
  }

  TideChartNode pack() {
    TideChartNode result = TideChartNode();
    result.type = type.toString().split(".").last;
    result.name = name;
    result.icon = icon;

    if (title != null) result.title = title;
    if (method != null) result.method = method;
    if (library != null) result.library = library;
    if (script != null) result.script = script;

    result.isLogging = isLogging;
    result.isDebugging = isDebugging;
    result.isPaused = isPaused;
    result.isDisabled = isDisabled;

    result.posX = pos.dx.round();
    result.posY = pos.dy.round();

    result.delay = (delay * 100).round();

    result.inports.addAll(inports.map((x) => x.pack()));
    result.outports.addAll(outports.map((x) => x.pack()));

    result.props.addAll(props.packList());
    result.settings.addAll(settings.packList());
    return result;
  }

  bool isAnyType(List<GraphNodeType> types) {
    return types.any((x) => x == type);
  }

  bool isNotType(List<GraphNodeType> types) {
    return !isAnyType(types);
  }

  bool equalTo(GraphNode other) {
    if (name != other.name) return false;
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

  List<NodePort> get localInports => inports.where((x) => x.isLocal).toList();
  List<NodePort> get localOutports => outports.where((x) => x.isLocal).toList();

  List<NodePort> get visibleInports {
    if (showLocalInports) {
      return inports;
    } else {
      return inports.where((x) => x.isGlobal).toList();
    }
  }

  List<NodePort> get visibleOutports {
    if (showLocalOutports) {
      return outports;
    } else {
      return outports.where((x) => x.isGlobal).toList();
    }
  }

  bool resize() {
    double width = size.width;
    double height = size.height;

    var inports = visibleInports;
    var outports = visibleOutports;

    var ports = max(inports.length, outports.length);

    if (type == GraphNodeType.action || type == GraphNodeType.behavior) {
      height = max(Graph.DefaultNodeSize,
          ports * Graph.DefaultPortSpacing + Graph.DefaultPortPadding);
      width = type == GraphNodeType.action
          ? Graph.DefaultNodeSize
          : Graph.DefaultNodeSize * 2.5;
    } else if (type == GraphNodeType.trigger || type == GraphNodeType.event) {
      var label = method ?? "";
      var rect = Graph.font.limits(label, pos, Graph.NodeTriggerLabelSize,
          alignment: Alignment.center);

      width = rect.width +
          Graph.NodeTriggerPaddingLeft +
          Graph.NodeTriggerPaddingRight +
          Graph.NodeTriggerLabelPadding;

      height = Graph.NodeTriggerHeight;
    } else if (type == GraphNodeType.gamepad) {
      width = Graph.DefaultGamepadWidth;
      height = Graph.DefaultGamepadHeight;
    } else {
      width = Graph.DefaultNodeSize;
      height = Graph.DefaultNodeSize;
    }

    var changed = false;
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
