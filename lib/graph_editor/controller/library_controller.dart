import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_file.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';

import 'graph_editor_comand.dart';
import 'graph_editor_controller.dart';
import 'graph_event.dart';
import 'keyboard_controller.dart';
import 'mouse_controller.dart';

enum LibraryMouseMode {
  none,
  swiping,
  scrolling,
  dragging,
}

enum LibraryDisplayMode {
  /// completely hides the library except for an expand button
  hidden,

  /// shows hotkey and context aware items
  toolbox,

  /// shows library in collapsed format
  collapsed,

  /// shows library in full width mode but collapsed items
  expanded,

  /// shows library items fully expanded
  detailed,

  // show items that match a search field
  search,

  // show a page of library items based on the option mode
  tabs,
}

enum LibraryTab {
  /// show widgets that can be added to the graph
  widgets,

  /// manage the files that are being imported into this chart
  imports,

  /// show items from the clipboard history
  clipboard,

  /// displays the examples/templates from imported charts
  templates,

  /// displays a simple file browser to access files stored locally (IndexedDB)
  /// or remotely (server, cloud, Lighthouse, OnBot java or attached device)
  files,

  /// displays the version history for this graph
  history,
}

typedef SelectFileHandler(String filename);

class SelectFileMenuItem extends MenuItem {
  SelectFileHandler handler;

  SelectFileMenuItem(this.handler);
}

class LibraryController with MouseController, KeyboardController {
  GraphEditorController editor;
  LibraryState get library => editor.library;
  bool get isSwiping => mouseMode == LibraryMouseMode.swiping;
  bool get isScrolling => mouseMode == LibraryMouseMode.scrolling;
  bool get isDragging => mouseMode == LibraryMouseMode.dragging;
  bool get isHidden => library.isHidden;
  bool get isCollapsed => library.isCollapsed;
  bool get isExpanded => library.isExpanded;

  bool isMouseDown = false;
  GraphEvent lastDown;

  Offset startPos = Offset.zero;
  Offset lastPos = Offset.zero;

  Rect scrollWindow = Rect.zero;

  double scrollStart = 0;
  double scrollHeight = 0;
  double scrollDownPos = 0;
  double scrollDownStart = 0;

  double get scrollPos {
    var range = scrollRange;
    if (range == 0) return 0;
    var pos = scrollStart / range;
    return pos > 1 ? 1 : pos;
  }

  double get scrollRange => scrollHeight < scrollWindow.height
      ? 0
      : scrollHeight - scrollWindow.height;

  MenuItem dragging;
  GraphSelection dropping;

  String filesTitle;
  SelectFileHandler onSelectFile;

  LibraryController(this.editor) {
    _setMenu(library.mode);
    _setClipboardButtons();
  }

  /// stores the current display [mode] when hiding the library
  LibraryDisplayMode last = LibraryDisplayMode.collapsed;
  List<LibraryTab> tabStack = [];

  LibraryMouseMode mouseMode = LibraryMouseMode.none;

  bool isHovered(Offset pt) {
    return library.hitbox.contains(pt) || pt.dx > editor.canvas.size.width;
  }

  void setScrollHeight(double height) {
    if (height != scrollHeight) {
      scrollHeight = height;
      // dispatch the call because updated heights come from painting
      // possibly we could have a layout phase that is independed of painting
      editor.dispatch(GraphEditorCommand((editor) {
        updateScrollPos();
      }));
    }
  }

  void setScrollPos(double pos) {
    if (pos < 0) pos = 0;
    if (pos > 1) pos = 1;

    if (pos == scrollPos) return;
    scrollStart = pos * scrollRange;

    editor.dispatch(GraphEditorCommand((editor) {
      updateScrollPos();
    }));
  }

  void updateClipboard() {
    library.beginUpdate();
    _setClipboardButtons();
    library.endUpdate(true);
  }

