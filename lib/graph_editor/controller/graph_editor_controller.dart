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
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/data/focus_state.dart';
import 'package:tide_ui/graph_editor/edit_graph_dialog.dart';
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
typedef GraphKeyPress(GraphEvent evt);

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

  CanvasTab get selected {
    var name = tabs.selected;
    if (name == null) return null;
    return editor.tabs[name];
  }

  GraphState graph;
  CanvasState canvas;
  CanvasController canvasController;
  GraphController graphController;

  GraphStateNotifier graphNotifier;
  CanvasStateNotifier canvasNotifier;

  final RadialMenuState menu = RadialMenuState();

  final LibraryState library = LibraryState();
  final LongPressFocusState longPress = LongPressFocusState();

  KeyboardHandler get keyboardHandler => editor.keyboardHandler;
  MouseHandler get mouseHandler => editor.mouseHandler;
  bool get isPanMode => editor.dragMode == GraphDragMode.panning;
  bool get isSelectMode => editor.dragMode == GraphDragMode.selecting;
  bool get isViewMode => editor.dragMode == GraphDragMode.viewing;

  bool get isTouchMode => editor.touchMode;
  bool get isMultiMode => editor.multiMode;
  bool get isModalActive => menu.visible || bottomSheetActive || dialogActive;

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
  bool dialogActive = false;
  bool bottomSheetActive = false;
  double bottomSheetHeight = 0;
  GraphDialogResult closeBottomSheet;
  GraphTabFocus tabFocus;
  GraphAutoComplete autoComplete;
  GraphKeyPress modalKeyHandler;

  List<TideChartProperty> nodePropsClipboard = [];
  List<TideChartProperty> graphPropsClipboard = [];

  List<GraphSelection> clipboard = [];
  int pasteIndex = 0;
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

    graphController = GraphController(this);
    canvasController = CanvasController(this);

    tabs.controller = CanvasTabsController(this);
    menu.controller = RadialMenuController(this);
    library.controller = LibraryController(this)
      ..addWidgets([GraphNode.gamepad()]);

    editor.keyboardHandler = KeyboardHandler(this);
    editor.mouseHandler = MouseHandler(this);

    graphNotifier = GraphStateNotifier(this);
    canvasNotifier = CanvasStateNotifier(this);

    longPress.editor = this;

    tabs.version = AppVersion;
    // tabs.addListener(onChangeTabs);

    //
    // Dispatch some startup commands in the future after
    // everything has painted at least once
    //

    newTab();

    dispatch(
        GraphEditorCommand.restoreCharts()
          ..then(GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
              tab: LibraryTab.widgets)),
        afterTicks: 5);
  }

  void setModalKeyHandler(GraphKeyPress handler) {
    modalKeyHandler = handler;
  }

  void newFile() {
    chartFile = TideChartFile()
      ..id = Uuid().v1().toString()
      ..name = "tide_${GraphNode.randomName()}.chart"
      ..chart = GraphFile.empty().toChart();

    nextSheet = 0;
    loadChart();
  }

  CanvasTab loadGraph(TideChartGraph graph) {
    var tab = CanvasTab(this, GraphState()..unpackGraph(graph));
    tab.zoomToFit();

    // graph names need to be unique and we cannot easily rename
    // them because they are used as references
    editor.tabs[tab.graph.name] = tab;

    return tab;
  }

  CanvasTab loadLibrary(TideChartLibrary library,
      {bool imported = false, String source}) {
    var tab = CanvasTab(
        this,
        GraphLibraryState()
          ..unpackLibrary(library)
          ..imported = imported
          ..source = source);

    tab.zoomToFit();

    // graph names need to be unique, however, library graph names
    // are not used directly so we can just rename them during loading
    while (editor.tabs.containsKey(tab.graph.name)) {
      tab.graph.name = GraphNode.randomName();
    }

    editor.tabs[tab.graph.name] = tab;

    return tab;
  }

  void loadChart() async {
    beginUpdateAll();

    setTitle("Tide Chart Editor - ${chartFile.name}");
    var file = GraphFile(chartFile.chart);

    editor.tabs.clear();
    tabs.clear();
    library.clear();

    for (var item in file.sheets) {
      var tab = loadGraph(item);
      library.controller.addSheet(tab.graph);
    }

    for (var item in file.library) {
      var tab = loadLibrary(item);
      library.controller.addLibrary(tab.graph);
    }

    if (file.sheets.isEmpty) {
      if (file.library.isEmpty) {
        newTab();
      } else {
        var name = file.library.first.methods.name;
        selectTab(name);
      }
    } else {
      var first = file.sheets.firstWhere((x) => x.type == "opmode",
          orElse: () => file.sheets.first);

      selectTab(first.name);
    }

    editor.imports.clear();

    var skipImport = file.sheets.isEmpty && file.library.isNotEmpty;

    if (!skipImport) {
      for (var source in file.imports) {
        if (!editor.imports.contains(source.name)) {
          editor.imports.add(source.name);
        }
      }

      await loadImports();
    }

    endUpdateAll();
  }

  void loadImports({bool reload = false}) async {
    for (var source in editor.imports) {
      var libs = editor.library.where((x) => x.source == source).toList();

      if (libs.isEmpty || reload) {
        if (source == "default.chart") {
          var file = await getServerFile(source);
          if (file != null) {
            print("Loading $source from server.");
            for (var item in file.chart.library) {
              print("Found ${item.methods.title}");
              var tab = loadLibrary(item, imported: true, source: source);
              library.controller.addLibrary(tab.graph, expand: false);
            }

            continue;
          }
        }
        var file = await getLocalFile(source);
        if (file != null) {
          print("Loading $source from local.");
          for (var item in file.chart.library) {
            var tab = loadLibrary(item, imported: true, source: source);
            library.controller.addLibrary(tab.graph, expand: false);
          }
        }
      }
    }

    library.controller.loadImports(editor.imports);
  }

  void beginUpdateAll() {
    editor.beginUpdate();
    tabs.beginUpdate();

    library.beginUpdate();

    canvasNotifier.beginUpdate();
    graphNotifier.beginUpdate();
  }

  void endUpdateAll() {
    library.endUpdate(true);

    tabs.endUpdate(true);
    editor.endUpdate(true);

    canvasNotifier.endUpdate(true);
    graphNotifier.endUpdate(true);
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
        waiting.addAll(cmd.after);
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

/*
  void onChangeTabs() {
    library.beginUpdate();
    editor.onChangeTab(tabs.current, canvas, graph);
    library.endUpdate(library.controller.update());
  }
*/

  List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => editor),
      ChangeNotifierProvider(builder: (_) => canvasNotifier),
      ChangeNotifierProvider(builder: (_) => tabs),
      ChangeNotifierProvider(builder: (_) => graphNotifier),
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

    if (key == "c" && evt.ctrlKey) {
      copySelection();
      return true;
    }

    if (key == "a" && evt.ctrlKey) {
      if (graph.controller.moveMode == MouseMoveMode.none &&
          graph.controller.dropping == null) {
        graph.controller.selectAll();
      }
      return true;
    }

    if (key == "x" && evt.ctrlKey) {
      cutSelection();
      return true;
    }

    if (key == "v" && evt.ctrlKey) {
      pasteClipboard();
      return true;
    }

    return false;
  }

  void zoomToFit([bool selected = false]) {
    canvas.beginUpdate();
    if (graph.nodes.isNotEmpty) {
      var rect = selected ? graph.selectionExtents : graph.extents;
      rect = rect.inflate(50);
      canvas.zoomToFit(rect, canvas.controller.size);
    } else {
      zoomHome();
    }
    canvas.endUpdate(true);
  }

  void zoomHome() {
    canvas.beginUpdate();
    canvas.reset();
    canvas.endUpdate(true);
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

  void popLibraryTabs() {
    if (library.controller.tabStack.isNotEmpty) {
      var next = library.controller.tabStack.removeLast();

      showLibrary(LibraryDisplayMode.tabs, tab: next, push: false);
    }
  }

  void nextLibrary() {
    if (library.isExpanded) {
      nextExpandedLibrary();
    } else {
      nextCollapsedLibrary();
    }
  }

  void nextCollapsedLibrary() {
    var mode = library.mode == LibraryDisplayMode.toolbox
        ? LibraryDisplayMode.collapsed
        : LibraryDisplayMode.toolbox;
    showLibrary(mode);
  }

  void nextExpandedLibrary() {
    var mode = library.mode;
    var tab = library.currentTab;

    switch (library.mode) {
      case LibraryDisplayMode.expanded:
        mode = LibraryDisplayMode.detailed;
        break;
      case LibraryDisplayMode.detailed:
        mode = LibraryDisplayMode.tabs;
        tab = LibraryTab.widgets;
        break;
      case LibraryDisplayMode.tabs:
        mode = LibraryDisplayMode.expanded;
        break;
      case LibraryDisplayMode.search:
        mode = LibraryDisplayMode.expanded;
        break;

      default:
        mode = LibraryDisplayMode.detailed;
        break;
    }
    showLibrary(mode, tab: tab);
  }

  void showLibrary(LibraryDisplayMode mode,
      {LibraryTab tab, bool push = true, bool pop = false}) {
    if (pop) {
      popLibraryTabs();
    }

    if (mode != null) {
      library.controller.setMode(mode, tab, push);
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

  void addImport(String filename) {
    if (editor.imports.contains(filename)) return;

    beginUpdateAll();
    editor.imports.add(filename);
    loadImports();
    endUpdateAll();
  }

  void addImports(List<String> files) {
    files = files.where((x) => !editor.imports.contains(x)).toList();

    if (files.isEmpty) return;

    beginUpdateAll();
    editor.imports.addAll(files);
    loadImports();
    endUpdateAll();
  }

  void removeImport(String filename) {
    if (!editor.imports.contains(filename)) return;

    beginUpdateAll();
    editor.imports.remove(filename);
    loadImports();
    endUpdateAll();
  }

  void moveImport(String filename, {int delta = 0}) {
    if (!editor.imports.contains(filename)) return;

    beginUpdateAll();
    var idx = editor.imports.indexOf(filename);
    editor.imports.removeAt(idx);

    var next = idx + delta;
    if (next < 0) next = 0;
    editor.imports.insert(next, filename);

    loadImports();
    endUpdateAll();
  }

  void newTab([bool random = false]) {
    editor.beginUpdate();

    var tab = CanvasTab(
        this,
        (random ? GraphState.random() : GraphState())
          ..name = GraphNode.randomName()
          ..icon = VectorIcons.getRandomName()
          ..title = "Untitled - ${nextSheet++}");

    tab.zoomToFit();

    while (editor.tabs.containsKey(tab.name)) {
      tab.graph.name = GraphNode.randomName();
    }
    editor.tabs[tab.name] = tab;
    library.controller.addSheet(tab.graph);
    selectTab(tab.name);
  }

  bool isTabSelected(String name) {
    return tabs.selected == name;
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

  void pasteClipboard() {
    if (clipboard.isEmpty) return;

    if (graph.controller.dropping != null) {
      if (GraphEvent.last.shiftKey) {
        pasteIndex++;
        if (pasteIndex >= clipboard.length) pasteIndex = 0;
      } else {
        pasteIndex--;
        if (pasteIndex < 0) pasteIndex = clipboard.length - 1;
      }
    } else {
      pasteIndex = clipboard.length - 1;
    }

    var last = clipboard[pasteIndex];
    last.pos = canvas.toGraphCoord(cursor);

    previewDrop(last);
  }

  void cutSelection({bool withLinks = true}) {
    if (graph.controller.selection.isEmpty) return;

    Map<String, GraphNode> nodes = {};

    for (var node in graph.controller.selection) {
      nodes[node.name] = node;
    }

    List<GraphLink> links = [];

    if (withLinks) {
      for (var link in graph.links) {
        if (nodes.containsKey(link.outPort.node.name) &&
            nodes.containsKey(link.inPort.node.name)) {
          links.add(link);
        }
      }
    }

    var nls = nodes.values.toList();
    var selection = GraphSelection.all(nls, links);
    clipboard.add(selection);

    graph.controller.removeNodes(nls);
  }

  void copySelection({bool withLinks = true}) {
    if (graph.controller.selection.isEmpty) return;

    Map<String, GraphNode> nodes = {};

    for (var node in graph.controller.selection) {
      nodes[node.name] = node;
    }

    List<GraphLink> links = [];

    if (withLinks) {
      for (var link in graph.links) {
        if (nodes.containsKey(link.outPort.node.name) &&
            nodes.containsKey(link.inPort.node.name)) {
          links.add(link);
        }
      }
    }

    var selection = GraphSelection.all(nodes.values.toList(), links);
    clipboard.add(selection);
  }

  GraphState getGraph(String name) {
    var tab = editor.tabs[name];
    if (tab == null) return null;

    return tab.graph;
  }

  void editNode(GraphNode node, {NodePort port, String focus}) {
    setCursor("default");
    bottomSheetActive = true;
    var rect = GraphState.getExtents(node.walkNode());
    var pos = canvas.pos;
    var scale = canvas.scale;

    canvas.beginUpdate();
    canvas.zoomToFit(
        rect.inflate(50),
        Size(canvas.size.width,
            canvas.size.height - EditNodeDialog.EditNodeDialogHeight));
    canvas.endUpdate(true);

    EditNodeDialog dialog;
    var controller = scaffold.currentState.showBottomSheet((context) {
      dialog = EditNodeDialog(this, node, closeBottomSheet,
          port: port, focus: focus);
      return dialog;
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

      graph.beginUpdate();
      node.script = dialog.script.text;
      graph.endUpdate(true);

      if (graph.isLibrary) {
        updateNode(graph, node);
      }

      bottomSheetActive = false;

      closeBottomSheet = null;
      autoComplete = null;
      tabFocus = null;
      modalKeyHandler = null;

      if (controller != null) {
        controller.close();
      }
    };
  }

  void updateNode(GraphState graph, GraphNode node) {
    if (graph is GraphLibraryState) {
      library.controller.updateNode(graph, node);
    }
  }

  void updateGraph(GraphState graph, {bool references = false}) {
    CanvasTab tab = editor.tabs[graph.name];
    if (tab == null) return;

    tabs.notify();
    library.controller.updateGraph(graph);

    if (references) {
      if (graph.isBehavior) {
        for (var sheet in editor.sheets) {
          for (var node in sheet.usingGraph(graph.name)) {
            print("Update ${node.name} to match ${graph.title}");
          }
        }
      }
    }
  }

  Iterable<GraphNode> usingGraph(String name) sync* {
    for (var item in editor.sheets) {
      yield* item.usingGraph(name);
    }
  }

  Iterable<GraphNode> usingMethod(String library, String name) sync* {
    for (var item in editor.sheets) {
      yield* item.usingMethod(library, name);
    }
  }

  void convertToLibrary(GraphState target, {bool confirmed = false}) {
    if (!confirmed) {
      int refCount = usingGraph(target.name).length;

      String msg = "This will create a library from ${graph.title}.";
      if (refCount > 0) {
        if (refCount == 1) {
          msg += "\n\nThere is one reference";
        } else {
          msg += "\n\nThere are ${refCount} references";
        }
        msg += " to this behavior that will be deleted.";
      }

      int nodeCount = target.nodes.where((x) => !x.isAction).length;

      if (nodeCount > 0) {
        if (nodeCount == 1) {
          msg += "\n\nThere is one node";
        } else {
          msg += "\n\nThere are ${nodeCount} nodes";
        }
        msg += " that are not actions and will be deleted";
      }

      showConfirmDialog("Convert to library?", msg).then((bool result) {
        if (result) {
          convertToLibrary(target, confirmed: true);
        }
      });

      return;
    }

    if (!selectTab(target.name)) return;

    print("Convert to Library: ${target.title}");

    beginUpdateAll();

    // remove any behavior nodes that reference this behavior
    for (var item in editor.sheets) {
      var nodes = item.usingGraph(target.name).toList();
      if (nodes.isNotEmpty) {
        if (selectTab(item.name, reload: true)) {
          graph.controller.removeNodes(nodes, locked: true);
        }
      }
    }

    // libraries only contain action nodes which define method templates
    selectTab(target.name);

    var nodes = graph.nodes.where((x) => !x.isAction).toList();
    graph.controller.removeNodes(nodes);

    graph.links.clear();

    for (var node in graph.nodes) {
      // clear flags that don't make sense on method templates
      node.isDebugging = false;
      node.isLogging = false;
      node.delay = 0;

      // actions might not have a method name assigned yet
      if (!node.hasMethod) {
        node.method = node.hasTitle
            ? node.title.toLowerCase().replaceAll(" ", "_")
            : "${node.name}_action";
      }

      // normally only system methods use the empty top level library
      if (!node.hasLibrary) {
        node.library = "user";
      }
    }

    graph.history.clear();

    library.controller.removeSheet(graph.name);

    var graphlib = GraphLibraryState()
      ..unpackGraph(graph.pack())
      ..type = GraphType.library;

    graphlib.library.name = chartFile.name
            .toLowerCase()
            .replaceAll(".chart", "")
            .replaceAll(" ", "_") +
        "." +
        graph.title.toLowerCase().replaceAll(" ", "_").replaceAll("-", "");

    editor.tabs[graphlib.name] = CanvasTab(this, graphlib)..zoomToFit();
    library.controller.addLibrary(graphlib);
    selectTab(graphlib.name, reload: true, replace: true);

    endUpdateAll();
  }

  bool selectTab(String name, {bool reload = false, bool replace = false}) {
    var tab = editor.tabs[name];
    if (tab == null) return false;
    if (tab.name == tabs.selected && !reload) return true;

    beginUpdateAll();

    tab.clearInteractive();
    tabs.selectOrAddTab(tab, replace: replace);
    if (closeBottomSheet != null) closeBottomSheet(true);

    graph = tab.graph;
    canvas = tab.canvas;

    hideMenu();
    endUpdateAll();

    return true;
  }

  void deleteGraph(GraphState target, {bool confirmed = false}) {
    if (!confirmed) {
      int refCount = target.isBehavior ? usingGraph(target.name).length : 0;

      String msg = "This will permanently delete ${target.title}.";
      if (refCount > 0) {
        if (refCount == 1) {
          msg += "\n\nThere is one reference";
        } else {
          msg += "\n\nThere are ${refCount} references";
        }
        msg +=
            " to this ${target.typeName.toLowerCase()} that will be deleted.";
      }

      showConfirmDialog("Delete ${target.typeName.toLowerCase()}?", msg)
          .then((bool result) {
        if (result) {
          deleteGraph(target, confirmed: true);
        }
      });

      return;
    }
    beginUpdateAll();

    // remove any behavior nodes that reference this behavior
    for (var item in editor.sheets) {
      var nodes = item.usingGraph(target.name).toList();
      if (nodes.isNotEmpty) {
        if (selectTab(item.name, reload: true)) {
          graph.controller.removeNodes(nodes, locked: true);
        }
      }
    }

    tabs.remove(target.name);
    editor.tabs.remove(target.name);
    if (target is GraphLibraryState) {
      library.controller.removeLibrary(target.name);
    } else if (target.isBehavior || target.isOpMode) {
      library.controller.removeSheet(target.name);
    }

    if (editor.tabs.isEmpty) {
      newTab();
    }

    var next = tabs.selected;

    if (next == target.name) {
      next = editor.tabs.values.first.graph.name;
    }

    selectTab(next, reload: true);

    endUpdateAll();
  }

  void editGraph(GraphState graph) {
    bottomSheetActive = true;
    setCursor("default");
    var rect = graph.extents;
    var pos = canvas.pos;
    var scale = canvas.scale;

    canvas.zoomToFit(
        rect.inflate(25),
        Size(canvas.size.width,
            canvas.size.height - EditGraphDialog.EditNodeDialogHeight));

    EditGraphDialog dialog;
    var controller = scaffold.currentState.showBottomSheet((context) {
      dialog = EditGraphDialog(this, graph, closeBottomSheet);
      return dialog;
    });

    controller.closed.then((evt) {
      controller = null;
      if (closeBottomSheet != null) {
        closeBottomSheet(true);
      }
    });

    closeBottomSheet = (bool save) {
      canvas.beginUpdate();
      canvas.pos = pos;
      canvas.scale = scale;
      canvas.endUpdate(true);

      graph.beginUpdate();
      graph.script = dialog.script.text;
      graph.endUpdate(true);

      updateGraph(graph, references: true);

      bottomSheetActive = false;

      closeBottomSheet = null;
      autoComplete = null;
      tabFocus = null;
      modalKeyHandler = null;

      if (controller != null) {
        controller.close();
      }
    };
  }
}
