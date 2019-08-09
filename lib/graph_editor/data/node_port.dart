import 'package:flutter_web/material.dart';

import 'graph.dart';
import 'graph_node.dart';

class NodePort extends GraphObject {
  NodePortType type = NodePortType.inport;
  GraphNode node;

  String name = "";
  int ordinal = 0;

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