  void updateVersion() {
    library.beginUpdate();
    library.versions.clear();
    library.lastVersions.clear();
    Map<String, VersionItem> versions = {};
    Map<String, int> columns = {"master": 0};
    Map<String, int> colors = {"master": 0};
    Map<String, VersionItem> terminal = {};

    int row = editor.chartFile.history.length;
    String branch;

    for (var data in editor.chartFile.history) {
      branch = data.branch;
      if (branch == null || branch.isEmpty) branch = "master";
      if (!colors.containsKey(branch)) colors[branch] = colors.length;
      if (!columns.containsKey(branch)) {
        var max = 0;
        for (var col in columns.values) {
          if (col > max) max = col;
        }
        columns[branch] = max + 1;
      }

      var next = VersionItem.chart(data)
        ..color = colors[branch]
        ..column = columns[branch]
        ..row = row;

      library.lastVersions[branch] = next;
      library.versions.add(next);
      versions[next.version] = next;
      if (data.merge != null && data.merge.isNotEmpty) {
        var target = versions[data.merge];
        if (target != null) {
          columns.remove(target.branch);
          library.lastVersions.remove(target.branch);
        }
      }

      row--;
    }

    library.currentVersion.updateFrom(editor.editor);
    branch = library.currentVersion.branch;
    if (branch == null || branch.isEmpty) branch = "master";
    if (!colors.containsKey(branch)) colors[branch] = colors.length;
    if (!columns.containsKey(branch)) columns[branch] = columns.length;
    library.currentVersion
      ..color = colors[branch]
      ..column = columns[branch]
      ..row = 0;
    library.currentBranch = branch;

    library.versions.add(library.currentVersion);

    for (var item in library.versions) {
      item.source = versions[item.sourceVersion];
      item.merge = versions[item.mergeVersion];
    }

    _setHistoryButtons();
    library.endUpdate(true);
  }

  void updateHistory() {
    library.beginUpdate();
    if (library.currentVersion != null) {
      library.currentVersion.version = editor.version;
    }

    library.history.clear();
    library.graphVersion = "";
    if (editor.graph != null) {
      library.graphVersion = editor.graph.history.getVersionLabel();

      var cmds = editor.graph.history.redoCmds;
      for (int i = 0; i < cmds.length; i++) {
        library.history.add(HistoryItem.command(cmds[i], i, undo: false));
      }

      cmds = editor.graph.history.undoCmds;
      for (int i = cmds.length - 1; i >= 0; i--) {
        library.history.add(HistoryItem.command(cmds[i], i, undo: true));
      }
    }

    library.chartVersion = editor.version.substring(0, 8);

    _setClipboardButtons();
    _setHistoryButtons();
    library.endUpdate(true);
  }

  void updateScrollPos() {
    library.beginUpdate();

    if (scrollStart > scrollRange) {
      scrollStart = scrollRange;
    }

    library.endUpdate(true);
  }

