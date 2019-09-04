import 'package:tide_chart/tide_chart.dart';
import 'package:uuid/uuid.dart';

import 'graph_link.dart';
import 'graph_node.dart';

class GraphCommand {
  static TideChartCommand command() {
    return TideChartCommand()..version = Uuid().v1().toString();
  }

  static TideChartCommand all(Iterable<TideChartCommand> cmds) {
    var inner = TideChartGroupCommand()..commands.addAll(cmds);

    return command()..group = inner;
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

  String getVersionLabel() {
    return version.split("-").first;
  }

  void apply(TideChartCommand cmd) {
    if (cmd == null) {
      version = "";
    } else {
      if (cmd.version == null || cmd.version.isEmpty) {
        cmd.version = Uuid().v1().toString();
      }

      version = cmd.version;
    }
  }

  void push(TideChartCommand cmd, {bool clear = true, bool locked = false}) {
    if (cmd.version == null || cmd.version.isEmpty) {
      cmd.version = Uuid().v1().toString();
    }

    // optimize empty and single command groups
    if (cmd.hasGroup()) {
      if (cmd.group.commands.isEmpty) return;
      if (cmd.group.commands.length == 1) {
        return push(cmd.group.commands.first, clear: clear, locked: locked);
      }
    }
    cmd.isLocked = locked;
    undoCmds.add(cmd);
    apply(cmd);
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

  void clear() {
    undoCmds.clear();
    redoCmds.clear();
  }
}
