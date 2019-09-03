import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_history.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';
import 'package:uuid/uuid.dart';

import 'canvas_interactive.dart';
import 'graph_property_set.dart';
import 'update_notifier.dart';
import 'graph_link.dart';
import 'graph_node.dart';
import 'node_port.dart';

typedef GetNodeByName(String name);

class GraphSelection {
  Offset pos = Offset.zero;
  Offset origin = Offset.zero;
  Size size = Size.zero;

  List<GraphNode> nodes = [];
  List<GraphLink> links = [];

  GraphSelection.node(GraphNode node) {
    nodes.add(GraphNode.clone(node)..name = GraphNode.randomName());
  }

  GraphSelection.copy(GraphSelection other) {
    pos = other.pos;
    origin = other.origin;
    size = other.size;

    Map<String, String> renameFrom = {};
    Map<String, GraphNode> renameTo = {};

    for (var node in other.nodes) {
      var next = GraphNode.clone(node);
      next.name = GraphNode.randomName();

      renameFrom[node.name] = next.name;
      renameTo[next.name] = next;

      this.nodes.add(next);
    }

    var lookup = (String name) {
      return renameTo[name];
    };

    for (var link in other.links) {
      var packed = link.pack();
      packed.inNode = renameFrom[link.inPort.node.name];
      packed.outNode = renameFrom[link.outPort.node.name];

      this.links.add(GraphLink.unpack(packed, lookup));
    }
  }

  Rect get extents {
    var rect = GraphState.getExtents(
        [...nodes.expand((x) => x.interactive()), ...links]);
    return rect;
  }

  GraphSelection.all(List<GraphNode> nodes, List<GraphLink> links) {
    var rect = GraphState.getExtents(
        [...nodes.expand((x) => x.interactive()), ...links]);

    origin = rect.center;
    size = rect.size;

    Map<String, String> renameFrom = {};
    Map<String, GraphNode> renameTo = {};

    for (var node in nodes) {
      var next = GraphNode.clone(node);
      next.name = GraphNode.randomName();
      next.moveBy(-origin.dx, -origin.dy);

      renameFrom[node.name] = next.name;
      renameTo[next.name] = next;

      this.nodes.add(next);
    }
    var lookup = (String name) {
      return renameTo[name];
    };

    for (var link in links) {
      var packed = link.pack();
      packed.inNode = renameFrom[link.inPort.node.name];
      packed.outNode = renameFrom[link.outPort.node.name];

      this.links.add(GraphLink.unpack(packed, lookup));
    }
  }
}

enum GraphType {
  /// a graph that can be used as a behavior node in other graphs
  behavior,

  /// a top level graph that cannot be included in other graphs
  opmode,

  /// used for subgraphs (regions) and generated graphs (widgets)
  internal,

  /// defines a library of methods (node templates)
  library,

  /// a graph that is available on the shared template page
  template,

  /// used when parsed type is unknown
  unknown
}

class GraphStateNotifier extends UpdateNotifier {
  GraphEditorController editor;
  GraphState get graph => editor.graph;
  GraphController get controller => editor.graph.controller;
  GraphStateNotifier(this.editor);
}

class GraphState {
  GraphController controller;

  GraphType type = GraphType.behavior;

  String id = Uuid().v1().toString();
  String name = GraphNode.randomName();
  String title = "";
  String icon = VectorIcons.getRandomName();

  String script;
  GraphPropertySet props = GraphPropertySet();
  GraphPropertySet settings = GraphPropertySet();

  bool get isOpMode => type == GraphType.opmode;
  bool get isBehavior => type == GraphType.behavior;
  bool get isLibrary => type == GraphType.library;
  bool get isTemplate => type == GraphType.template;
  bool get isInternal => type == GraphType.internal;

  String get opModeType => settings.getString("opmode_type", "Teleop");
  set opModeType(String type) =>
      settings.replace(GraphProperty.asString("opmode_type", type));

