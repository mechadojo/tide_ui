import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_event.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
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

  MenuItem editButton = MenuItem(icon: "edit");
  MenuItem deleteButton = MenuItem(icon: "times");

  LibraryItem.node(this.node) {
    icon = node.icon;
    name = node.hasTitle ? node.title : node.name;
  }

  LibraryItem.graph(GraphState graph) {
    this.graph = graph;
    icon = graph.icon;
    name = graph.title;
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

  LibraryDisplayMode mode = LibraryDisplayMode.hidden;
  LibraryDisplayMode lastCollapsed = LibraryDisplayMode.toolbox;
  LibraryDisplayMode lastExpanded = LibraryDisplayMode.expanded;

  /// context menu used to edit items
  MenuItemSet contextMenu;

  /// toolbar of small icon buttoms at top of panel
  List<MenuItem> menu = [];

  /// track location of headers in expanded and detailed modes
  List<MenuItem> headers = [];

  /// items displayed in toolbox mode have a hotkey and default tags
  List<LibraryItem> toolbox = [];

  /// collapsed mode displays all the charts defined in this file
  List<LibraryItem> sheets = [];

  /// expanded and detailed modes display groups of items and subgroups
  List<LibraryItem> groups = [];

  List<LibraryItem> get behaviors =>
      sheets.where((x) => x.graph?.type == GraphType.behavior).toList();

  List<LibraryItem> get opmodes =>
      sheets.where((x) => x.graph?.type == GraphType.opmode).toList();

  Rect hitbox = Rect.zero;

  bool get isCollapsed =>
      mode == LibraryDisplayMode.toolbox ||
      mode == LibraryDisplayMode.collapsed;

  bool get isHidden => mode == LibraryDisplayMode.hidden;

  bool get isExpanded =>
      mode == LibraryDisplayMode.expanded ||
      mode == LibraryDisplayMode.detailed;

  LibraryState() {
    int count = 10;
    toolbox = [
      ...GraphState.randomNodes(count).map((x) => LibraryItem.node(x))
    ];
    toolbox[Random().nextInt(count)].isDefault = true;
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
