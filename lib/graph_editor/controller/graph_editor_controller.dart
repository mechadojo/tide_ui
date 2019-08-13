import 'dart:html';
import 'package:provider/provider.dart';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/radial_menu_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';
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

  final RadialMenuState menu = RadialMenuState();

  final GraphState graph = GraphState();
  final CanvasState canvas = CanvasState();
  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;
  bool get isPanMode => editor.dragMode == GraphDragMode.panning;
  bool get isSelectMode => editor.dragMode == GraphDragMode.selecting;
  bool get isViewMode => editor.dragMode == GraphDragMode.viewing;

  bool get isTouchMode => editor.touchMode;
  bool get isModalActive => menu.visible;

  List<GraphEditorCommand> commands = [];
  List<GraphEditorCommand> waiting = [];
  Duration timer = Duration.zero;
  int ticks = 0;

  bool isAutoPanning = false;
  Offset cursor = Offset.zero; // last position of cursor in screen coord

  GraphEditorController() {
    editor.controller = this;
    tabs.controller = CanvasTabsController(this);
    graph.controller = GraphController(this);
    canvas.controller = CanvasController(this);
    menu.controller = RadialMenuController(this);

    editor.keyboardHandler = KeyboardHandler(this);
    editor.mouseHandler = MouseHandler(this);

    tabs.version = AppVersion;
    tabs.addListener(onChangeTabs);
    tabs.add(select: true);

    dispatch(GraphEditorCommand.zoomToFit(), afterTicks: 10);
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
      ChangeNotifierProvider(builder: (_) => menu),
    ];
  }

  Offset get edgePanOffset {
    if (!graph.controller.dragging && !graph.controller.selecting) return null;

    var pt = cursor; // last know cursor position
    var pan = canvas.controller.panRectScreen; // last known visible region

    double dx = 0;
    double dy = 0;

    if (pt.dx < pan.left) dx = pan.left - pt.dx;
    if (pt.dx > pan.right) dx = pan.right - pt.dx;

    if (pt.dy < pan.top) dy = pan.top - pt.dy;
    if (pt.dy > pan.bottom) dy = pan.bottom - pt.dy;

    if (dx != 0 || dy != 0) {
      return Offset(dx, dy);
    }
    return null;
  }

  void panAtEdges() {
    var pos = edgePanOffset;

    if (pos == null) {
      isAutoPanning = false;
      return;
    }

    isAutoPanning = true;
    var rx = (pos.dx / Graph.AutoPanMargin) * Graph.MaxAutoPan;
    var ry = (pos.dy / Graph.AutoPanMargin) * Graph.MaxAutoPan;

    canvas.scrollBy(rx / canvas.scale, ry / canvas.scale);
    dispatch(GraphEditorCommand.autoPan(), delay: Duration(milliseconds: 20));
  }

  bool onMouseMove(MouseEvent evt, Offset pt) {
    cursor = pt;

    if ((graph.controller.dragging || graph.controller.selecting) &&
        !isAutoPanning) {
      panAtEdges();
    }
    return false;
  }

  @override
  bool onKeyDown(KeyboardEvent evt) {
    var key = evt.key.toLowerCase();

    if (key == "h") {
      zoomHome();
    }

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

  void toggleDragMode() {
    var next = editor.dragMode == GraphDragMode.panning
        ? GraphDragMode.selecting
        : editor.dragMode == GraphDragMode.selecting
            ? GraphDragMode.viewing
            : GraphDragMode.panning;

    setDragMode(next);
  }

  void setTouchMode(bool mode) {
    if (editor.touchMode == mode) return;
    editor.beginUpdate();
    editor.touchMode = mode;
    editor.endUpdate(true);
  }

  void setDragMode(GraphDragMode mode) {
    if (editor.dragMode == mode) return;

    editor.beginUpdate();
    editor.dragMode = mode;
    editor.endUpdate(true);
  }

  void showMenu([Offset pt]) {
    graph.controller.moveMode = MouseMoveMode.none;
    graph.controller.clearSelection();

    menu.beginUpdate();
    menu.clearInteractive(); // clears ui interactive states

    moveMenu(pt);

    menu.controller.allowClose = false;
    menu.visible = true;
    menu.endUpdate(true);
  }

  void moveMenu(Offset pt) {
    tabs.beginUpdate();

    if (pt != null) {
      var sz = Graph.RadialMenuSize * 2;

      var rect = Rect.fromCenter(center: pt, width: sz, height: sz);
      var limits = canvas.controller.menuLimits;

      var dx = rect.left < limits.left ? limits.left - rect.left : 0;
      var dy = rect.top < limits.top ? limits.top - rect.top : 0;
      dx = rect.right > limits.right ? limits.right - rect.right : dx;
      dy = rect.bottom > limits.bottom ? limits.bottom - rect.bottom : dy;

      menu.moveTo(pt.translate(dx, dy));
    }

    tabs.endUpdate(true);
  }

  void hideMenu({bool resetMoveMode = true, bool resetPanning = true}) {
    if (resetMoveMode) {
      graph.controller.moveMode = MouseMoveMode.none;
    }

    menu.beginUpdate();
    menu.visible = false;
    menu.endUpdate(true);

    if (resetPanning) {
      canvas.controller.stopPanning();
    }
  }

  void openMenu(MenuItemSet items, [Offset pt, bool resetStack = true]) {
    menu.beginUpdate();
    if (resetStack) {
      menu.controller.menuStack.clear();
    }

    menu.controller.openMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }

    menu.endUpdate(true);
  }

  void pushMenu(MenuItemSet items, [Offset pt]) {
    menu.beginUpdate();
    menu.controller.pushMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }
    menu.endUpdate(true);
  }

  void popMenu([bool autoClose = false]) {
    menu.beginUpdate();
    var last = menu.controller.popMenu();
    if (last == null) {
      if (autoClose) {
        hideMenu();
      }
    } else {
      if (!menu.visible) {
        showMenu();
      }
    }

    menu.endUpdate(true);
  }

  MenuItemSet getNodeMenu(GraphNode node) {
    switch (node.type) {
      case GraphNodeType.action:
        return MenuItemSet([
          MenuItem(icon: "edit"),
          MenuItem(icon: "chevron-circle-right"),
          MenuItem(icon: "trash-alt"),
          MenuItem(icon: "chevron-circle-left"),
        ]);
      default:
        return MenuItemSet([
          MenuItem(icon: "edit"),
          MenuItem(icon: "trash-alt"),
        ]);
    }
  }

  MenuItemSet getGraphMenu(GraphState graph) {
    return MenuItemSet([
      MenuItem(icon: "edit"),
      MenuItem(icon: "save"),
      MenuItem(icon: "upload"),
      MenuItem(icon: "mobile-alt"),
    ]);
  }
}
