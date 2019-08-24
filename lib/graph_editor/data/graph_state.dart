import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_history.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';
import 'package:uuid/uuid.dart';

import 'canvas_interactive.dart';
import 'update_notifier.dart';
import 'graph_link.dart';
import 'graph_node.dart';
import 'node_port.dart';

typedef GetNodeByName(String name);

class GraphSelection {
  Offset pos = Offset.zero;

  List<GraphNode> nodes = [];
  List<GraphLink> links = [];

  GraphSelection.node(GraphNode node) {
    nodes.add(node);
  }
}

class GraphState extends UpdateNotifier {
  GraphController controller;

  GlobalKey graphKey = GlobalKey();

  String id = Uuid().v1().toString();
  String name = GraphNode.randomName();
  String title = "";
  String icon = VectorIcons.getRandomName();
  String type = "";

  int version = 0;

  List<GraphNode> nodes = [];
  List<GraphLink> links = [];

  // access nodes by reference where nodes may not be fully defined
  // allows reconstructing the recursively defined graph objects
  Map<String, GraphNode> referenced = {};
  GraphHistory history = GraphHistory();

  GraphState();
  GraphState.random() {
    nodes.addAll(randomNodes(10));
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

  Future<Uint8List> getImage() async {
    RenderRepaintBoundary boundary = graphKey.currentContext.findRenderObject();

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }

  TideChartGraph pack() {
    TideChartGraph result = TideChartGraph();
    result.id = id;
    result.name = name;
    result.icon = icon;

    if (title != null) result.title = title;
    if (type != null) result.type = type;

    result.nodes.addAll(nodes.map((x) => x.pack()));
    result.links.addAll(links.map((x) => x.pack()));
    result.history.addAll(history.undoCmds);
    return result;
  }

  void layout() {
    for (var link in links) {
      link.update();
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

    result = GraphNode()..name = name;
    referenced[name] = result;
    return result;
  }

  GraphNode clone(GraphNode node) {
    if (node == null) return null;

    var packed = node.pack();
    node.name = GraphNode.randomName();
    return unpackNode(packed);
  }

  void unpackGraph(TideChartGraph graph) {
    id = graph.id;
    name = graph.name;
    title = graph.title;
    icon = graph.icon;
    type = graph.type;

    nodes = [...graph.nodes.map((x) => unpackNode(x))];
    links = [...graph.links.map((x) => unpackLink(x))];

    history = GraphHistory()..undoCmds = [...graph.history];
  }

  GraphNode unpackNode(TideChartNode node) {
    return GraphNode.unpack(node, getNode);
  }

  GraphLink unpackLink(TideChartLink link) {
    return GraphLink.unpack(link, getNode);
  }

  NodePort unpackPort(TideChartPort port) {
    return NodePort.unpack(port, getNode);
  }

  int findNode(GraphNode node) {
    return nodes.indexWhere((x) => x.equalTo(node));
  }

  int findLink(NodePort fromPort, NodePort toPort) {
    return links.indexWhere(
        (x) => x.outPort.equalTo(fromPort) && x.inPort.equalTo(toPort));
  }

  Iterable<GraphLink> getNodeLinks(GraphNode node) sync* {
    for (var link in links) {
      if (link.outPort.node.equalTo(node)) yield link;
      if (link.inPort.node.equalTo(node)) yield link;
    }
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

  bool allowDeletePort(NodePort port) {
    if (port == null) return false;

    if (port.isRequired) return false;
    if (port.showFlag) return false;

    if (links.any((x) => x.outPort.equalTo(port) || x.inPort.equalTo(port))) {
      return false;
    }

    return true;
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
    return getExtents(walkGraph());
  }

  Iterable<GraphObject> walkGraph() sync* {
    for (var node in nodes.reversed) {
      if (node.selected) continue;
      yield* node.walkNode();
    }

    yield* links.reversed;

    for (var node in nodes.reversed) {
      if (!node.selected) continue;
      yield* node.walkNode();
    }
  }

  static Iterable<GraphNode> randomNodes(int count) sync* {
    var rnd = Random();

    for (int i = 0; i < count; i++) {
      yield GraphNode.action(
          inputs: List.filled(rnd.nextInt(6) + 1, ""),
          outputs: List.filled(rnd.nextInt(6) + 1, ""))
        ..moveTo(rnd.nextInt(750) + 50.0, rnd.nextInt(750) + 50.0)
        ..isLogging = rnd.nextBool()
        ..isDebugging = rnd.nextBool()
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
    if (name != other.name) return false;
    if (title != other.title) return false;
    if (icon != other.icon) return false;

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
    bool changed = true;

    beginUpdate();

    id = other.id;
    title = other.title;
    icon = other.icon;
    name = other.name;
    type = other.type;

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
