import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_property_set.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'graph.dart';
import 'graph_node.dart';

class PortFlag extends GraphObject {
  String text = "";
  Path path;
  List<Offset> leader = [];
  Offset textPos = Offset.zero;
  Offset iconPos = Offset.zero;

  double direction = -1.0;

  void update() {
    path = Path();

    leader.clear();
    var cx = pos.dx + (Graph.DefaultPortSize / 2 * direction);
    var cy = pos.dy;
    var rect = Graph.font.limits(text, Offset.zero, Graph.PortValueLabelSize);

    leader.add(Offset(cx, cy));
    cx += Graph.PortValueLeader * direction;
    leader.add(Offset(cx, cy));
    path.moveTo(cx, cy);

    cy += Graph.PortValueHeight / 2;
    var bottomY = cy;
    cx += Graph.PortValueFlagWidth * direction;
    path.lineTo(cx, cy);
    var startX = cx;
    cx += Graph.PortValuePaddingStart * direction;
    var textStart = cx;

    cx += rect.width * direction;
    var textEnd = cx;
    cx += Graph.PortValuePaddingEnd * direction;
    var endX = cx;
    path.lineTo(cx, cy);
    cy -= Graph.PortValueHeight;
    var topY = cy;
    path.lineTo(cx, cy);

    cx = startX;
    path.lineTo(cx, cy);
    path.close();

    textPos = Offset((textStart + textEnd) / 2, pos.dy);
    iconPos = Offset(
        endX +
            ((Graph.PortValueIconSize / 2 + Graph.PortValueIconPadding) *
                direction),
        pos.dy);
    hitbox = Rect.fromPoints(Offset(startX, topY), Offset(endX, bottomY));
  }
}

class NodePort extends GraphObject {
  static NodePort none = NodePort()..name = "<none>";

  PortFlag flag = PortFlag();
  NodePortType type = NodePortType.inport;
  GraphNode node = GraphNode.none;

  String name = "";

  int ordinal = 0;
  bool isDefault = false;
  bool isRequired = true;

  bool get isLocal => name != null && name.startsWith("_");
  bool get isGlobal => !isLocal;

  String get value => node.props.getString(name);
  set value(String next) {
    if (next == null || next.isEmpty || type != NodePortType.inport) {
      node.props.remove(name);
    } else {
      node.props.replace(GraphProperty.parse(name, next));
    }
  }

  String trigger;
  String link;
  String event;

  bool get showFlag => hasValue || hasTrigger || hasLink || hasEvent;
  bool get hasValue => value != null && value.isNotEmpty;
  bool get hasTrigger => trigger != null && trigger.isNotEmpty;
  bool get hasLink => link != null && link.isNotEmpty;
  bool get hasEvent => event != null && event.isNotEmpty;

  String get flagLabel {
    if (hasValue) return value;
    if (hasTrigger) return trigger;
    if (hasLink) return link;
    if (hasEvent) return event;
    return null;
  }

  String get flagType {
    if (hasValue) return "Value";
    if (hasTrigger) return "Trigger";
    if (hasLink) return "Link";
    if (hasEvent) return "Event";
    return null;
  }

  void rename(String next) {
    if (node != null) {
      var ports = isInport ? node.inports : node.outports;
      if (ports.any((x) => x != this && x.name == next)) {
        next = next + "_";
      }

      if (hasValue) {
        node.props.rename(name, next);
      }
    }

    var last = name;
    name = next;

    var lastLocal = last.startsWith("_");
    var nextLocal = next.startsWith("_");
    if (lastLocal != nextLocal) {
      node.resize();
    }
  }

  void clearFlag() {
    value = null;
    trigger = null;
    link = null;
    event = null;
  }

  void setValue(String value) {
    this.value = value;
    if (value != null) {
      trigger = null;
      link = null;
      event = null;
    }
  }

  void setTrigger(String trigger) {
    this.trigger = trigger;

    if (trigger != null) {
      value = null;
      link = null;
      event = null;
    }
  }

  void setLink(String link) {
    this.link = link;

    if (link != null) {
      value = null;
      trigger = null;
      event = null;
    }
  }

  void setEvent(String event) {
    this.event = event;

    if (event != null) {
      value = null;
      trigger = null;
      link = null;
    }
  }

  String get icon => type == NodePortType.inport
      ? "chevron-circle-left"
      : "chevron-circle-right";

  bool get isInport => type == NodePortType.inport;
  bool get isOutport => type == NodePortType.outport;

  @override
  String toString() {
    return "${node}:$name";
  }

  bool allowSetValue() {
    return !hasValue && node.isAnyType(Action_Behavior);
  }

  bool canLinkTo(NodePort other) {
    return type != other.type;
  }

  NodePort();

  static NodePort unpackByName(
      String node, String port, String type, GetNodeByName lookup) {
    GraphNode target = lookup(node) as GraphNode;
    NodePort result = target.getOrAddPort(port, NodePort.parsePortType(type),
        autoResize: false);
    return result;
  }

  static NodePort unpack(TideChartPort packed, GetNodeByName lookup) {
    GraphNode target = lookup(packed.node) as GraphNode;
    NodePort result = target.getOrAddPort(
        packed.name, NodePort.parsePortType(packed.type),
        autoResize: false);
    result.isDefault = packed.isDefault;
    result.isRequired = packed.isRequired;
    result.value = packed.value;
    result.trigger = packed.trigger;
    result.event = packed.event;
    result.link = packed.link;

    return result;
  }

  NodePort.input(this.node, this.ordinal, [this.name]) {
    type = NodePortType.inport;
    if (name == null || name.isEmpty) {
      name = ordinal == 0 ? "in" : "in$ordinal";
    }
    if (ordinal == 0) ordinal = 1;
    size = Graph.DefaultPortHitboxSize;
  }

  NodePort.output(this.node, this.ordinal, [this.name]) {
    type = NodePortType.outport;
    if (name == null || name.isEmpty) {
      name = ordinal == 0 ? "out" : "out$ordinal";
    }
    if (ordinal == 0) ordinal = 1;
    size = Graph.DefaultPortHitboxSize;
  }

  bool equalTo(NodePort other) {
    if (other == null) return false;

    if (node.name != other.node.name) return false;
    if (name != other.name) return false;

    return true;
  }

  TideChartPort pack() {
    TideChartPort result = TideChartPort();
    result.type = type.toString().split(".").last;
    result.node = node.name;
    result.name = name;
    result.ordinal = ordinal;
    result.isDefault = isDefault;
    result.isRequired = isRequired;

    if (value != null) result.value = value;
    if (trigger != null) result.trigger = trigger;
    if (link != null) result.link = link;
    if (event != null) result.event = event;

    return result;
  }

  static NodePortType parsePortType(String type) {
    switch (type) {
      case "inport":
        return NodePortType.inport;
      case "outport":
        return NodePortType.outport;
      default:
        return NodePortType.unknown;
    }
  }
}
