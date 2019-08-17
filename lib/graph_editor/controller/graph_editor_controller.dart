import 'package:provider/provider.dart';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_browser.dart';
import 'package:tide_ui/graph_editor/controller/radial_menu_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';

import 'package:tide_ui/main.dart' show AppVersion;

import 'canvas_controller.dart';
import 'graph_controller.dart';
import 'library_controller.dart';
import 'graph_editor_comand.dart';
import 'graph_editor_menus.dart';
import 'graph_event.dart';
import 'keyboard_controller.dart';
import 'keyboard_handler.dart';
import 'mouse_controller.dart';
import 'mouse_handler.dart';

class GraphEditorControllerBase {
  final GraphEditorState editor = GraphEditorState();
  final CanvasTabsState tabs = CanvasTabsState(menu: [
    MenuItem(
        name: "app-menu",
        icon: "ellipsisV",
        command: GraphEditorCommand.showAppMenu()),
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
  final LibraryState library = LibraryState();

  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;
  bool get isPanMode => editor.dragMode == GraphDragMode.panning;
  bool get isSelectMode => editor.dragMode == GraphDragMode.selecting;
  bool get isViewMode => editor.dragMode == GraphDragMode.viewing;

  bool get isTouchMode => editor.touchMode;
  bool get isMultiMode => editor.multiMode;
  bool get isModalActive => menu.visible;

  List<GraphEditorCommand> commands = [];
  List<GraphEditorCommand> waiting = [];
  Duration timer = Duration.zero;

  Duration longPressTimeout;
  Duration longPressUpdate = Duration.zero;
  Rect longPressRect = Rect.zero;
  GraphEvent longPressStart = GraphEvent();

  int ticks = 0;

  bool isAutoPanning = false;
  Offset cursor = Offset.zero; // last position of cursor in screen coord
}

class GraphEditorController extends GraphEditorControllerBase
    with
        MouseController,
        KeyboardController,
        GraphEditorMenus,
        GraphEditorBrowser {
  GraphEditorController() {
    editor.controller = this;
    tabs.controller = CanvasTabsController(this);
    graph.controller = GraphController(this);
    canvas.controller = CanvasController(this);
    menu.controller = RadialMenuController(this);
    library.controller = LibraryController(this);

    editor.keyboardHandler = KeyboardHandler(this);
    editor.mouseHandler = MouseHandler(this);

    tabs.version = AppVersion;
    tabs.addListener(onChangeTabs);
    tabs.add(select: true);

    dispatch(GraphEditorCommand.showLibrary(), afterTicks: 5);
    dispatch(GraphEditorCommand.zoomToFit(), afterTicks: 10);
  }

  void handleLongPress() {
    var delta = longPressTimeout - timer;

    if (delta < Duration.zero) {
      graph.controller.onContextMenu(longPressStart);
      cancelLongPress();
      graph.beginUpdate();
      longPressRect = Rect.zero;
      graph.endUpdate(true);
      return;
    }

    if (timer > longPressUpdate) {
      var ratio = 1 -
          delta.inMicroseconds /
              Graph.LongPressDuration.inMicroseconds.toDouble();

      graph.beginUpdate();

      var radius = Graph.LongPressRadius * ratio;
      if (radius > Graph.LongPressStartRadius) {
        graph.controller.longPressRadius = radius;
      }

      graph.controller.longPressPos = longPressStart.pos;

      graph.endUpdate(true);

      longPressUpdate += Graph.LongPressUpdatePeriod;
    }
  }

  void onTick(Duration dt) {
    timer = dt;

    if (longPressTimeout != null) {
      handleLongPress();
    }
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

  void startLongPress(GraphEvent evt) {
    longPressStart = evt;
    longPressTimeout = evt.timer + Graph.LongPressDuration;
    longPressUpdate = evt.timer + Graph.LongPressUpdatePeriod;
    longPressRect = Rect.zero;
  }

  void cancelLongPress() {
    longPressTimeout = null;
    if (graph.controller.longPressRadius > 0) {
      graph.beginUpdate();
      graph.controller.longPressRadius = 0;
      graph.endUpdate(true);
    }
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
      ChangeNotifierProvider(builder: (_) => library),
    ];
  }

  Offset get edgePanOffset {
    if (graph.controller.moveMode == MouseMoveMode.none) return null;

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

  bool onMouseMove(GraphEvent evt) {
    var pt = getPos(evt.pos);
    cursor = pt;

    if ((graph.controller.moveMode != MouseMoveMode.none) && !isAutoPanning) {
      panAtEdges();
    }
    return false;
  }

  @override
  bool onKeyDown(GraphEvent evt) {
    var key = evt.key.toLowerCase();

    if (key == "h") {
      zoomHome();
    }

    if (key == "f") {
      zoomToFit(evt.ctrlKey);
      return true;
    }

    return false;
  }

  void zoomToFit([bool selected = false]) {
    if (graph.nodes.isNotEmpty) {
      var rect = selected ? graph.selectionExtents : graph.extents;
      rect = rect.inflate(50);
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

  bool setMultiMode(bool mode) {
    if (editor.multiMode == mode) return false;
    editor.beginUpdate();
    editor.multiMode = mode;
    editor.endUpdate(true);
    return true;
  }

  bool setTouchMode(bool mode) {
    if (editor.touchMode == mode) return false;
    editor.beginUpdate();
    editor.touchMode = mode;
    editor.moveCounter = 0;
    editor.endUpdate(true);
    return true;
  }

  bool setDragMode(GraphDragMode mode) {
    if (editor.dragMode == mode) return false;

    editor.beginUpdate();
    editor.dragMode = mode;
    editor.endUpdate(true);
    return true;
  }

  void cancelEditing() {
    cancelLongPress();
    editor.beginUpdate();
    graph.beginUpdate();
    graph.controller.moveMode = MouseMoveMode.none;
    graph.controller.selectRect = Rect.zero;
    graph.endUpdate(true);
    editor.endUpdate(true);
  }

  void showLibrary([LibraryDisplayMode mode]) {
    library.beginUpdate();
    if (mode != null) {
      library.controller.setMode(mode);
    }

    library.controller.show();
    library.endUpdate(true);

    if (graph.paddingRight != library.controller.width) {
      graph.beginUpdate();
      graph.paddingRight = library.controller.width;
      graph.endUpdate(true);
    }
  }

  void hideLibrary() {
    library.controller.hide();

    if (graph.paddingRight != library.controller.width) {
      graph.beginUpdate();
      graph.paddingRight = library.controller.width;
      graph.endUpdate(true);
    }
  }
}
