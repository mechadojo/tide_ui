import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';
import 'package:tide_ui/graph_editor/painter/widget_node_painter.dart';

import 'graph.dart';
import 'graph_property_set.dart';
import 'node_port.dart';

const Inport_Outport = [GraphNodeType.inport, GraphNodeType.outport];
const Inport_Trigger = [GraphNodeType.inport, GraphNodeType.trigger];
const Outport_Event = [GraphNodeType.outport, GraphNodeType.event];
const Action_Behavior = [GraphNodeType.action, GraphNodeType.behavior];
const Action_Behavior_Widget = [
  GraphNodeType.action,
  GraphNodeType.behavior,
  GraphNodeType.widget
];
const Trigger_Event = [GraphNodeType.trigger, GraphNodeType.event];

enum GraphNodeType {
  /// action nodes use library/method to handle messages
  action,

  /// behavior nodes reference a behavior graph to handle its messages
  behavior,

  /// inports define inbound message ports for use as a behavior node
  inport,

  /// outports define outboard message ports for use as a behavior node
  outport,

  /// trigger nodes monitor for event broadcasts and produce a message
  trigger,

  /// messages routed into an event node are broadcasted as an event
  event,

  /// widgets can combine the features of all the other node types
  widget,

  /// node type name was not recognized
  unknown,
}

enum WidgetNodeType {
  /// placeholder value when a node is not a widget node
  none,

  /// generates events from gamepad input
  gamepad,

  /// combine, split, sequence and route messages
  router,

  /// condionally transform and drop messages passing thru them
  filter,

  /// execute groups of nodes as steps and produce events on step change
  sequence,

  /// produce events over time
  timeline,

  /// produce messages over time based on input values
  controller,

  /// produce events from external values (sensors)
  input,

  /// control external mechanism based on events (motors/servos)
  output,

  /// combine inputs, outputs and logic into subsystems
  mechanism,

  /// generates events from configuration data
  config,

  /// routes messages to/from global configuration
  global,

  /// cancel message routing based on events
  reset,

  /// generate custom scripts from configuration data
  blocks,

  /// routes messages to/from a remote source
  remote,

  /// widget name was not recognized
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
  WidgetNodeType widget = WidgetNodeType.none;

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

  bool get isAction => type == GraphNodeType.action;
  bool get isBehavior => type == GraphNodeType.behavior;
  bool get isEvent => type == GraphNodeType.event;
  bool get isTrigger => type == GraphNodeType.trigger;
  bool get isInport => type == GraphNodeType.inport;
  bool get isOutport => type == GraphNodeType.outport;
  bool get isWidget => type == GraphNodeType.widget;

  bool get isGamepad => widget == WidgetNodeType.gamepad;
  bool get isRouter => widget == WidgetNodeType.router;
  bool get isFilter => widget == WidgetNodeType.filter;
  bool get isSequence => widget == WidgetNodeType.sequence;
  bool get isTimeline => widget == WidgetNodeType.timeline;
  bool get isController => widget == WidgetNodeType.controller;
  bool get isInput => widget == WidgetNodeType.input;
  bool get isOutput => widget == WidgetNodeType.output;
  bool get isMechanism => widget == WidgetNodeType.mechanism;
  bool get isConfig => widget == WidgetNodeType.config;
  bool get isGlobal => widget == WidgetNodeType.global;
  bool get isReset => widget == WidgetNodeType.reset;
  bool get isBlocks => widget == WidgetNodeType.blocks;
  bool get isRemote => widget == WidgetNodeType.remote;

  double delay = 0;

  List<NodePort> inports = [];
  List<NodePort> outports = [];

  List<GraphState> internal = [];
  List<TideChartSource> resources = [];
  List<TideChartNote> notes = [];

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

  factory GraphNode.clone(GraphNode other) {
    GraphNode result = GraphNode();
    return GraphNode.unpack(other.pack(), (name) => result);
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

  String get action => hasLibrary ? "$library.$method" : "$method";
  set action(String value) {
    var parts = value.split('.');
    if (parts.length == 1) {
      library = "";
      method = parts.first;
    } else {
      library = parts.take(parts.length - 1).join(".");
      method = parts.last;
    }
  }

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
    node.widget = GraphNode.parseWidgetType(packed.widget);

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

    node.notes = [...packed.notes.map((x) => x.clone())];
    node.resources = [...packed.resources.map((x) => x.clone())];
    node.internal = [...packed.internal.map((x) => GraphState.unpack(x))];

    node.resize();

    node.moveTo(packed.posX.toDouble(), packed.posY.toDouble(), update: true);

    return node;
  }

