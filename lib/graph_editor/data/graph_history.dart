import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';
import 'package:uuid/uuid.dart';

import 'graph_link.dart';
import 'graph_node.dart';

class GraphCommand {
  String version = Uuid().v1().toString();
  String target;

  static GraphCommand none = GraphCommand();
  String get name => "none";

  GraphCommand();

  factory GraphCommand.chart(TideChartCommand cmd) {
    GraphCommand result;

    switch (cmd.whichCommand()) {
      case TideChartCommand_Command.group:
        result = GraphCommandGroup.chart(cmd.group);
        break;
      case TideChartCommand_Command.move:
        result = GraphMoveCommand.chart(cmd.move);
        break;

      case TideChartCommand_Command.link:
        result = GraphLinkCommand.chart(cmd.link);
        break;
      case TideChartCommand_Command.node:
        result = GraphNodeCommand.chart(cmd.node);
        break;

      default:
        result = GraphCommand();
        break;
    }

    result.version = cmd.version;
    result.target = cmd.target;
    return result;
  }

  GraphCommand get reverse {
    return GraphCommand.none;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'target': target,
        'name': name,
      };

  TideChartCommand toChart() {
    TideChartCommand result = TideChartCommand();
    if (version != null) result.version = version;
    if (target != null) result.target = target;
    return result;
  }

  TideChartCommandUpdateType toUpdateType(String type) {
    switch (type) {
      case "add":
        return TideChartCommandUpdateType.add;
      case "remove":
        return TideChartCommandUpdateType.remove;
      case "update":
        return TideChartCommandUpdateType.update;
    }

    return null;
  }
}

class GraphCommandGroup extends GraphCommand {
  List<GraphCommand> cmds = [];
  @override
  String get name => "group";

  bool get isNotEmpty => cmds.isNotEmpty;
  bool get isEmpty => cmds.isEmpty;
  int get length => cmds.length;

  GraphCommandGroup();
  GraphCommandGroup.chart(TideChartGroupCommand group) {
    cmds = group.commands.map((x) => GraphCommand.chart(x));
  }

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
  TideChartCommand toChart() {
    TideChartCommand result = super.toChart();

    result.group = TideChartGroupCommand()
      ..commands.addAll(cmds.map((x) => x.toChart()));

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
  GraphMoveCommand.chart(TideChartMoveCommand move) {
    node = RefGraphNode()..name = move.node;
    fromPos = Offset(move.fromPosX.toDouble(), move.fromPosY.toDouble());
    toPos = Offset(move.toPosX.toDouble(), move.toPosY.toDouble());
  }

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

  @override
  TideChartCommand toChart() {
    TideChartCommand result = super.toChart();
    result.move = TideChartMoveCommand()
      ..node = node.name
      ..fromPosX = fromPos.dx.round()
      ..fromPosY = fromPos.dy.round()
      ..toPosX = toPos.dx.round()
      ..toPosY = toPos.dy.round();

    return result;
  }
}

class GraphNodeCommand extends GraphCommand {
  String type;

  PackedGraphNode node;
  PackedGraphNode last;

  GraphNodeCommand();

  GraphNodeCommand.chart(TideChartNodeCommand cmd) {
    type = cmd.type.name;

    if (cmd.hasToNode()) {
      node = PackedGraphNode.chart(cmd.toNode);
    }

    if (cmd.hasFromNode()) {
      if (type == "remove") {
        node = PackedGraphNode.chart(cmd.fromNode);
      } else {
        last = PackedGraphNode.chart(cmd.fromNode);
      }
    }
  }

  GraphNodeCommand.add(GraphNode node) {
    type = "add";
    this.node = node.pack();
    node.last = this.node;
  }

  GraphNodeCommand.remove(GraphNode node) {
    type = "remove";
    this.node = node.pack();
    node.last = this.node;
  }

  GraphNodeCommand.update(GraphNode node) {
    type = "remove";

    this.node = node.pack();
    this.last = node.last;
    node.last = this.node;
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

  @override
  TideChartCommand toChart() {
    TideChartCommand result = super.toChart();
    result.node = TideChartNodeCommand()..type = toUpdateType(type);

    if (type == "add") {
      result.node.toNode = node.toChart();
    } else if (type == "remove") {
      result.node.fromNode = node.toChart();
    } else {
      var changes = node.toChanges(last);
      result.node.fromNode = changes.first;
      result.node.toNode = changes.last;
    }

    return result;
  }
}

class GraphLinkCommand extends GraphCommand {
  String type;

  PackedGraphLink link;
  PackedGraphLink last;

  GraphLinkCommand();
  GraphLinkCommand.chart(TideChartLinkCommand cmd) {
    type = cmd.type.name;

    if (cmd.hasToLink()) {
      link = PackedGraphLink.chart(cmd.toLink);
    }

    if (cmd.hasFromLink()) {
      if (type == "remove") {
        link = PackedGraphLink.chart(cmd.fromLink);
      } else {
        last = PackedGraphLink.chart(cmd.fromLink);
      }
    }
  }

  GraphLinkCommand.add(GraphLink link) {
    type = "add";
    this.link = link.pack();
    link.last = this.link;
  }

  GraphLinkCommand.remove(GraphLink link) {
    type = "remove";
    this.link = link.pack();
    link.last = this.link;
  }

  GraphLinkCommand.update(GraphLink link) {
    type = "update";
    this.link = link.pack();
    this.last = link.last;
    link.last = this.link;
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

  @override
  TideChartCommand toChart() {
    TideChartCommand result = super.toChart();

    result.link = TideChartLinkCommand()..type = toUpdateType(type);

    if (type == "add") {
      result.link.toLink = link.toChart();
    } else if (type == "remove") {
      result.link.fromLink = link.toChart();
    } else {
      var changes = link.toChanges(last);
      result.link.fromLink = changes.first;
      result.link.toLink = changes.last;
    }

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
