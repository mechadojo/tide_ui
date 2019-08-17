import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/controller/radial_menu_controller.dart';
import 'package:tide_ui/graph_editor/graph_tabs.dart';

import 'graph_event.dart';
import 'mouse_controller.dart';

typedef OnMouseEvent(GraphEvent evt);

class MouseHandler {
  GraphEditorController editor;
  CanvasTabsController get tabs => editor.tabs.controller;
  CanvasController get canvas => editor.canvas.controller;
  GraphController get graph => editor.graph.controller;
  KeyboardHandler get keyboard => editor.keyboardHandler;
  RadialMenuController get menu => editor.menu.controller;
  LibraryController get library => editor.library.controller;

  MouseHandler(this.editor);

  // ***************************************************************
  //
  //  Dispatch events to tabs or canvas based on screen location
  //
  // ***************************************************************

  Offset globalToLocal(RenderBox rb, Offset pt) {
    try {
      return rb.globalToLocal(pt);
    } catch (ex) {
      print(ex.toString());
      return null;
    }
  }

  void dispatchEvent(GraphEvent evt, BuildContext context,
      {OnMouseEvent onTabs, OnMouseEvent onCanvas}) {
    RenderBox rb = context.findRenderObject();

    evt.timer = editor.timer;

    var pt = globalToLocal(rb, evt.pos);

    if (pt == null) return;

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    for (var touch in evt.touches.values) {
      var tpt = globalToLocal(rb, touch.pos);
      if (tpt != null) touch.pos = tpt;
    }

    evt.pos = pt;

    if (evt.pos.dy < GraphTabs.DefaultTabHeight) {
      if (onTabs != null) {
        onTabs(evt);
      }
    } else {
      evt.moveBy(0, -GraphTabs.DefaultTabHeight);
      if (onCanvas != null) {
        onCanvas(evt);
      }
    }
  }

  bool shouldUseLibrary(GraphEvent evt) {
    return library.isHovered(evt.pos) ||
        library.mouseMode != LibraryMouseMode.none;
  }

  Iterable<MouseController> getActiveControllers(GraphEvent evt,
      [bool clicking = false]) sync* {
    if (editor.isModalActive) {
      if (editor.menu.visible) {
        yield menu;
      }
    } else {
      var useCanvas =
          clicking && shouldAutoPan(evt) || canvas.panning || canvas.zooming;

      if (useCanvas) {
        yield canvas;
      } else {
        if (shouldUseLibrary(evt)) {
          yield library;
        } else {
          yield editor;
          yield graph;
        }
      }
    }
  }

  // ***************************************************************
  //
  //  Touch Events
  //
  // ***************************************************************

  void onTouchStartTabs(GraphEvent evt) {
    onMouseMoveTabs(evt);
    onMouseDownTabs(evt);
  }

  void handleMultiTouch(GraphEvent evt) {
    // prevent multitouch in menu mode and other complex scenarios
    if (editor.isModalActive) return;

    var mode = evt.touches.length > 1;
    if (editor.setMultiMode(mode)) {
      editor.cancelEditing();
    }

    // first touch is the control point ... if it is stable then we
    // we use the second touch point and modify its ctrl/shift keys
    var meta = evt.touches[1];

    if (meta != null) {
      evt.pos = meta.pos;
      // need to save this value for the mouseup/touchup events

      GraphEvent.last.pos = evt.pos;
      if (editor.isPanMode) evt.ctrlKey = true;
      if (editor.isSelectMode) evt.shiftKey = true;

      // aside from modal mode the only options are pan/zoom or editing
      if (canvas.panning || canvas.zooming) {
        canvas.stopPanning();
      }
    }
  }

  void onTouchStartCanvas(GraphEvent evt) {
    handleMultiTouch(evt);
    onMouseMoveCanvas(evt);
    onMouseDownCanvas(evt);
  }

  void onTouchMoveTabs(GraphEvent evt) {
    onMouseMoveTabs(evt);
  }

  void onTouchMoveCanvas(GraphEvent evt) {
    handleMultiTouch(evt);
    onMouseMoveCanvas(evt);
  }

  void onTouchEndTabs(GraphEvent evt) {
    onMouseUpTabs(evt);
    onMouseOutTabs();
  }

  void onTouchEndCanvas(GraphEvent evt) {
    handleMultiTouch(evt);
    onMouseUpCanvas(evt);
    onMouseOutCanvas();
  }

  void onTouchCancel(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    onMouseOut(evt, context, isActive);
    editor.cancelEditing();
  }

  void onTouchStart(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    var touch = evt.touches[0];
    if (touch == null) return;
    evt.pos = touch.pos;
    GraphEvent.last.pos = evt.pos;

    dispatchEvent(
      evt,
      context,
      onTabs: onTouchStartTabs,
      onCanvas: onTouchStartCanvas,
    );
  }

  void onTouchMove(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    var touch = evt.touches[0];
    if (touch == null) return;
    evt.pos = touch.pos;
    GraphEvent.last.pos = evt.pos;

    dispatchEvent(
      evt,
      context,
      onTabs: onTouchMoveTabs,
      onCanvas: onTouchMoveCanvas,
    );
  }

  void onTouchEnd(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    var touch = evt.touches[0];
    if (touch != null) {
      return;
    }
    evt.pos = GraphEvent.last.pos;

    dispatchEvent(
      evt,
      context,
      onTabs: onTouchEndTabs,
      onCanvas: onTouchEndCanvas,
    );
  }

  // ***************************************************************
  //
  //  Mouse Move Events
  //
  // ***************************************************************

