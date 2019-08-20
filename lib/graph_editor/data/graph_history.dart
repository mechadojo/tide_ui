import 'package:tide_chart/tide_chart.dart';
import 'package:uuid/uuid.dart';

import 'graph_link.dart';
import 'graph_node.dart';

class GraphCommand {
  static TideChartCommand command() {
    return TideChartCommand()..version = Uuid().v1().toString();
  }

  static TideChartCommand moveAll(Iterable<GraphNode> nodes) {
    var inner = TideChartGroupCommand()
      ..commands.addAll(nodes.map((x) => GraphCommand.moveNode(x)));

    return command()..group = inner;
  }

  static TideChartCommand moveNode(GraphNode node) {
    var inner = TideChartMoveCommand()
      ..node = node.name
      ..fromPosX = node.dragStart.dx.round()
      ..fromPosY = node.dragStart.dy.round()
      ..toPosX = node.pos.dx.round()
      ..toPosY = node.pos.dy.round();

    return command()..move = inner;
  }

  static TideChartCommand addNode(GraphNode node) {
    var inner = TideChartNodeCommand()
      ..type = TideChartCommandUpdateType.add
      ..toNode = node.pack();

    return command()..node = inner;
  }

  static TideChartCommand removeNode(GraphNode node) {
    var inner = TideChartNodeCommand()
      ..type = TideChartCommandUpdateType.remove
      ..fromNode = node.pack();

    return command()..node = inner;
  }

  static TideChartCommand addLink(GraphLink link) {
    var inner = TideChartLinkCommand()
      ..type = TideChartCommandUpdateType.add
      ..toLink = link.pack();

    return command()..link = inner;
  }

  static TideChartCommand removeLink(GraphLink link) {
    var inner = TideChartLinkCommand()
      ..type = TideChartCommandUpdateType.remove
      ..fromLink = link.pack();

    return command()..link = inner;
  }

  static bool isUpdating(TideChartCommandUpdateType type) {
    return type == TideChartCommandUpdateType.update;
  }

  static bool isNotUpdating(TideChartCommandUpdateType type) {
    return type != TideChartCommandUpdateType.update;
  }

  static bool isAdding(TideChartCommandUpdateType type,
      [bool reversed = false]) {
    if (reversed) {
      return type == TideChartCommandUpdateType.remove;
    } else {
      return type == TideChartCommandUpdateType.add;
    }
  }

  static bool isRemoving(TideChartCommandUpdateType type,
      [bool reversed = false]) {
    if (reversed) {
      return type == TideChartCommandUpdateType.add;
    } else {
      return type == TideChartCommandUpdateType.remove;
    }
  }

  static TideChartNode getNode(TideChartNodeCommand cmd) {
    if (cmd.type == TideChartCommandUpdateType.remove) {
      return cmd.fromNode;
    }

    return cmd.toNode;
  }

  static TideChartLink getLink(TideChartLinkCommand cmd) {
    if (cmd.type == TideChartCommandUpdateType.remove) {
      return cmd.fromLink;
    }

    return cmd.toLink;
  }
}

class GraphHistory {
  String version = "";

  List<TideChartCommand> undoCmds = [];
  List<TideChartCommand> redoCmds = [];

  bool get canRedo => redoCmds.isNotEmpty;
  bool get canUndo => undoCmds.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'version': version,
        'commands': undoCmds,
      };

  void push(TideChartCommand cmd, [bool clear = true]) {
    // optimize empty and single command groups
    if (cmd.hasGroup()) {
      if (cmd.group.commands.isEmpty) return;
      if (cmd.group.commands.length == 1) {
        return push(cmd.group.commands.first, clear);
      }
    }

    undoCmds.add(cmd);
    if (clear) {
      redoCmds.clear();
    }
  }

  TideChartCommand undo() {
    var last = undoCmds.removeLast();
    if (last != null) redoCmds.add(last);
    return last;
  }

  TideChartCommand redo() {
    return redoCmds.removeLast();
  }

  void copy(GraphHistory other) {
    undoCmds = [...other.undoCmds];
    redoCmds = [...other.redoCmds];
  }
}
