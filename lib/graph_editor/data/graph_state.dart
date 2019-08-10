import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_history.dart';
import 'package:uuid/uuid.dart';

import 'graph_link.dart';
import 'graph_node.dart';
import 'node_port.dart';

typedef GetNodeByName(String name);

class GraphState with ChangeNotifier {
  GraphController controller;

  String id = Uuid().v1().toString();
  String title = "";
  int version = 0;

  List<GraphNode> nodes = [...random(10)];
  List<GraphLink> links = [];

  // access nodes by reference where nodes may not be fully defined
  // allows reconstructing the recursively defined graph objects
  Map<String, GraphNode> referenced = {};
  GraphHistory history = GraphHistory();

  int updating = 0;
  bool hasChanged = false;

  void beginUpdate() {
    updating++;
  }

  void endUpdate(bool changed) {
    updating--;
    hasChanged |= changed;

    if (updating <= 0 && hasChanged) {
      notifyListeners();
      hasChanged = false;
      updating = 0;
    }
  }

  GraphNode getNode(String name) {
    var result = referenced[name];
    if (result != null) return result;

    result = nodes.firstWhere((x) => x.name == name,
        orElse: () => GraphNode()..name = name);
    referenced[name] = result;
    return result;
  }

  GraphNode unpackNode(PackedGraphNode node) {
    return node.unpack(getNode);
  }

  GraphLink unpackLink(PackedGraphLink link) {
    return link.unpack(getNode);
  }

  NodePort unpackPort(PackedNodePort port) {
    return port.unpack(getNode);
  }

  int findLink(NodePort fromPort, NodePort toPort) {
    return links.indexWhere(
        (x) => x.fromPort.equalTo(fromPort) && x.toPort.equalTo(toPort));
  }

  GraphLink removeLink(NodePort fromPort, NodePort toPort) {
    var index = findLink(fromPort, toPort);
    if (index >= 0) {
      return links.removeAt(index);
    }
    return GraphLink.none;
  }

  GraphLink addLink(NodePort fromPort, NodePort toPort) {
    var link = GraphLink.link(fromPort, toPort);
    links.add(link);
    return link;
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

    referenced.clear();
    for (var name in other.referenced.keys) {
      referenced[name] = other.referenced[name];
    }

    history.copy(other.history);

    endUpdate(changed);

    return changed;
  }

  void clear() {}
}
