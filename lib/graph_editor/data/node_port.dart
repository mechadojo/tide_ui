import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'graph.dart';
import 'graph_node.dart';

class PackedNodePort {
  NodePortType type;
  RefGraphNode node;
  String name;
  int ordinal = 0;
  bool isDefault = false;

  PackedNodePort.port(NodePort port) {
    type = port.type;
    node = port.node.ref();
    name = port.name;
    ordinal = port.ordinal;
    isDefault = port.isDefault;
  }

  NodePort unpack(GetNodeByName lookup) {
    GraphNode target = lookup(node.name) as GraphNode;
    NodePort result = target.getOrAddPort(name, type);
    result.isDefault = isDefault;
    return result;
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString().split(".").last,
        'node': node.name,
        'name': name,
        'ordinal': ordinal,
        'isDefault': isDefault
      };
}

class NodePort extends GraphObject {
  static NodePort none = NodePort()..name = "<none>";

  NodePortType type = NodePortType.inport;
  GraphNode node = GraphNode.none;

  String name = "";
  int ordinal = 0;
  bool isDefault = false;

  bool get isInport => type == NodePortType.inport;
  bool get isOutport => type == NodePortType.outport;

  PackedNodePort pack() {
    return PackedNodePort.port(this);
  }

  @override
  String toString() {
    return "${node}:$name";
  }

  bool canLinkTo(NodePort other) {
    return type != other.type;
  }

  NodePort();
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
}
