import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:uuid/uuid.dart';

import 'graph_node.dart';

class GraphState with ChangeNotifier {
  GraphController controller;
  String id = Uuid().v1().toString();
  int version = 0;

  List<GraphNode> nodes = [GraphNode.action()..pos = Offset(100, 100)];
  List<GraphLink> links = [];

  void beginUpdate() {}

  void endUpdate(bool changed) {
    if (changed) {
      notifyListeners();
    }
  }

  bool equals(GraphState other) {
    if (id != other.id) return false;
    if (version != other.version) return false;
    if (nodes.length != other.nodes.length) return false;
    if (links.length != other.links.length) return false;

    for (int i = 0; i < nodes.length; i++) {
      if (!nodes[i].equals(other.nodes[i])) return false;
    }

    for (int i = 0; i < links.length; i++) {
      if (!links[i].equals(other.links[i])) return false;
    }

    return true;
  }

  bool copy(GraphState other) {
    bool changed = !equals(other);

    beginUpdate();

    id = other.id;
    version = other.version;
    nodes = [...other.nodes];
    links = [...other.links];

    endUpdate(changed);

    return changed;
  }

  void clear() {}
}