  int version = 0;

  bool isLogging = false;
  bool isDebugging = false;
  bool isPaused = false;
  bool isDisabled = false;

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

  GraphState.unpack(TideChartGraph source) {
    unpackGraph(source);
  }

  void beginUpdate() {
    controller.editor.graphNotifier.beginUpdate();
  }

  void endUpdate(bool changed) {
    controller.editor.graphNotifier.endUpdate(changed);
  }

  String get typeName {
    if (type == GraphType.opmode) return "OpMode";
    var result = type.toString().split(".").last;
    result = result[0].toUpperCase() + result.substring(1);
    return result;
  }

  Future<Uint8List> getImage({double width = 500, double height = 500}) async {
    var picture = ui.PictureRecorder();
    print("Rendering $width,$height");
    //var limits = extents;

    //var state = CanvasState();
    var canvas = Canvas(picture, Rect.fromLTWH(0, 0, width, height));

    //state.zoomToFit(limits, limits.size);
    //var painter = CanvasPainter(state, this);
    //painter.paint(canvas, limits.size);

    canvas.drawRect(
        Rect.fromLTWH(10, 10, 100, 100), Paint()..color = Colors.red);

    var pic = picture.endRecording();

    // this doesn't work because Flutter web doesn't implement toImage
    ui.Image image = await pic.toImage(width.round(), height.round());
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }

  TideChartGraph pack() {
    TideChartGraph result = TideChartGraph();
    result.id = id;
    result.name = name;
    result.icon = icon;

    result.isDebugging = isDebugging;
    result.isLogging = isLogging;
    result.isPaused = isPaused;
    result.isDisabled = isDisabled;

    if (title != null) result.title = title;
    if (type != null) result.type = type.toString().split(".").last;
    if (script != null) result.script = script;

    result.nodes.addAll(nodes.map((x) => x.pack()));
    result.links.addAll(links.map((x) => x.pack()));
    result.history.addAll(history.undoCmds);

    result.props.addAll(props.packList());
    result.settings.addAll(settings.packList());

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

  Iterable<GraphNode> usingGraph(String name) sync* {
    for (var node in nodes) {
      if (node.usingGraph(name)) yield node;
    }
  }

  Iterable<GraphNode> usingMethod(String library, String method) sync* {
    for (var node in nodes) {
      if (node.usingMethod(library, method)) yield node;
    }
  }

  GraphNode clone(GraphNode node) {
    if (node == null) return null;

    var packed = node.pack();
    node.name = GraphNode.randomName();
    return unpackNode(packed);
  }

  static GraphType parseType(String type) {
    switch (type) {
      case "":
      case "behavior":
        return GraphType.behavior;
      case "opmode":
        return GraphType.opmode;
      case "internal":
        return GraphType.internal;
      case "library":
        return GraphType.library;
      case "template":
        return GraphType.template;
    }
    return GraphType.unknown;
  }

  void unpackGraph(TideChartGraph graph) {
    id = graph.id;
    name = graph.name;
    title = graph.title;
    icon = graph.icon;
    type = parseType(graph.type);
    script = graph.script;

    isDisabled = graph.isDisabled;
    isLogging = graph.isLogging;
    isDebugging = graph.isDebugging;
    isPaused = graph.isPaused;

    nodes = [...graph.nodes.map((x) => unpackNode(x))];
    links = [...graph.links.map((x) => unpackLink(x))];

    history = GraphHistory()..undoCmds = [...graph.history];
    props = GraphPropertySet.unpack(graph.props);
    settings = GraphPropertySet.unpack(graph.settings);
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

  static Rect getExtents(Iterable<CanvasInteractive> items) {
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

  bool allowAddFlag(NodePort port) {
    if (port == null) return false;
    if (port.node.type != GraphNodeType.action) return false;

    return !links.any((x) => x.inPort.equalTo(port) || x.outPort.equalTo(port));
  }

  void clear() {}
}
