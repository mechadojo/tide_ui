import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_history.dart';
import 'package:uuid/uuid.dart';

import 'canvas_interactive.dart';
import 'graph_link.dart';
import 'graph_node.dart';
import 'node_port.dart';

typedef GetNodeByName(String name);

class GraphState with ChangeNotifier {
  GraphController controller;

  String id = Uuid().v1().toString();
  String title = "";
  int version = 0;

  List<GraphNode> nodes = [];
  List<GraphLink> links = [];

  // access nodes by reference where nodes may not be fully defined
  // allows reconstructing the recursively defined graph objects
  Map<String, GraphNode> referenced = {};
  GraphHistory history = GraphHistory();

  int updating = 0;
  bool hasChanged = false;

  GraphState() {
    nodes.addAll(random(10));
    var rand = Random();
    for (int i = 0; i < 10; i++) {
      var fromNode = nodes[rand.nextInt(nodes.length)];
      var toNode = nodes[rand.nextInt(nodes.length)];
      while (toNode == fromNode) {
        toNode = nodes[rand.nextInt(nodes.length)];
      }

      var fromPort = fromNode.outports[rand.nextInt(fromNode.outports.length)];
      var toPort = toNode.inports[rand.nextInt(toNode.inports.length)];

      addLink(fromPort, toPort);
    }
  }
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

    result = nodes.firstWhere((x) => x.name == name, orElse: () => null);

    if (result != null) {
      referenced[name] = result;
      return result;
    }

    print("Creating a new node for $name");
    result = GraphNode()..name = name;
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
        (x) => x.outPort.equalTo(fromPort) && x.inPort.equalTo(toPort));
  }

  GraphLink removeLink(NodePort fromPort, NodePort toPort) {
    var index = findLink(fromPort, toPort);
    if (index >= 0) {
      return links.removeAt(index);
    }
    return GraphLink.none;
  }

  GraphLink addLink(NodePort fromPort, NodePort toPort, [int group = -1]) {
    var link = GraphLink.link(fromPort, toPort);
    if (group >= 0) link.group = group;

    links.add(link);
    return link;
  }

  Rect getExtents(Iterable<CanvasInteractive> items) {
    double top = 0;
    double left = 0;
    double bottom = 0;
    double right = 0;
    bool first = true;

    for (var item in items) {
      if (first) {
        top = item.hitbox.top;
        left = item.hitbox.left;
        bottom = item.hitbox.bottom;
        right = item.hitbox.right;
      } else {
        if (item.hitbox.left < left) left = item.hitbox.left;
        if (item.hitbox.top < top) top = item.hitbox.top;
        if (item.hitbox.right > right) right = item.hitbox.right;
        if (item.hitbox.bottom > bottom) bottom = item.hitbox.bottom;
      }
      first = false;
    }

    var result = Rect.fromLTRB(left, top, right, bottom);
    return result;
  }

  Rect get selectionExtents {
    if (controller.selection.isEmpty) {
      return extents;
    }

    return getExtents(controller.walkSelection());
  }

  Rect get extents {
    return getExtents(controller.walkGraph());
  }

  static Iterable<GraphNode> random(int count) sync* {
    var rnd = Random();

    for (int i = 0; i < count; i++) {
      yield GraphNode.action(
          inputs: List.filled(rnd.nextInt(6) + 1, ""),
          outputs: List.filled(rnd.nextInt(6) + 1, ""))
        ..moveTo(rnd.nextInt(750) + 50.0, rnd.nextInt(750) + 50.0)
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
