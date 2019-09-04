import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/controller/graph_event.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'graph_history.dart';
import 'graph_node.dart';
import 'menu_item.dart';
import 'update_notifier.dart';

class HistoryItem extends LibraryItem {
  TideChartCommand cmd;
  TideChartLink cmdLink;
  TideChartNode cmdNode;

  bool isUndoItem = true;
  bool get isRedoItem => !isUndoItem;
  int index = 0;
  TideChartCommandUpdateType cmdType;
  String typeIcon;
  String version;

  String getTypeIcon(TideChartCommandUpdateType type) {
    switch (type) {
      case TideChartCommandUpdateType.add:
        return "plus";
      case TideChartCommandUpdateType.remove:
        return "minus";
      case TideChartCommandUpdateType.update:
        return "edit-solid";
    }
    return "question";
  }

  String getTypeName(TideChartCommandUpdateType type) {
    switch (type) {
      case TideChartCommandUpdateType.add:
        return "Add";
      case TideChartCommandUpdateType.remove:
        return "Remove";
      case TideChartCommandUpdateType.update:
        return "Update";
    }
    return "???";
  }

  HistoryItem.command(this.cmd, this.index, {bool undo = true}) {
    isUndoItem = undo;

    if (cmd.hasGroup()) {
      var count = cmd.group.commands.length;
      typeIcon = "archive";
      Set<String> groupTypes = {};
      var groupType = "";
      for (var subcmd in cmd.group.commands) {
        if (subcmd.hasGroup()) groupTypes.add("group");
        if (subcmd.hasMove()) groupTypes.add("move");
        if (subcmd.hasNode()) {
          groupTypes.add("${getTypeName(subcmd.node.type).toLowerCase()} node");
        }
        if (subcmd.hasLink()) {
          groupTypes.add("${getTypeName(subcmd.link.type).toLowerCase()} link");
        }
      }
      if (groupTypes.length == 1) groupType = "${groupTypes.first} ";
      if (groupTypes.length == 2) {
        var first = groupTypes.first;
        var last = groupTypes.last;
        for (var prefix in ["add ", "remove ", "update "]) {
          if (first.startsWith(prefix) && last.startsWith(prefix)) {
            last = last.substring(prefix.length);
          }
        }
        groupType = "${first} and ${last} ";
      }

      if (groupTypes.length > 2) {
        groupType = groupTypes.join(",") + " ";
      }

      title = "${count} ${groupType}commands";
    }

    if (cmd.hasMove()) {
      typeIcon = "arrows-alt";
      title =
          "(${cmd.move.fromPosX}, ${cmd.move.fromPosY}) to (${cmd.move.toPosX}, ${cmd.move.toPosY})";
    }

    if (cmd.hasNode()) {
      cmdType = cmd.node.type;
      cmdNode = GraphCommand.getNode(cmd.node);
      icon = cmdNode.icon;
      title = cmdNode.title == null || cmdNode.title.isEmpty
          ? "Node ${cmdNode.name}"
          : cmdNode.title;
      typeIcon = getTypeIcon(cmdType);
    }

    if (cmd.hasLink()) {
      cmdType = cmd.link.type;
      cmdLink = GraphCommand.getLink(cmd.link);
      icon = "share-alt";
      title = "${cmdLink.outPort} to ${cmdLink.inPort}";
      typeIcon = getTypeIcon(cmdType);
    }
  }
}

class VersionItem extends MenuItem {}

class LibraryItem extends MenuItem {
  GraphNode node;
  GraphState graph;
  GraphSelection selection;

  String name;
  bool isDefault = false;
  List<LibraryItem> items = [];

  MenuItem openButton =
      MenuItem(icon: "folder-open", iconAlt: "folder-open-solid");
  MenuItem editButton = MenuItem(icon: "edit");

  MenuItem collapseButton = MenuItem(icon: "angle-down");
  MenuItem expandButton = MenuItem(icon: "angle-right");
  MenuItem get expandoButton => isCollapsed ? expandButton : collapseButton;

  bool collapsed = false;
  bool get isCollapsed => collapsed;
  bool get isExpanded => !collapsed;

  LibraryItem();
  LibraryItem.selection(GraphSelection selection) {
    this.selection = selection;
    this.name =
        "${selection.nodes.length} nodes - ${selection.links.length} links";
    this.icon = "clipboard-solid";
  }

  LibraryItem.group(String name, List<GraphNode> nodes) {
    this.name = name;
    this.icon = "cogs";
    items = [...nodes.map((x) => LibraryItem.method(x))];
  }

  LibraryItem.widget(this.node) {
    icon = node.icon;
    name = node.hasTitle ? node.title : node.widgetTypeName;
  }

  LibraryItem.node(this.node) {
    icon = node.icon;
    name = node.hasTitle ? node.title : node.name;
  }

  LibraryItem.method(this.node) {
    icon = node.icon;
    name =
        node.hasTitle ? node.title : node.hasMethod ? node.method : node.name;
  }

  LibraryItem.graph(GraphState graph) {
    this.graph = graph;
    icon = graph.icon;
    name = graph.title;
  }

