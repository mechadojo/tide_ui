import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'graph.dart';
import 'graph_node.dart';

class NodePort extends GraphObject {
  static NodePort none = NodePort()..name = "<none>";

  NodePortType type = NodePortType.inport;
  GraphNode node = GraphNode.none;

  String name = "";
  int ordinal = 0;
  bool isDefault = false;

  bool get isInport => type == NodePortType.inport;
  bool get isOutport => type == NodePortType.outport;

  @override
  String toString() {
    return "${node}:$name";
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
    if (node.name != other.node.name) return false;
    if (type != other.type) return false;
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
