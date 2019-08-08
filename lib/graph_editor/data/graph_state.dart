import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:uuid/uuid.dart';

import 'graph_node.dart';

class GraphState with ChangeNotifier {
  GraphController controller;
  String id = Uuid().v1().toString();
  int version = 0;

  List<GraphNode> nodes = [...random(10)];
  List<GraphLink> links = [];

  void beginUpdate() {}

  void endUpdate(bool changed) {
    if (changed) {
      notifyListeners();
    }
  }

  static Iterable<GraphNode> random(int count) sync* {
    var rnd = Random();

    for (int i = 0; i < count; i++) {
      yield GraphNode.action(
          inputs: List.filled(rnd.nextInt(6) + 1, ""),
          outputs: List.filled(rnd.nextInt(6) + 1, ""))
        ..moveTo(rnd.nextInt(500) + 50.0, rnd.nextInt(500) + 50.0)
        ..logging = rnd.nextBool()
        ..debugging = rnd.nextBool()
        ..method = rnd.nextBool()
            ? GraphNode.randomName()
            : rnd.nextBool() ? "really_long_method_name" : ""
        ..delay = rnd.nextBool()
            ? rnd.nextInt(6) + rnd.nextInt(16) / 16.0
            : rnd.nextInt(3)
        ..title = rnd.nextBool() ? "Node ${rnd.nextInt(count) + 1}" : "";
    }
  }

  bool equalTo(GraphState other) {
    if (id != other.id) return false;
    if (version != other.version) return false;
    if (nodes.length != other.nodes.length) return false;
    if (links.length != other.links.length) return false;

    for (int i = 0; i < nodes.length; i++) {
      if (!nodes[i].equalTo(other.nodes[i])) return false;
    }

    for (int i = 0; i < links.length; i++) {
      if (!links[i].equalTo(other.links[i])) return false;
    }

    return true;
  }

  bool copy(GraphState other) {
    bool changed = !equalTo(other);

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