  double get width {
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        return Graph.LibraryCollapsedWidth;
      case LibraryDisplayMode.collapsed:
        return Graph.LibraryCollapsedWidth;
      case LibraryDisplayMode.expanded:
        return Graph.LibraryExpandedWidth;
      case LibraryDisplayMode.detailed:
        return Graph.LibraryExpandedWidth;
      case LibraryDisplayMode.search:
        return Graph.LibraryExpandedWidth;
      case LibraryDisplayMode.tabs:
        return Graph.LibraryExpandedWidth;
      case LibraryDisplayMode.hidden:
        return 0;
    }
    return 0;
  }

  MenuItemSet createFileMenuItem(String file,
      {SelectFileHandler onSelect,
      SelectFileHandler onDelete,
      List<SelectFileMenuItem> items}) {
    items = items ?? [];

    return MenuItemSet([
      ...items.map((x) => MenuItem()
        ..copy(x)
        ..command = GraphEditorCommand((editor) {
          x.handler(file);
        })),
      if (onSelect != null)
        MenuItem()
          ..icon = "folder-open-solid"
          ..command = GraphEditorCommand((editor) {
            onSelect(file);
          }),
      if (onDelete != null)
        MenuItem()
          ..icon = "trash-alt"
          ..command = GraphEditorCommand((editor) {
            onDelete(file);
          }),
    ])
      ..name = file;
  }

  void selectFile(String title, List<String> files,
      {SelectFileHandler onSelect, SelectFileHandler onDelete}) {
    files = files ?? [];

    library.files = files
        .map((x) =>
            createFileMenuItem(x, onSelect: onSelect, onDelete: onDelete))
        .toList();

    editor.dispatch(GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
        tab: LibraryTab.files));

    onSelectFile = onSelect;
    filesTitle = title;
  }

  void _setClipboardButtons() {
    var canUndo = false;
    var canRedo = false;
    var hasSelection = false;

    if (editor.graph != null) {
      canUndo = editor.graph.history.canUndo;
      canRedo = editor.graph.history.canRedo;
    }

    if (editor.graph != null) {
      hasSelection = editor.graph.controller.selection.isNotEmpty;
    }

    library.clipboardButtons = [
      MenuItem(icon: "cut", command: GraphEditorCommand.cutSelection())
        ..disabled = !hasSelection,
      MenuItem(icon: "copy-solid", command: GraphEditorCommand.copySelection())
        ..disabled = !hasSelection,
      MenuItem(icon: "paste", command: GraphEditorCommand.pasteClipboard())
        ..disabled = editor.clipboard.isEmpty,
      MenuItem(icon: "undo", command: GraphEditorCommand.undoHistory())
        ..disabled = !canUndo,
      MenuItem(icon: "redo", command: GraphEditorCommand.redoHistory())
        ..disabled = !canRedo,
      MenuItem(
          icon: "trash-restore", command: GraphEditorCommand.clearClipboard())
        ..disabled = editor.clipboard.isEmpty,
    ];
  }

  void _setHistoryButtons() {
    var canUndo = false;
    var canRedo = false;

    if (editor.graph != null) {
      canUndo = editor.graph.history.canUndo;
      canRedo = editor.graph.history.canRedo;
    }

    library.historyButtons = [
      MenuItem(icon: "undo", command: GraphEditorCommand.undoHistory())
        ..disabled = !canUndo,
      MenuItem(icon: "redo", command: GraphEditorCommand.redoHistory())
        ..disabled = !canRedo,
    ];

    var canCommit = editor.allowCommit;
    var canMerge = editor.allowMerge;
    var canBranch = editor.allowBranch;

    library.versionButtons = [
      MenuItem(icon: "git-merge", command: GraphEditorCommand.mergeVersion())
        ..disabled = !canMerge,
      MenuItem(icon: "git-branch", command: GraphEditorCommand.branchVersion())
        ..disabled = !canBranch,
      MenuItem(icon: "check", command: GraphEditorCommand.commitChanges())
        ..disabled = !canCommit
    ];
  }

  void _setMenu(LibraryDisplayMode mode) {
    var toolboxItem = MenuItem(
      icon: "toolbox",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.toolbox),
    );
    var tabsItem = MenuItem(
      icon: "cogs",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.collapsed),
    );
    var gridItem = MenuItem(
      icon: "th-large",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.expanded),
    );
    var detailsItem = MenuItem(
      icon: "th-list",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.detailed),
    );
    var searchItem = MenuItem(
      icon: "search",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.search),
    );

    var optionsItem = MenuItem(
      icon: "tools",
      command: GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs),
    );

    // optionsMenu
    library.tabs = [
      MenuItem(
          icon: "hat-wizard",
          command: GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
              tab: LibraryTab.widgets))
        ..selected = library.currentTab == LibraryTab.widgets,
      MenuItem(
          icon: "history",
          command: GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
              tab: LibraryTab.history))
        ..selected = library.currentTab == LibraryTab.history,
      MenuItem(
          icon: "clipboard-solid",
          command: GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
              tab: LibraryTab.clipboard))
        ..selected = library.currentTab == LibraryTab.clipboard,
      MenuItem(
          icon: "file-import",
          command: GraphEditorCommand.showLibrary(LibraryDisplayMode.tabs,
              tab: LibraryTab.imports))
        ..selected = library.currentTab == LibraryTab.imports,
      if (tabStack.isNotEmpty)
        MenuItem(
            icon: "window-close-solid",
            command: GraphEditorCommand.popLibraryTabs()),
      if (library.currentTab == LibraryTab.templates)
        MenuItem(icon: "share-square-solid")
          ..selected = library.currentTab == LibraryTab.templates,
      if (library.currentTab == LibraryTab.files)
        MenuItem(
            icon: "folder-open-solid",
            command: GraphEditorCommand.print("View Files"))
          ..selected = library.currentTab == LibraryTab.files,
    ];

    switch (mode) {
      case LibraryDisplayMode.toolbox:
        library.menu = [toolboxItem..selected = true, tabsItem];
        break;
      case LibraryDisplayMode.collapsed:
        library.menu = [toolboxItem, tabsItem..selected = true];
        break;
      case LibraryDisplayMode.expanded:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem..selected = true,
          detailsItem,
          optionsItem,
          searchItem,
        ];
        break;
      case LibraryDisplayMode.detailed:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem..selected = true,
          optionsItem,
          searchItem,
        ];
        break;
      case LibraryDisplayMode.search:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem,
          optionsItem,
          searchItem..selected = true,
        ];
        break;
      case LibraryDisplayMode.tabs:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem,
          optionsItem..selected = true,
          searchItem,
        ];
        break;
      default:
        library.menu = [];
        break;
    }
  }

  void setMode(LibraryDisplayMode next, [LibraryTab tab, bool push = true]) {
    if (next == library.mode && tab == null) return;

    library.beginUpdate();

    if (tab != null) {
      if (library.currentTab != tab && push) {
        if (library.isModalTab(tab)) {
          tabStack.add(library.currentTab);
        } else {
          tabStack.clear();
        }
      }
      library.currentTab = tab;
    }

    if (library.mode == LibraryDisplayMode.expanded ||
        library.mode == LibraryDisplayMode.detailed ||
        library.mode == LibraryDisplayMode.search ||
        library.mode == LibraryDisplayMode.tabs) {
      library.lastExpanded = library.mode;
    }

    if (library.mode == LibraryDisplayMode.toolbox ||
        library.mode == LibraryDisplayMode.collapsed) {
      library.lastCollapsed = library.mode;
    }

    library.mode = next;
    _setMenu(next);

    library.endUpdate(true);
  }

  void hide() {
    if (library.mode == LibraryDisplayMode.hidden) return;

    last = library.mode;
    setMode(LibraryDisplayMode.hidden);
  }

  void show() {
    if (library.mode != LibraryDisplayMode.hidden) return;
    setMode(last);
  }

  @override
  bool onMouseWheel(GraphEvent evt) {
    if (evt.deltaY < 0) {
      setScrollPos(scrollPos - .2);
    } else {
      setScrollPos(scrollPos + .2);
    }

    return true;
  }

  @override
  bool onContextMenu(GraphEvent evt) {
    evt = toScrollCoord(evt);

    print("Library Context Menu: ${evt.pos}");

    mouseMode = LibraryMouseMode.none;
    dragging = null;

    return true;
  }

  Iterable<CanvasInteractive> tabInteractive() sync* {
    switch (library.currentTab) {
      case LibraryTab.files:
        for (var item in library.files) {
          yield* item.items;
        }
        break;
      case LibraryTab.imports:
        yield* library.importButtons;
        for (var item in library.imports) {
          yield* item.items;
        }
        break;
      case LibraryTab.widgets:
        yield* library.widgets;
        break;
      case LibraryTab.clipboard:
        yield* library.clipboardButtons;
        yield* library.clipboard;
        break;
      case LibraryTab.history:
        yield* library.historyButtons;
        yield* library.versionButtons;
        yield library.historyGroup.expandoButton;
        yield library.versionGroup.expandoButton;
        yield* library.history;
        break;
      default:
        break;
    }
  }

  Iterable<CanvasInteractive> interactive() sync* {
    yield* library.menu;
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        yield* library.toolbox;
        break;
      case LibraryDisplayMode.collapsed:
        yield* library.behaviors;
        break;
      case LibraryDisplayMode.expanded:
        for (var sheet in library.sheets) {
          yield sheet;
        }

        if (library.behaviors.isNotEmpty) {
          yield library.behaviorGroup.expandoButton;
        }

        if (library.opmodes.isNotEmpty) {
          yield library.opmodeGroup.expandoButton;
        }

        for (var group in library.groups) {
          if (allowEditGroup(group)) {
            yield group.openButton;
          }

          yield group.expandoButton;

          if (group.isExpanded) {
            for (var sub in group.items) {
              yield* sub.items;
            }
          }
        }

        break;
      case LibraryDisplayMode.detailed:
        for (var sheet in library.sheets) {
          yield sheet.editButton;
          yield sheet;
        }

        if (library.behaviors.isNotEmpty) {
          yield library.behaviorGroup.expandoButton;
        }
        if (library.opmodes.isNotEmpty) {
          yield library.opmodeGroup.expandoButton;
        }

        for (var group in library.groups) {
          if (allowEditGroup(group)) {
            yield group.openButton;
          }

          yield group.expandoButton;

          if (group.isExpanded) {
            for (var sub in group.items) {
              yield* sub.items;
            }
          }
        }

        break;
      case LibraryDisplayMode.tabs:
        yield* library.tabs;
        yield* tabInteractive();
        break;
      default:
        break;
    }
  }

  void showAddImportTab() {
    editor.getLocalFileList().then((files) {
      selectFile("Select Import", files, onSelect: (filename) {
        editor.popLibraryTabs();
        editor.addImport(filename);
      });
    });
  }

  void loadImports(List<String> sources) {
    library.beginUpdate();
    library.imports.clear();

    library.importButtons = [
      if (GraphFile.defaultImports.any((x) => !sources.contains(x)))
        MenuItem()
          ..icon = "star"
          ..command = GraphEditorCommand((editor) {
            editor.addImports(GraphFile.defaultImports);
          }),
      MenuItem()
        ..icon = "plus"
        ..command = GraphEditorCommand((editor) {
          showAddImportTab();
        })
    ];

    for (var source in sources) {
      library.imports.add(MenuItemSet([
        if (source != sources.first)
          MenuItem()
            ..icon = "arrow-up"
            ..command = GraphEditorCommand((editor) {
              editor.moveImport(source, delta: -1);
            }),
        if (source != sources.last)
          MenuItem()
            ..icon = "arrow-down"
            ..command = GraphEditorCommand((editor) {
              editor.moveImport(source, delta: 1);
            }),
        MenuItem()
          ..icon = "trash-alt"
          ..command = GraphEditorCommand((editor) {
            editor.removeImport(source);
          }),
      ])
        ..name = source);
    }

    library.endUpdate(true);

    updateHistory();
    editor.updateVersion();
  }

  void removeLibrary(String name) {
    library.beginUpdate();

    library.groups = [...library.groups.where((x) => x.graph.name != name)];

    library.endUpdate(true);
  }

  void addWidgets(List<GraphNode> widgets) {
    library.beginUpdate();
    for (var widget in widgets) {
      addWidget(widget);
    }
    library.endUpdate(true);
  }

  void addWidget(GraphNode widget) {
    library.beginUpdate();
    library.widgets.add(LibraryItem.widget(widget));
    library.endUpdate(true);
  }

  void addSelection(GraphSelection selection) {
    library.beginUpdate();
    library.clipboard.add(LibraryItem.selection(selection));
    library.endUpdate(true);
  }

  void addLibrary(GraphLibraryState graph, {bool expand = true}) {
    library.beginUpdate();
    var added = LibraryItem.library(graph);
    library.groups.add(added);
    if (expand) {
      for (var group in library.groups) {
        if (group == added) continue;
        group.collapsed = true;
      }
    } else {
      added.collapsed = true;
    }

    library.endUpdate(true);
  }

  void addSheet(GraphState graph) {
    library.beginUpdate();
    library.sheets.add(LibraryItem.graph(graph));
    library.endUpdate(true);
  }

  void updateNode(GraphState graph, GraphNode node) {
    updateGraph(graph);
  }

  void updateGraph(GraphState graph) {
    library.beginUpdate();

    if (graph is GraphLibraryState) {
      var idx = library.groups.indexWhere((x) => x.graph.name == graph.name);

      if (idx >= 0) {
        library.groups[idx] = LibraryItem.library(graph);
      }
    } else {
      var idx = library.sheets.indexWhere((x) => x.graph.name == graph.name);
      if (idx >= 0) {
        library.sheets[idx] = LibraryItem.graph(graph);
      }
    }

    library.endUpdate(true);
  }

  void removeSheet(String name) {
    library.beginUpdate();
    library.sheets = [...library.sheets.where((x) => x.graph.name != name)];
    library.endUpdate(true);
  }

  bool update() {
    bool changed = false;
    for (var item in library.sheets) {
      var alerted = editor.isTabSelected(item.graph.name);
      if (alerted != item.alerted) {
        changed = true;
      }

      item.clearInteractive();
      item.alerted = alerted;
    }
    return changed;
  }

  GraphEvent toScrollCoord(GraphEvent evt) {
    if (scrollWindow.contains(evt.pos)) {
      return GraphEvent.copy(evt)..pos = evt.pos.translate(0, scrollStart);
    } else {
      return evt;
    }
  }

  @override
  bool onMouseMove(GraphEvent evt) {
    var screen = evt;
    evt = toScrollCoord(evt);

    if (isMouseDown && mouseMode == LibraryMouseMode.none) {
      var dx = evt.pos.dx - startPos.dx;
      var dy = evt.pos.dy - startPos.dy;
      if (dx.abs() > 5 || dy.abs() > 5) {
        mouseMode = (dx.abs() > dy.abs())
            ? LibraryMouseMode.swiping
            : LibraryMouseMode.scrolling;

        print("Set Mode: $mouseMode");
      }
    }

    bool changed = false;
    bool hovered = false;

    if (isScrolling) {
      changed = true;

      var delta = screen.pos.dy - scrollDownPos;
      scrollStart = scrollDownStart - delta;
      if (scrollStart < 0) scrollStart = 0;
      if (scrollStart > scrollRange) scrollStart = scrollRange;
    }

    if (isDragging) {
      changed = true;
      dragging.pos = screen.pos;

      if (dropping != null) {
        if (screen.pos.dx < editor.canvas.size.width) {
          dropping.pos = editor.canvas.toGraphCoord(screen.pos);
          editor.previewDrop(dropping);
        } else {
          editor.cancelDrop();
        }
      }
    }

    library.beginUpdate();

    if (mouseMode == LibraryMouseMode.none) {
      for (var item in interactive()) {
        var alerted =
            item.alerted && library.mode == LibraryDisplayMode.collapsed;

        if (alerted) continue;
        if (item.disabled) {
          if (item.hovered) {
            changed = true;
            item.hovered = false;
          }
          continue;
        }
        changed |= item.checkHovered(evt.pos);
        if (!alerted) {
          hovered |= item.hovered;
        }
      }
    } else {
      for (var item in interactive()) {
        if (item.hovered) {
          item.hovered = false;
          changed = true;
        }
      }
    }

    editor.setCursor(isDragging ? "grab" : hovered ? "pointer" : "default");

    library.endUpdate(changed);

    return true;
  }

  @override
  bool onMouseDoubleTap(GraphEvent evt) {
    evt = toScrollCoord(evt);

    for (var item in clickable()) {
      if (item.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.selectTab(item.graph.name));
        }
      }
    }
    if (library.isHistory) {
      for (var item in library.history) {
        if (item.hitbox.contains(evt.pos)) {
          if (item.isUndoItem) {
            editor.dispatch(GraphEditorCommand.undoHistory(index: item.index));
          } else {
            editor.dispatch(GraphEditorCommand.redoHistory(index: item.index));
          }
        }
      }
    }

    mouseMode = LibraryMouseMode.none;
    dragging = null;
    editor.setCursor("default");
    return true;
  }

  bool handleGroupExpando(GraphEvent evt) {
    bool changed = false;
    library.beginUpdate();

    //   LibraryItem expanded;
    for (var group in library.groups) {
      if (group.expandoButton.hitbox.contains(evt.pos)) {
        group.collapsed = !group.collapsed;
        // if (group.isExpanded) expanded = group;
        changed = true;
      }
    }

    if (library.mode == LibraryDisplayMode.tabs &&
        library.currentTab == LibraryTab.history) {
      for (var group in [library.historyGroup, library.versionGroup]) {
        if (group.expandoButton.hitbox.contains(evt.pos)) {
          group.collapsed = !group.collapsed;
          changed = true;
        }
      }
    }

/*
    if (expanded != null) {
      for (var group in library.groups) {
        if (group == expanded) continue;

        if (group.isExpanded) {
          group.collapsed = true;
          changed = true;
        }
      }
    }
*/

    library.endUpdate(changed);
    if (changed) return true;

    if (library.opmodes.isNotEmpty) {
      if (library.opmodeGroup.expandoButton.hitbox.contains(evt.pos)) {
        library.beginUpdate();
        library.opmodeGroup.collapsed = !library.opmodeGroup.collapsed;
        library.endUpdate(true);
        return true;
      }
    }

    if (library.behaviors.isNotEmpty) {
      if (library.behaviorGroup.expandoButton.hitbox.contains(evt.pos)) {
        library.beginUpdate();
        library.behaviorGroup.collapsed = !library.behaviorGroup.collapsed;
        library.endUpdate(true);
        return true;
      }
    }
    return false;
  }

  @override
  bool onMouseDown(GraphEvent evt) {
    scrollDownPos = evt.pos.dy;
    scrollDownStart = scrollStart;

    evt = toScrollCoord(evt);

    if (library.hitbox.contains(evt.pos)) {
      if (isHidden) {
        editor.dispatch(GraphEditorCommand.showLibrary(null));
      } else {
        editor.dispatch(GraphEditorCommand.hideLibrary());
      }

      return true;
    }

    startPos = evt.pos;
    isMouseDown = true;
    if (lastDown != null) {
      var dt = editor.timer - lastDown.timer;
      if (dt < Duration(milliseconds: 500) && lastDown.touches.length <= 1) {
        onMouseDoubleTap(evt);
        return true;
      }
    }

    lastDown = evt;

    for (var item in library.menu) {
      if (item.hovered && item.command != null) {
        editor.dispatch(item.command);
        return true;
      }
    }

    for (var item in buttons()) {
      if (!item.disabled && item.hitbox.contains(evt.pos)) {
        editor.dispatch(item.command);

        return true;
      }
    }

    for (var item in clickable()) {
      if (item.editButton.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.selectTab(item.graph.name)
            ..then(GraphEditorCommand.editGraph(item.graph)));
          return true;
        }

        if (item.node != null) {
          editor.dispatch(GraphEditorCommand.editNode(item.node));
          return true;
        }
      }

      if (item.openButton.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.selectTab(item.graph.name));
          return true;
        }
      }
    }

    if (handleGroupExpando(evt)) return true;

    if (checkStartDrag(evt)) {
      return true;
    }

    mouseMode = LibraryMouseMode.none;
    dragging = null;

    return true;
  }

  Iterable<LibraryItem> draggable() sync* {
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        yield* library.toolbox;
        break;

      case LibraryDisplayMode.collapsed:
        if (!editor.graph.isLibrary) {
          yield* library.behaviors;
        }
        break;

      case LibraryDisplayMode.expanded:
      case LibraryDisplayMode.detailed:
        if (!editor.graph.isLibrary) {
          yield* library.sheets;
        }

        for (var group in library.groups) {
          if (group.isExpanded) {
            for (var sub in group.items) {
              yield* sub.items;
            }
          }
        }

        break;
      case LibraryDisplayMode.tabs:
        switch (library.currentTab) {
          case LibraryTab.widgets:
            yield* library.widgets;
            break;
          case LibraryTab.clipboard:
            yield* library.clipboard;
            break;

          default:
            break;
        }
        break;
      default:
        break;
    }
  }

  bool allowEditGroup(LibraryItem item) {
    if (item.graph is GraphLibraryState) {
      return !(item.graph as GraphLibraryState).imported;
    }
    return false;
  }

  Iterable<LibraryItem> clickable() sync* {
    switch (library.mode) {
      case LibraryDisplayMode.expanded:
      case LibraryDisplayMode.detailed:
        yield* library.sheets;

        for (var group in library.groups) {
          if (allowEditGroup(group)) {
            yield group;
          }

          if (group.isExpanded) {
            for (var sub in group.items) {
              yield* sub.items;
            }
          }
        }

        break;

      default:
        break;
    }
  }

  Iterable<MenuItem> tabButtons() sync* {
    switch (library.currentTab) {
      case LibraryTab.files:
        for (var item in library.files) {
          yield* item.items;
        }
        break;
      case LibraryTab.imports:
        yield* library.importButtons;
        for (var item in library.imports) {
          yield* item.items;
        }
        break;
      case LibraryTab.clipboard:
        yield* library.clipboardButtons;
        break;

      case LibraryTab.history:
        yield* library.historyButtons;
        yield* library.versionButtons;
        break;

      default:
        break;
    }
  }

  Iterable<MenuItem> buttons() sync* {
    switch (library.mode) {
      case LibraryDisplayMode.tabs:
        yield* library.tabs;
        yield* tabButtons();
        break;

      default:
        break;
    }
  }

  bool checkStartDrag(GraphEvent evt) {
    for (var item in draggable()) {
      if (item.alerted) continue;

      if (item.graph != null && item.graph.type == GraphType.opmode) continue;

      if (item.isHovered(evt.pos)) {
        mouseMode = LibraryMouseMode.dragging;
        dragging = MenuItem()..copy(item);

        if (item.selection != null) {
          dropping = item.selection;
        } else {
          var node = item.dropNode..moveTo(0, 0);
          dropping = GraphSelection.node(node);
        }
        return true;
      }
    }

    return false;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    evt = toScrollCoord(evt);

    bool changed = mouseMode != LibraryMouseMode.none;

    library.beginUpdate();

    if (isSwiping) {
      var dx = evt.pos.dx - startPos.dx;
      if (dx < 0 && library.isCollapsed) {
        editor.dispatch(GraphEditorCommand.showLibrary(library.lastExpanded));
      }

      if (dx > 0) {
        if (library.isExpanded) {
          editor
              .dispatch(GraphEditorCommand.showLibrary(library.lastCollapsed));
        }
      }
    }

    if (isDragging) {
      if (dropping != null && evt.pos.dx < editor.canvas.size.width) {
        editor.endDrop(dropping, select: true);
      }

      dropping = null;
      dragging = null;
      editor.setCursor("default");
    }

    mouseMode = LibraryMouseMode.none;
    isMouseDown = false;

    library.endUpdate(changed);
    return true;
  }

  @override
  bool onMouseOut() {
    isMouseDown = false;

    bool changed = false;
    library.beginUpdate();
    for (var item in interactive()) {
      changed |= item.hovered;
      item.hovered = false;
    }

    library.endUpdate(changed);

    return true;
  }
}
