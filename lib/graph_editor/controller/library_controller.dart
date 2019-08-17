import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
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
      icon: "plus",
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
    return true;
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

    library.beginUpdate();
    for (var item in library.menu) {
      changed |= item.checkHovered(evt.pos);
      hovered |= item.hovered;
    }

    editor.setCursor(hovered ? "pointer" : "default");

    library.endUpdate(changed);

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
      var dt = evt.timer - lastDown.timer;
      if (dt < Graph.DoubleClickDuration) {
        print("Library Double Click: ${evt.pos}");
        lastDown = evt;
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

    print("Library Down: ${evt.pos}");
    return true;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    print("Library Up: ${evt.pos}");
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

    isMouseDown = false;
    mouseMode = LibraryMouseMode.none;

    return true;
  }

  @override
  bool onMouseOut() {
    isMouseDown = false;

    bool changed = false;
    library.beginUpdate();
    for (var item in library.menu) {
      changed |= item.hovered;
      item.hovered = false;
    }
    library.endUpdate(changed);
    return true;
  }
}
