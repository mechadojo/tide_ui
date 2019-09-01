import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_event.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'graph_node.dart';
import 'menu_item.dart';
import 'update_notifier.dart';

class LibraryItem extends MenuItem {
  GraphNode node;
  GraphState graph;

  String name;
  bool isDefault = false;
  List<LibraryItem> items = [];

  MenuItem openButton =
      MenuItem(icon: "folder-open", iconAlt: "folder-open-solid");
  MenuItem editButton = MenuItem(icon: "edit");

  MenuItem collapseButton = MenuItem(icon: "caret-up");
  MenuItem expandButton = MenuItem(icon: "caret-down");
  MenuItem get expandoButton => isCollapsed ? expandButton : collapseButton;

  bool collapsed = false;
  bool get isCollapsed => collapsed;
  bool get isExpanded => !collapsed;

  LibraryItem.group(String name, List<GraphNode> nodes) {
    this.name = name;
    this.icon = "cogs";
    items = [...nodes.map((x) => LibraryItem.method(x))];
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

  /// list of files used in Tab-Files mode
  List<MenuItemSet> files = [];

  /// list of files used in Tab-Imports mode
  List<MenuItemSet> imports = [];
  List<MenuItem> importButtons = [];
  
  List<LibraryItem> get behaviors =>
      sheets.where((x) => x.graph?.type == GraphType.behavior).toList();

  List<LibraryItem> get opmodes =>
      sheets.where((x) => x.graph?.type == GraphType.opmode).toList();

  LibraryItem behaviorGroup = LibraryItem.group("Behaviors", []);
  LibraryItem opmodeGroup = LibraryItem.group("OpModes", []);

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
      case LibraryTab.history:
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