  GraphNode.gamepad([int driver = 1, double size = 150]) {
    name = GraphNode.randomName();
    title = "Driver $driver";
    props.replace(GraphProperty.asInt("driver", driver));
    settings.replace(GraphProperty.asDouble("size", size));
    icon = "gamepad";
    type = GraphNodeType.widget;
    widget = WidgetNodeType.gamepad;
    resize();
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

  void removePort(NodePort port) {
    if (port.isInport) {
      var idx = inports.indexWhere((x) => x.name == port.name);
      if (idx >= 0) {
        inports.removeAt(idx);
      }
    } else {
      var idx = outports.indexWhere((x) => x.name == port.name);
      if (idx >= 0) {
        outports.removeAt(idx);
      }
    }

    resize();
  }

  NodePort addInport() {
    int idx = inports.length + 1;
    while (inports.any((x) => x.name == "in$idx")) {
      idx++;
    }
    var result = NodePort.input(this, inports.length + 1, "in${idx}");
    inports.add(result);
    resize();
    return result;
  }

  NodePort addOutport() {
    int idx = outports.length + 1;
    while (outports.any((x) => x.name == "out$idx")) {
      idx++;
    }

    var result = NodePort.output(this, outports.length + 1, "out${idx}");
    outports.add(result);
    resize();
    return result;
  }

  bool usingGraph(String name) {
    return type == GraphNodeType.behavior && method == name;
  }

  bool usingMethod(String library, String method) {
    return type == GraphNodeType.action &&
        this.library == library &&
        this.method == method;
  }

  Iterable<GraphObject> walkNode() sync* {
    for (var port in inports) {
      if (port.showFlag) yield port.flag;
      if (port.hasFilter) yield port.filterFlag;
      yield port;
    }

    for (var port in outports) {
      if (port.showFlag) yield port.flag;
      if (port.hasFilter) yield port.filterFlag;
      yield port;
    }

    yield this;
  }

  bool get allowAddFilter {
    if (isGamepad) return true;

    return false;
  }

  bool get allowAddInport {
    if (isAnyType(Action_Behavior)) return true;
    return false;
  }

  bool get allowAddOutport {
    if (isAnyType(Action_Behavior)) return true;

    if (isGamepad) return true;

    return false;
  }

  String get widgetTypeName {
    var result = widget.toString().split(".").last;
    result = result[0].toUpperCase() + result.substring(1);
    return result;
  }

  static WidgetNodeType parseWidgetType(String type) {
    if (type == null || type.isEmpty) return WidgetNodeType.none;
    switch (type) {
      case "none":
        return WidgetNodeType.none;
      case "gamepad":
        return WidgetNodeType.gamepad;
      case "router":
        return WidgetNodeType.router;
      case "filter":
        return WidgetNodeType.filter;
      case "sequence":
        return WidgetNodeType.sequence;
      case "timeline":
        return WidgetNodeType.timeline;
      case "controller":
        return WidgetNodeType.controller;
      case "input":
        return WidgetNodeType.input;
      case "output":
        return WidgetNodeType.output;
      case "mechanism":
        return WidgetNodeType.mechanism;
      case "config":
        return WidgetNodeType.config;
      case "global":
        return WidgetNodeType.global;
      case "reset":
        return WidgetNodeType.reset;
      case "blocks":
        return WidgetNodeType.blocks;
      case "remote":
        return WidgetNodeType.remote;
    }
    return WidgetNodeType.unknown;
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
      case "widget":
        return GraphNodeType.widget;
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
    var wt = widget.toString().split(".").last;

    if (wt != null && wt != "none") {
      result.widget = wt;
    }

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

    result.notes.addAll(notes.map((x) => x.clone()));
    result.resources.addAll(resources.map((x) => x.clone()));
    result.internal.addAll(internal.map((x) => x.pack()));

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
    yield* inports.expand((x) => x.interactive());
    yield* outports.expand((x) => x.interactive());
    yield this;
  }

  @override
  void moveBy(double dx, double dy) {
    super.moveBy(dx, dy);

    for (var port in inports) {
      port.moveBy(dx, dy);
    }

    for (var port in outports) {
      port.moveBy(dx, dy);
    }
  }

  @override
  bool moveTo(double dx, double dy, {bool update = false}) {
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

  double get inportsFilterMargin {
    double result = 0;
    for (var port in inports) {
      if (port.hasFilter) {
        var sz = Graph.font
            .limits(port.filter, Offset.zero, Graph.PortValueLabelSize);
        var width = sz.width + Graph.PortFilterFlagPadding;
        if (width > result) result = width;
      }
    }
    return result;
  }

  double get outportsFilterMargin {
    double result = 0;
    for (var port in outports) {
      if (port.hasFilter) {
        var sz = Graph.font
            .limits(port.filter, Offset.zero, Graph.PortValueLabelSize);
        var width = sz.width + Graph.PortFilterFlagPadding;
        if (width > result) result = width;
      }
    }
    return result;
  }

  bool resize() {
    double width = size.width;
    double height = size.height;

    var inports = visibleInports;
    var outports = visibleOutports;
    var spacing = Graph.DefaultPortSpacing;

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
    } else if (type == GraphNodeType.widget) {
      var sz = settings.getDouble("size", 150);
      size = WidgetNodePainter.measureWidget(widget, Size(sz, sz));
      width = size.width;
      height = size.height;
      spacing = Graph.WidgetPortSpacing;
    } else {
      width = Graph.DefaultNodeSize;
      height = Graph.DefaultNodeSize;
    }

    var changed = false;
    //
    // update position of inports
    //
    var dy = (height - Graph.DefaultPortPadding) / inports.length;
    if (dy < spacing) dy = spacing;
    var px = pos.dx - (width / 2 + Graph.DefaultPortOffset);
    px -= inportsFilterMargin;

    var py = pos.dy - ((inports.length - 1) * dy) / 2;

    for (var port in inports) {
      changed |= port.moveTo(px, py);
      py += dy;
    }

    //
    // update position of outports
    //
    dy = (height - Graph.DefaultPortPadding) / outports.length;
    if (dy < spacing) dy = spacing;
    py = pos.dy - ((outports.length - 1) * dy) / 2;
    px = pos.dx + (width / 2 + Graph.DefaultPortOffset);
    px += outportsFilterMargin;

    for (var port in outports) {
      changed |= port.moveTo(px, py);
      py += dy;
    }

    changed |= resizeTo(width, height);
    if (changed) version++;
    return changed;
  }
}
