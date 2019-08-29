import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
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
  detailed
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

  MenuItem dragging;
  GraphSelection dropping;

  LibraryController(this.editor) {
    _setMenu(library.mode);
  }

  /// stores the current display [mode] when hiding the library
  LibraryDisplayMode last = LibraryDisplayMode.collapsed;
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
      case LibraryDisplayMode.hidden:
        return 0;
    }
    return 0;
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
    );
    var addItem = MenuItem(
      icon: "tools",
    );
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
          addItem,
        ];
        break;
      case LibraryDisplayMode.detailed:
        library.menu = [
          toolboxItem,
          tabsItem,
          gridItem,
          detailsItem..selected = true,
          searchItem,
          addItem,
        ];
        break;
      default:
        library.menu = [];
        break;
    }
  }

  void setMode(LibraryDisplayMode next) {
    if (next == library.mode) return;

    library.beginUpdate();
    if (library.mode == LibraryDisplayMode.expanded ||
        library.mode == LibraryDisplayMode.detailed) {
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

  Iterable<CanvasInteractive> interactive() sync* {
    yield* library.menu;
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        yield* library.toolbox;
        break;
      case LibraryDisplayMode.collapsed:
        yield* library.behaviors;
        break;
      case LibraryDisplayMode.detailed:
        for (var sheet in library.sheets) {
          yield sheet.editButton;
          yield sheet.deleteButton;
          yield sheet;
        }

        break;

      default:
        break;
    }
  }

  void addSheet(GraphState graph) {
    library.beginUpdate();
    library.sheets.add(LibraryItem.graph(graph));
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
    for (var item in draggable()) {
      if (item.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.showTab(item.graph.name));
        }
      }
    }

    mouseMode = LibraryMouseMode.none;
    dragging = null;
    editor.setCursor("default");
    return true;
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

    for (var item in clickable()) {
      if (item.editButton.hitbox.contains(evt.pos)) {
        if (item.graph != null) {
          editor.dispatch(GraphEditorCommand.editGraph(item.graph));
        }

        if (item.node != null) {
          editor.dispatch(GraphEditorCommand.editNode(item.node));
        }
      }
    }

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
        yield* library.behaviors;
        break;

      case LibraryDisplayMode.detailed:
        yield* library.sheets;
        break;

      default:
        break;
    }
  }

  Iterable<LibraryItem> clickable() sync* {
    switch (library.mode) {
      case LibraryDisplayMode.detailed:
        yield* library.sheets;
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
