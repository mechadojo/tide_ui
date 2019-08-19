import 'package:flutter_web/material.dart';
import 'package:uuid/uuid.dart';

import 'graph_link.dart';
import 'graph_node.dart';

class GraphCommand {
  String version = Uuid().v1().toString();
  String source;

  static GraphCommand none = GraphCommand();
  String get name => "none";

  GraphCommand get reverse {
    return GraphCommand.none;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'source': source,
        'name': name,
      };
}

class GraphCommandGroup extends GraphCommand {
  List<GraphCommand> cmds = [];
  @override
  String get name => "group";

  bool get isNotEmpty => cmds.isNotEmpty;
  bool get isEmpty => cmds.isEmpty;
  int get length => cmds.length;

  GraphCommandGroup();
  GraphCommandGroup.all(Iterable<GraphCommand> source) {
    cmds = [...source];
  }

  GraphCommandGroup.moveAll(Iterable<GraphNode> nodes) {
    cmds = [...nodes.map((x) => GraphMoveCommand.node(x))];
  }

  void add(GraphCommand cmd) {
    cmds.add(cmd);
  }

  void addAll(Iterable<GraphCommand> source) {
    cmds.addAll(source);
  }

  void clear() {
    cmds.clear();
  }

  Map<String, dynamic> toJson() {
    var result = super.toJson();
    result.addAll({"cmds": cmds});
    return result;
  }

  @override
  GraphCommand get reverse {
    return GraphCommandGroup.all(cmds.map((x) => x.reverse))..version = version;
  }
}

class GraphMoveCommand extends GraphCommand {
  RefGraphNode node;
  Offset fromPos = Offset.zero;
  Offset toPos = Offset.zero;

  GraphMoveCommand();
  GraphMoveCommand.node(GraphNode node) {
    this.node = node.ref();
    this.fromPos = node.dragStart;
    this.toPos = node.pos;
  }

  @override
  String get name => "move";

  @override
  GraphCommand get reverse {
    return GraphMoveCommand()
      ..node = node
      ..fromPos = toPos
      ..toPos = fromPos
      ..version = version;
  }

  Map<String, dynamic> toJson() {
    var result = super.toJson();
    result.addAll({
      "node": node.name,
      "fromPos": [fromPos.dx, fromPos.dy],
      "toPos": [toPos.dx, toPos.dy],
    });

    return result;
  }
}

class GraphNodeCommand extends GraphCommand {
  String type;
  PackedGraphNode node;

  GraphNodeCommand();

  GraphNodeCommand.add(GraphNode node) {
    type = "add";
    this.node = node.pack();
  }

  GraphNodeCommand.remove(GraphNode node) {
    type = "remove";
    this.node = node.pack();
  }

  @override
  String get name => "$type-node";

  @override
  GraphCommand get reverse {
    return GraphNodeCommand()
      ..type = type == "add" ? "remove" : "add"
      ..node = node
      ..version = version;
  }

  Map<String, dynamic> toJson() {
    var result = super.toJson();
    result.addAll({
      "node": node,
      "type": type,
    });

    return result;
  }
}

class GraphLinkCommand extends GraphCommand {
  String type;

  PackedGraphLink link;

  GraphLinkCommand();
  GraphLinkCommand.add(GraphLink link) {
    type = "add";
    this.link = link.pack();
  }

  GraphLinkCommand.remove(GraphLink link) {
    type = "remove";
    this.link = link.pack();
  }

  @override
  String get name => "$type-link";

  @override
  GraphCommand get reverse {
    return GraphLinkCommand()
      ..type = type == "add" ? "remove" : "add"
      ..link = link
      ..version = version;
  }

  Map<String, dynamic> toJson() {
    var result = super.toJson();
    result.addAll({
      "link": link,
      "type": type,
    });

    return result;
  }
}

class GraphHistory {
  String version = "";

  List<GraphCommand> undoCmds = [];
  List<GraphCommand> redoCmds = [];

  bool get canRedo => redoCmds.isNotEmpty;
  bool get canUndo => undoCmds.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'version': version,
        'commands': undoCmds,
      };

  void push(GraphCommand cmd, [bool clear = true]) {
    // optimize empty and single command groups
    if (cmd is GraphCommandGroup) {
      if (cmd.isEmpty) return;
      if (cmd.length == 1) {
        return push(cmd.cmds.first, clear);
      }
    }

    undoCmds.add(cmd);
    if (clear) {
      redoCmds.clear();
    }
  }

  GraphCommand undo() {
    var last = undoCmds.removeLast();
    if (last != null) redoCmds.add(last);
    return last;
  }

  GraphCommand redo() {
    return redoCmds.removeLast();
  }

  void copy(GraphHistory other) {
    undoCmds = [...other.undoCmds];
    redoCmds = [...other.redoCmds];
  }
}
