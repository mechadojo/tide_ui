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
import 'graph_editor_comand.dart';
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
    MenuItem(
        name: "tab-prev",
        icon: "angleLeft",
        command: GraphEditorCommand.prevTab()),
    MenuItem(
        name: "tab-next",
        icon: "angleRight",
        command: GraphEditorCommand.nextTab()),
    MenuItem(
        name: "tab-new",
        icon: "solidPlusSquare",
        iconAlt: "plusSquare",
        command: GraphEditorCommand.newTab()),
  ]);

  final GraphState graph = GraphState();
  final CanvasState canvas = CanvasState();
  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;

  List<GraphEditorCommand> commands = [];
  List<GraphEditorCommand> waiting = [];
  Duration timer = Duration.zero;
  int ticks = 0;

  GraphEditorController() {
    editor.controller = this;
    tabs.controller = CanvasTabsController(this);
    graph.controller = GraphController(this);
    canvas.controller = CanvasController(this);

    editor.keyboardHandler = KeyboardHandler(this);
    editor.mouseHandler = MouseHandler(this);

    tabs.version = AppVersion;
    tabs.addListener(onChangeTabs);
    tabs.add(select: true);

    dispatch(GraphEditorCommand.zoomToFit(), afterTicks: 3);
  }

  void onTick(Duration dt) {
    timer = dt;

    while (commands.isNotEmpty) {
      var cmd = commands.removeAt(0);
      if (cmd.waitUntil > timer) {
        waiting.add(cmd);
      } else if (cmd.waitTicks != 0 && cmd.waitTicks > ticks) {
        waiting.add(cmd);
      } else if (cmd.condition != null && !cmd.condition(this)) {
        waiting.add(cmd);
      } else {
        cmd.handler(this);
      }
    }

    commands.addAll(waiting);
    waiting.clear();

    ticks++;
  }

  void dispatch(GraphEditorCommand cmd,
      {Duration delay = Duration.zero,
      CommandCondition runWhen,
      int afterTicks = 0}) {
    cmd.waitUntil = timer + delay;
    if (runWhen != null) cmd.condition = runWhen;
    if (afterTicks != 0) cmd.waitTicks = ticks + afterTicks;

    commands.add(cmd);
  }

  void onChangeTabs() {
    editor.onChangeTab(tabs.current, canvas, graph);
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

  @override
  bool onKeyDown(KeyboardEvent evt) {
    var key = evt.key.toLowerCase();

    if (key == "h") {
      zoomHome();
    }
    ;

    if (key == "f") {
      zoomToFit();
      return true;
    }

    return false;
  }

  void zoomToFit() {
    if (graph.nodes.isNotEmpty) {
      var rect = graph.extents.inflate(50);
      canvas.zoomToFit(rect, canvas.size);
    } else {
      zoomHome();
    }
  }

  void zoomHome() {
    canvas.reset();
  }
}
