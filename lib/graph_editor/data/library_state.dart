import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'graph_node.dart';
import 'menu_item.dart';
import 'update_notifier.dart';

class LibraryItem extends MenuItem {
  GraphNode node;
  String name;
  bool isDefault = false;
  List<LibraryItem> items = [];

  LibraryItem.node(this.node) {
    icon = node.icon;
    name = node.hasTitle ? node.title : node.name;
  }
}

class LibraryState extends UpdateNotifier {
  LibraryController controller;

  bool get isCollapsed =>
      mode == LibraryDisplayMode.toolbox ||
      mode == LibraryDisplayMode.collapsed;

  bool get isHidden => mode == LibraryDisplayMode.hidden;

  bool get isExpanded =>
      mode == LibraryDisplayMode.expanded ||
      mode == LibraryDisplayMode.detailed;

  LibraryDisplayMode mode = LibraryDisplayMode.hidden;
  LibraryDisplayMode lastCollapsed = LibraryDisplayMode.toolbox;
  LibraryDisplayMode lastExpanded = LibraryDisplayMode.expanded;

  List<MenuItem> menu = [];
  List<MenuItem> headers = [];

  List<LibraryItem> toolbox = [];
  List<LibraryItem> tabs = [];
  List<LibraryItem> groups = [];

  Rect hitbox = Rect.zero;

  LibraryState() {
    toolbox = [...GraphState.random(10).map((x) => LibraryItem.node(x))];
    toolbox[Random().nextInt(10)].isDefault = true;
  }
}
