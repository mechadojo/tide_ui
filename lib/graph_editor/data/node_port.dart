import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'graph.dart';
import 'graph_node.dart';

class PackedNodePort {
  NodePortType type;
  RefGraphNode node;
  String name;
  int ordinal;

  PackedNodePort.port(NodePort port) {
    type = port.type;
    node = port.node.ref();
    name = port.name;
    ordinal = port.ordinal;
  }

  NodePort unpack(GetNodeByName lookup) {
    return NodePort()
      ..type = type
      ..node = lookup(node.name)
      ..name = name
      ..ordinal = ordinal;
  }
}

class NodePort extends GraphObject {
  static NodePort none = NodePort()..name = "<none>";

  NodePortType type = NodePortType.inport;
  GraphNode node = GraphNode.none;

  String name = "";
  int ordinal = 0;
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
    size = Size(Graph.DefaultPortSize, Graph.DefaultPortSize);
  }

  NodePort.output(this.node, this.ordinal, [this.name]) {
    type = NodePortType.outport;
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
