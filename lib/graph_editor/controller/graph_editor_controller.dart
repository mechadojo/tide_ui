import 'package:provider/provider.dart';
import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';

import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_browser.dart';
import 'package:tide_ui/graph_editor/controller/radial_menu_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/canvas_tab.dart';

import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_file.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/data/focus_state.dart';
import 'package:tide_ui/graph_editor/edit_node_dialog.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'package:tide_ui/main.dart' show AppVersion;
import 'package:uuid/uuid.dart';

import 'canvas_controller.dart';
import 'graph_controller.dart';
import 'graph_editor_filesource.dart';
import 'library_controller.dart';
import 'graph_editor_comand.dart';
import 'graph_editor_menus.dart';
import 'graph_event.dart';
import 'keyboard_controller.dart';
import 'keyboard_handler.dart';
import 'mouse_controller.dart';
import 'mouse_handler.dart';

typedef GraphDialogResult(bool save);
typedef GraphTabFocus(bool reverse);
typedef GraphAutoComplete(bool reverse);

class GraphEditorControllerBase {
  final GraphEditorState editor = GraphEditorState();
  final CanvasTabsState tabs = CanvasTabsState(menu: [
    MenuItem(
      name: "app-menu",
      icon: "ellipsisV",
    ),
    MenuItem(
        name: "save",
        icon: "solidSave",
        iconAlt: "save",
        command: GraphEditorCommand.saveFile()),
    MenuItem(
        name: "open",
        icon: "solidFolderOpen",
        iconAlt: "folderOpen",
        command: GraphEditorCommand.openFile()),
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
  final LongPressFocusState longPress = LongPressFocusState();

  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;
  bool get isPanMode => editor.dragMode == GraphDragMode.panning;
  bool get isSelectMode => editor.dragMode == GraphDragMode.selecting;
  bool get isViewMode => editor.dragMode == GraphDragMode.viewing;

  bool get isTouchMode => editor.touchMode;
  bool get isMultiMode => editor.multiMode;
  bool get isModalActive => menu.visible || bottomSheetActive;

  TideChartFile chartFile = TideChartFile()
    ..id = Uuid().v1().toString()
    ..name = "tide_${GraphNode.randomName()}.chart";

  List<GraphEditorCommand> commands = [];
  List<GraphEditorCommand> waiting = [];
  Duration timer = Duration.zero;
  int nextSheet = 1;
  int ticks = 0;

  String platform;
  bool isAutoPanning = false;
  Offset cursor = Offset.zero; // last position of cursor in screen coord
  FileSourceType lastSource = FileSourceType.local;

  final scaffold = GlobalKey<ScaffoldState>();
  bool bottomSheetActive = false;
  double bottomSheetHeight = 0;
  GraphDialogResult closeBottomSheet;
  GraphTabFocus tabFocus;
  GraphAutoComplete autoComplete;
}

class GraphEditorController extends GraphEditorControllerBase
    with
        MouseController,
        KeyboardController,
        GraphEditorMenus,
        GraphEditorFileSource,
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

    longPress.editor = this;

    tabs.version = AppVersion;
    tabs.addListener(onChangeTabs);

    //
    // Dispatch some startup commands in the future after
    // everything has painted at least once
    //

    dispatch(GraphEditorCommand.restoreCharts(), afterTicks: 5);

    dispatch(GraphEditorCommand.showLibrary(LibraryDisplayMode.collapsed),
        afterTicks: 5);
  }

  void newFile() {
    chartFile = TideChartFile()
      ..id = Uuid().v1().toString()
      ..name = "tide_${GraphNode.randomName()}.chart";
    nextSheet = 0;
    loadChart();
  }

  void loadChart() {
    beginUpdateAll();

    setTitle("Tide Chart Editor - ${chartFile.name}");
    var file = GraphFile(chartFile.chart);

    editor.tabs.clear();
    tabs.clear();
    library.sheets.clear();
    if (file.sheets.isEmpty) {
      newTab();
    }

    for (var sheet in file.sheets) {
      var tab = CanvasTab();

      tab.graph.unpackGraph(sheet);

      if (tab.graph.nodes.isNotEmpty) {
        tab.graph.layout();
        var rect = tab.graph.extents.inflate(50);
        tab.canvas.zoomToFit(rect, canvas.size);
      }

      editor.tabs[tab.graph.name] = tab;

      if (tabs.isEmpty) {
        editor.currentTab = tab;
        tabs.addTab(tab, true, false);
        graph.copy(tab.graph);
        canvas.copy(tab.canvas);
      }

      library.controller.addSheet(tab.graph);
    }

    endUpdateAll();
  }

  void beginUpdateAll() {
    editor.beginUpdate();
    tabs.beginUpdate();
    canvas.beginUpdate();
    library.beginUpdate();
    graph.beginUpdate();
  }

  void endUpdateAll() {
    graph.endUpdate(true);
    library.endUpdate(true);
    canvas.endUpdate(true);
    tabs.endUpdate(true);
    editor.endUpdate(true);
  }

  void handleLongPress() {
    if (!longPress.active) return;

    bool changed = false;
    longPress.beginUpdate();
    changed = longPress.checkUpdate(timer);
    longPress.endUpdate(changed);
  }

  void onTick(Duration dt) {
    timer = dt;

    handleLongPress();

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
    if (cmd == null) return;

    cmd.waitUntil = timer + delay;
    if (runWhen != null) cmd.condition = runWhen;
    if (afterTicks != 0) cmd.waitTicks = ticks + afterTicks;

    commands.add(cmd);
  }

  void saveChanges() {
    editor.saveChanges();
  }