  LibraryItem.library(GraphLibraryState next) {
    graph = next;
    icon = next.icon;
    name = next.title;

    Map<String, List<GraphNode>> groups = {};

    for (var node in graph.nodes) {
      var libname = node.library ?? "";
      if (!groups.containsKey(libname)) {
        groups[libname] = List<GraphNode>();
      }

      // Add a copy of the node so that drag/drop doesn't impact
      // the actual node pos on the library graph
      groups[libname].add(GraphNode.clone(node)..name = GraphNode.randomName());
    }

    var keys = groups.keys.toList();
    keys.sort();
    for (var key in keys) {
      items.add(LibraryItem.group(key, groups[key]));
    }
  }

  GraphNode get dropNode {
    if (graph != null) {
      return GraphNode.behavior(graph);
    }

    return node;
  }
}

class LibraryState extends UpdateNotifier {
  LibraryController controller;

  LibraryTab currentTab = LibraryTab.widgets;

  LibraryDisplayMode mode = LibraryDisplayMode.hidden;
  LibraryDisplayMode lastCollapsed = LibraryDisplayMode.toolbox;
  LibraryDisplayMode lastExpanded = LibraryDisplayMode.expanded;

  /// context menu used to edit items
  MenuItemSet contextMenu;

  /// toolbar of small icon buttoms at top of panel
  List<MenuItem> menu = [];

  /// a second row of small icon buttoms at top of panel
  List<MenuItem> tabs = [];

  /// items displayed in toolbox mode have a hotkey and default tags
  List<LibraryItem> toolbox = [];

  /// collapsed mode displays all the charts defined in this file
  List<LibraryItem> sheets = [];

  /// expanded and detailed modes display groups of items and subgroups
  List<LibraryItem> groups = [];

  // List of clipboard items used int Tab-Clipboard mode
  List<LibraryItem> clipboard = [];

  List<HistoryItem> history = [];

  List<VersionItem> versions = [];

  /// list of files used in Tab-Files mode
  List<MenuItemSet> files = [];

  /// list of files used in Tab-Imports mode
  List<MenuItemSet> imports = [];

  List<MenuItem> importButtons = [];
  List<MenuItem> clipboardButtons = [];
  List<MenuItem> historyButtons = [];
  List<MenuItem> versionButtons = [];

  /// list of widgets used in Tab-Widgets mode
  List<LibraryItem> widgets = [];

  List<LibraryItem> get behaviors =>
      sheets.where((x) => x.graph?.type == GraphType.behavior).toList();

  List<LibraryItem> get opmodes =>
      sheets.where((x) => x.graph?.type == GraphType.opmode).toList();

  LibraryItem behaviorGroup = LibraryItem.group("Behaviors", []);
  LibraryItem opmodeGroup = LibraryItem.group("OpModes", []);
  LibraryItem historyGroup = LibraryItem.group("History", [])..collapsed = true;
  LibraryItem versionGroup = LibraryItem.group("Version", []);
  String graphVersion = "";
  String chartVersion = "";

  Rect hitbox = Rect.zero;

  bool get isCollapsed =>
      mode == LibraryDisplayMode.toolbox ||
      mode == LibraryDisplayMode.collapsed;

  bool get isHidden => mode == LibraryDisplayMode.hidden;

  bool get isExpanded =>
      mode == LibraryDisplayMode.expanded ||
      mode == LibraryDisplayMode.detailed ||
      mode == LibraryDisplayMode.search ||
      mode == LibraryDisplayMode.tabs;

  bool get isHistory =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.history;
  bool get isWidgets =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.widgets;
  bool get isClipboard =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.clipboard;
  bool get isImports =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.imports;
  bool get isFiles =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.files;
  bool get isTemplates =>
      mode == LibraryDisplayMode.tabs && currentTab == LibraryTab.templates;
  bool get isSearch => mode == LibraryDisplayMode.search;
  bool get isDetailed => mode == LibraryDisplayMode.detailed;
  bool get isGrid => mode == LibraryDisplayMode.expanded;
  bool get isToolbox => mode == LibraryDisplayMode.toolbox;
  bool get isBehaviors => mode == LibraryDisplayMode.collapsed;

  LibraryState() {
    int count = 10;
    toolbox = [
      ...GraphState.randomNodes(count).map((x) => LibraryItem.node(x))
    ];
    toolbox[Random().nextInt(count)].isDefault = true;
  }

  void clear() {
    sheets.clear();
    groups.clear();
  }

  bool isModalTab(LibraryTab tab) {
    switch (tab) {
      case LibraryTab.files:
        return true;
      case LibraryTab.templates:
        return true;
      default:
        return false;
    }
  }

  GraphNode getDefaultNode([GraphEvent evt]) {
    if (toolbox.isEmpty) return null;

    var item =
        toolbox.firstWhere((x) => x.isDefault, orElse: () => toolbox.first);
    return item.dropNode;
  }

  GraphNode getToolboxNode([int hotkey = -1, GraphEvent evt]) {
    if (hotkey == -1) return getDefaultNode(evt);

    if (toolbox.isEmpty) return null;

    var item = toolbox[hotkey % toolbox.length];
    return item.dropNode;
  }
}
