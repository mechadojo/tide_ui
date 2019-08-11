import 'dart:html';
import 'package:provider/provider.dart';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/main.dart' show AppVersion;

import 'canvas_controller.dart';
import 'graph_controller.dart';
import 'keyboard_controller.dart';
import 'keyboard_handler.dart';
import 'mouse_controller.dart';
import 'mouse_handler.dart';

class GraphEditorController with MouseController, KeyboardController {
  final GraphEditorState editor = GraphEditorState();
  final CanvasTabsState tabs = CanvasTabsState(menu: [
    MenuItem(name: "app-menu", icon: "ellipsisV"),
    MenuItem(name: "save", icon: "solidSave", iconAlt: "save"),
    MenuItem(name: "open", icon: "solidFolderOpen", iconAlt: "folderOpen"),
    MenuItem(name: "tab-prev", icon: "angleLeft"),
    MenuItem(name: "tab-next", icon: "angleRight"),
    MenuItem(name: "tab-new", icon: "solidPlusSquare", iconAlt: "plusSquare"),
  ]);

  final GraphState graph = GraphState();
  final CanvasState canvas = CanvasState();
  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;

  void onChangeTabs() {
    editor.onChangeTab(tabs.current, canvas, graph);
  }

  GraphEditorController() {
    editor.controller = this;
    tabs.controller = CanvasTabsController(tabs);
    graph.controller = GraphController(graph);
    canvas.controller = CanvasController(canvas);

    editor.keyboardHandler = KeyboardHandler(this);
    editor.mouseHandler = MouseHandler(this);

    tabs.version = AppVersion;
    tabs.addListener(onChangeTabs);
    tabs.add(select: true);
  }

  List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => editor),
      ChangeNotifierProvider(builder: (_) => canvas),
      ChangeNotifierProvider(builder: (_) => tabs),
      ChangeNotifierProvider(builder: (_) => graph),
    ];
  }

  bool onMouseMove(MouseEvent evt, Offset pt) {
    if (graph.controller.dragging) {
      var pan = canvas.controller.panRect;
      double dx = 0;
      double dy = 0;

      if (pt.dx < pan.left) dx = pan.left - pt.dx;
      if (pt.dx > pan.right) dx = pan.right - pt.dx;

      if (pt.dy < pan.top) dy = pan.top - pt.dy;
      if (pt.dy > pan.bottom) dy = pan.bottom - pt.dy;

      var limit = Graph.MaxAutoPan;
      if (dx.abs() > limit) {
        dx = limit * dx.sign;
      }

      if (dy.abs() > limit) {
        dy = limit * dy.sign;
      }

      if (dx != 0 || dy != 0) {
        print("Scroll $dx, $dy");
        canvas.scrollBy(dx, dy);
      }
    }
    return false;
  }
}
