import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';

import 'graph_editor_comand.dart';
import 'graph_editor_controller.dart';
import 'graph_editor_filesource.dart';
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

  MenuItem dragging;
  GraphSelection dropping;

  String filesTitle;
  SelectFileHandler onSelectFile;

  LibraryController(this.editor) {
    _setMenu(library.mode);
  }

  /// stores the current display [mode] when hiding the library
  LibraryDisplayMode last = LibraryDisplayMode.collapsed;
  List<LibraryTab> tabStack = [];

  LibraryMouseMode mouseMode = LibraryMouseMode.none;

  bool isHovered(Offset pt) {
    return library.hitbox.contains(pt) || pt.dx > editor.canvas.size.width;
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

  MenuItemSet createFileMenuItem(String file) {
    return MenuItemSet([
      MenuItem()
        ..icon = "folder-open-solid"
        ..command = GraphEditorCommand.all([
          GraphEditorCommand.popLibraryTabs(),
          GraphEditorCommand.showLibrary(LibraryDisplayMode.detailed),
          GraphEditorCommand.openFile(FileSourceType.local, file)
        ]),
      MenuItem()
        ..icon = "trash-alt"
        ..command = GraphEditorCommand.deleteLocalFile(file),
    ])
      ..name = file;
  }

  void openFile(String title, SelectFileHandler onSelect,
      [List<String> files]) {
    files = files ?? [];

    library.files = files.map(createFileMenuItem).toList();

    editor.dispatch(GraphEditorCommand.showLibrary(
        LibraryDisplayMode.tabs, LibraryTab.files));

    onSelectFile = onSelect;
    filesTitle = title;
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
          icon: "share-square-solid",
          command: GraphEditorCommand.showLibrary(
              LibraryDisplayMode.tabs, LibraryTab.templates))
        ..selected = library.currentTab == LibraryTab.templates,
      MenuItem(
          icon: "puzzle-piece",
          command: GraphEditorCommand.showLibrary(
              LibraryDisplayMode.tabs, LibraryTab.widgets))
        ..selected = library.currentTab == LibraryTab.widgets,
      MenuItem(
          icon: "file-import",
          command: GraphEditorCommand.showLibrary(
              LibraryDisplayMode.tabs, LibraryTab.imports))
        ..selected = library.currentTab == LibraryTab.imports,
      MenuItem(
          icon: "clipboard-solid",
          command: GraphEditorCommand.showLibrary(
              LibraryDisplayMode.tabs, LibraryTab.clipboard))
        ..selected = library.currentTab == LibraryTab.clipboard,
      if (tabStack.isNotEmpty)
        MenuItem(
            icon: "window-close-solid",
            command: GraphEditorCommand.popLibraryTabs()),
      if (library.currentTab == LibraryTab.history)
        MenuItem(icon: "history")
          ..selected = library.currentTab == LibraryTab.history,
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
          searchItem,
          optionsItem,
        ];
        break;
      case LibraryDisplayMode.detailed:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem..selected = true,
          searchItem,
          optionsItem,
        ];
        break;
      case LibraryDisplayMode.search:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem,
          searchItem..selected = true,
          optionsItem,
        ];
        break;
      case LibraryDisplayMode.tabs:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem,
          searchItem,
          optionsItem..selected = true,
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
    print("Library Wheel: ${evt.pos} ${evt.deltaY}");
    return true;
  }

  @override
  bool onContextMenu(GraphEvent evt) {
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

  void addLibrary(GraphLibraryState graph) {
    library.beginUpdate();
    var added = LibraryItem.library(graph);
    library.groups.add(added);
    for (var group in library.groups) {
      if (group == added) continue;
      group.collapsed = true;
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

  void removeSheet(GraphState graph) {
    library.beginUpdate();
    library.sheets = [
      ...library.sheets.where((x) => x.graph.name != graph.name)
    ];
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

  @override
  bool onMouseMove(GraphEvent evt) {
    if (isMouseDown && mouseMode == LibraryMouseMode.none) {
      var dx = evt.pos.dx - startPos.dx;
      var dy = evt.pos.dy - startPos.dy;
      if (dx.abs() > 5 || dx.abs() > 5) {
        mouseMode = (dx.abs() > dy.abs())
            ? LibraryMouseMode.swiping
            : LibraryMouseMode.scrolling;

        print("Set Mode: $mouseMode");
      }
    }

    bool changed = false;
    bool hovered = false;

    if (isDragging) {
      changed = true;
      dragging.pos = evt.pos;

      if (dropping != null) {
        if (evt.pos.dx < editor.canvas.size.width) {
          dropping.pos = editor.canvas.toGraphCoord(evt.pos);
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

        changed |= item.checkHovered(evt.pos);
        if (!alerted) {
          hovered |= item.hovered;
        }
      }
    }

    editor.setCursor(isDragging ? "grab" : hovered ? "pointer" : "default");

    library.endUpdate(changed);

    return true;
  }

  @override
  bool onMouseDoubleTap(GraphEvent evt) {
    for (var item in clickable()) {
      if (item.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.selectTab(item.graph.name));
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

    LibraryItem expanded;
    for (var group in library.groups) {
      if (group.expandoButton.hitbox.contains(evt.pos)) {
        group.collapsed = !group.collapsed;
        if (group.isExpanded) expanded = group;
        changed = true;
      }
    }

    if (expanded != null) {
      for (var group in library.groups) {
        if (group == expanded) continue;

        if (group.isExpanded) {
          group.collapsed = true;
          changed = true;
        }
      }
    }

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
    if (library.hitbox.contains(evt.pos)) {
      if (isHidden) {
        editor.dispatch(GraphEditorCommand.showLibrary());
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
      if (item.hitbox.contains(evt.pos)) {
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
        var node = item.dropNode..moveTo(0, 0);
        dropping = GraphSelection.node(node);

        return true;
      }
    }

    return false;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
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
        editor.endDrop(dropping);
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