  void previewDrop(GraphSelection dropping) {
    graph.controller.previewDrop(dropping);
  }

  void cancelDrop() {
    graph.controller.cancelDrop();
  }

  void startDrop(GraphSelection dropping) {
    graph.controller.startDrop(dropping);
  }

  void endDrop(GraphSelection dropping) {
    graph.controller.endDrop(dropping);
  }

  void startLongPress(GraphEvent evt) {
    longPress.beginUpdate();
    longPress.start(evt, Graph.LongPressDuration);
    longPress.endUpdate(true);
  }

  void cancelLongPress() {
    if (!longPress.active) return;

    longPress.beginUpdate();
    longPress.cancel();
    longPress.endUpdate(true);
  }

  void checkLongPress(GraphEvent evt) {
    if (!longPress.active) return;

    var changed = false;
    longPress.beginUpdate();
    changed = longPress.checkEvent(evt);
    longPress.endUpdate(changed);
  }

  void onChangeTabs() {
    library.beginUpdate();
    editor.onChangeTab(tabs.current, canvas, graph);
    library.endUpdate(library.controller.update());
  }

  List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => editor),
      ChangeNotifierProvider(builder: (_) => canvas),
      ChangeNotifierProvider(builder: (_) => tabs),
      ChangeNotifierProvider(builder: (_) => graph),
      ChangeNotifierProvider(builder: (_) => menu),
      ChangeNotifierProvider(builder: (_) => library),
      ChangeNotifierProvider(builder: (_) => longPress),
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

    if (key == "o" && evt.ctrlKey) {
      editor.dispatch(GraphEditorCommand.openFile());
      return true;
    }

    if (key == "s" && evt.ctrlKey) {
      editor.dispatch(GraphEditorCommand.saveFile());
      return true;
    }

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

    library.beginUpdate(); // library displays hover labels in touch mode
    library.endUpdate(true);
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

    if (graph.controller.paddingRight != library.controller.width) {
      graph.beginUpdate();
      graph.controller.paddingRight = library.controller.width;
      graph.endUpdate(true);
    }
  }

  void hideLibrary() {
    library.controller.hide();

    if (graph.controller.paddingRight != library.controller.width) {
      graph.beginUpdate();
      graph.controller.paddingRight = library.controller.width;
      graph.endUpdate(true);
    }
  }

  void newTab([bool random = false]) {
    editor.beginUpdate();

    var tab = CanvasTab();
    var graph = (random ? GraphState.random() : GraphState())
      ..name = GraphNode.randomName()
      ..icon = VectorIcons.getRandomName()
      ..title = "Untitled - ${nextSheet++}";

    tab.graph.copy(graph);
    if (graph.nodes.isNotEmpty) {
      graph.layout();
      var rect = graph.extents.inflate(50);
      tab.canvas.zoomToFit(rect, canvas.size);
    }

    editor.tabs[tab.name] = tab;

    tabs.beginUpdate();
    tabs.addTab(tab, true);
    library.controller.addSheet(tab.graph);
    tabs.endUpdate(true);

    editor.endUpdate(true);
  }

  bool isTabSelected(String name) {
    return tabs.selected == name;
  }

  void showTab(String name, {bool reload = false}) {
    if (tabs.selected == name && !reload) return;
    if (!editor.tabs.containsKey(name)) return;

    tabs.beginUpdate();
    if (tabs.hasTab(name)) {
      tabs.select(name);
    } else {
      var tab = editor.tabs[name];

      tab.graph.layout();
      var rect = tab.graph.extents.inflate(50);
      tab.canvas.zoomToFit(rect, canvas.size);

      tabs.addTab(tab, true);
    }

    for (var item in tabs.interactive()) {
      item.clearInteractive();
    }

    tabs.endUpdate(true);
  }

  void addNode(GraphNode node,
      {List<GraphLink> links, bool drag = false, double offset = 0}) {
    graph.beginUpdate();

    if (drag) {
      var gpt = canvas.controller.toGraphCoord(cursor);

      if (isTouchMode) {
        gpt = gpt.translate(node.size.width * offset, 0);
        node.moveTo(gpt.dx, gpt.dy);
      } else {
        node.moveTo(gpt.dx, gpt.dy);

        graph.controller.setSelection(node);
        bool mouseDown = graph.controller.moveMode != MouseMoveMode.none;
        graph.controller.startDragging(gpt);
        graph.controller.dragRelease = mouseDown ? 0 : 1;
        graph.controller.dragDrop = true;
      }
    }

    graph.controller.addNode(node, links: links);

    graph.endUpdate(true);
  }

  void editNode(GraphNode node) {
    bottomSheetActive = true;
    var rect = graph.getExtents(node.walkNode());
    var pos = canvas.pos;
    var scale = canvas.scale;

    canvas.zoomToFit(
        rect.inflate(25),
        Size(canvas.size.width,
            canvas.size.height - EditNodeDialog.EditNodeDialogHeight));

    var controller = scaffold.currentState.showBottomSheet((context) {
      return EditNodeDialog(this, node, closeBottomSheet);
    });

    controller.closed.then((evt) {
      controller = null;
      if (closeBottomSheet != null) {
        print("Swipe closing bottom");
        closeBottomSheet(true);
      }
    });

    closeBottomSheet = (bool save) {
      canvas.beginUpdate();
      canvas.pos = pos;
      canvas.scale = scale;
      canvas.endUpdate(true);
      bottomSheetActive = false;

      closeBottomSheet = null;
      autoComplete = null;
      tabFocus = null;

      if (controller != null) {
        controller.close();
      }
    };
  }
}