  void onMouseMoveTabs(GraphEvent evt) {
    onMouseOutCanvas();
    tabs.onMouseMove(evt);
  }

  void onMouseMoveCanvas(GraphEvent evt) {
    onMouseOutTabs();

    if (editor.longPress.active) {
      if (library.isHovered(evt.pos)) {
        editor.cancelLongPress();
      } else {
        editor.checkLongPress(evt);
      }
    }

    var ls = getActiveControllers(evt).toList();
    if (!ls.contains(library)) library.onMouseOut();
    if (!ls.contains(graph)) graph.onMouseOut();
    if (!ls.contains(editor)) editor.onMouseOut();
    if (!ls.contains(canvas)) canvas.onMouseOut();
    if (!ls.contains(menu)) menu.onMouseOut();

    for (var active in ls) {
      active.onMouseMove(evt);
    }
  }

  void onMouseMove(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    dispatchEvent(
      evt,
      context,
      onTabs: onMouseMoveTabs,
      onCanvas: onMouseMoveCanvas,
    );
  }

  void onMouseOutTabs() {
    tabs.onMouseOut();
  }

  void onMouseOutCanvas() {
    editor.cancelLongPress();
    graph.onMouseOut();
    canvas.onMouseOut();
    menu.onMouseOut();
    library.onMouseOut();
  }

  void onMouseOut(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    onMouseOutTabs();
    onMouseOutCanvas();
  }

  // ***************************************************************
  //
  //  Mouse Down Events
  //
  // ***************************************************************

  void onMouseDoubleTap(GraphEvent evt) {
    if (library.isHovered(evt.pos)) {
      library.onMouseDoubleTap(evt);
      return;
    }

    onMouseOutCanvas();
    onMouseOutTabs();

    canvas.onMouseDoubleTap(evt);
    tabs.onMouseDoubleTap(evt);
    graph.onMouseDoubleTap(evt);

    canvas.stopPanning();
    editor.hideMenu();
    editor.cancelEditing();
  }

  void onMouseDownTabs(GraphEvent evt) {
    GraphEvent.start = evt;
    onMouseOutCanvas();
    tabs.onMouseDown(evt);
  }

  bool shouldAutoPan(GraphEvent evt) {
    if (library.isHovered(evt.pos)) return false;

    if (editor.isViewMode) return true;

    if (evt.ctrlKey) return false;
    if (evt.shiftKey) return true;
    if (graph.focus != null) return false;

    if (editor.isTouchMode) return editor.isPanMode;

    if (!editor.isTouchMode && graph.selection.length > 1) {
      return false;
    }

    return editor.isPanMode;
  }

  void onMouseDownCanvas(GraphEvent evt) {
    onMouseOutTabs();

    var dt = editor.timer - GraphEvent.start.timer;
    if (dt < Duration(milliseconds: 500) &&
        GraphEvent.last.touches.length <= 1) {
      onMouseDoubleTap(evt);
      return;
    }

    if (!library.isHovered(evt.pos) && !editor.isViewMode) {
      GraphEvent.start = evt;
      editor.startLongPress(evt);
    }

    for (var active in getActiveControllers(evt, true)) {
      active.onMouseDown(evt);
    }
  }

  void onMouseDown(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;
    if (evt.buttons == 2) {
      dispatchEvent(
        evt,
        context,
        onTabs: onContextMenuTabs,
        onCanvas: onContextMenuCanvas,
      );
      return;
    }

    dispatchEvent(
      evt,
      context,
      onTabs: onMouseDownTabs,
      onCanvas: onMouseDownCanvas,
    );
  }

  // ***************************************************************
  //
  //  Mouse Up Events
  //
  // ***************************************************************

  void onMouseUpTabs(GraphEvent evt) {
    onMouseOutCanvas();
    graph.onMouseOut();
    tabs.onMouseUp(evt);
  }

  void onMouseUpCanvas(GraphEvent evt) {
    onMouseOutTabs();
    editor.cancelLongPress();

    for (var active in getActiveControllers(evt)) {
      active.onMouseUp(evt);
    }
  }

  void onMouseUp(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;
    if (evt.buttons == 2) return;

    dispatchEvent(
      evt,
      context,
      onTabs: onMouseUpTabs,
      onCanvas: onMouseUpCanvas,
    );
  }

  // ***************************************************************
  //
  //  Context Menu Events
  //
  // ***************************************************************

  void onContextMenuCanvas(GraphEvent evt) {
    onMouseOutTabs();

    if (editor.isViewMode) return;

    if (editor.isModalActive && !editor.menu.visible) {
      return;
    }

    for (var active in getActiveControllers(evt)) {
      active.onContextMenu(evt);
    }
  }

  void onContextMenuTabs(GraphEvent evt) {
    onMouseOutCanvas();
  }

  void onContextMenu(GraphEvent evt, BuildContext context, bool isActive) {
    evt.preventDefault();

    if (!isActive) return;
    print("Context Menu");

    dispatchEvent(
      evt,
      context,
      onTabs: onContextMenuTabs,
      onCanvas: onContextMenuCanvas,
    );
  }

  void onMouseWheelTabs(GraphEvent evt) {
    onMouseOutCanvas();
  }

  void onMouseWheelCanvas(GraphEvent evt) {
    onMouseOutTabs();

    if (editor.isModalActive) {
      return;
    }
    if (evt.pos.dx > canvas.size.width) {
      library.onMouseWheel(evt);
    } else {
      canvas.onMouseWheel(evt);
    }
  }

  void onMouseWheel(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    dispatchEvent(
      evt,
      context,
      onTabs: onMouseWheelTabs,
      onCanvas: onMouseWheelCanvas,
    );
  }
}
