import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
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

    var pt = globalToLocal(rb, evt.pos);
    if (pt == null) return;

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      if (onTabs != null) {
        evt.pos = pt;
        onTabs(evt);
      }
    } else {
      pt = pt.translate(0, -GraphTabs.DefaultTabHeight);
      evt.pos = pt;
      if (onCanvas != null) {
        onCanvas(evt);
      }
    }
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
        yield editor;
        yield graph;
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

  void onTouchStartCanvas(GraphEvent evt) {
    onMouseMoveCanvas(evt);
    onMouseDownCanvas(evt);
  }

  void onTouchMoveTabs(GraphEvent evt) {
    onMouseMoveTabs(evt);
  }

  void onTouchMoveCanvas(GraphEvent evt) {
    onMouseMoveCanvas(evt);
  }

  void onTouchEndTabs(GraphEvent evt) {
    onMouseUpTabs(evt);
    onMouseOutTabs();
  }

  void onTouchEndCanvas(GraphEvent evt) {
    onMouseUpCanvas(evt);
    onMouseOutCanvas();
  }

  void onTouchStart(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    var touch = evt.touches[0];
    if (touch == null) return;
    evt.pos = touch.pos;
    GraphEvent.last.pos = evt.pos;
    print("Touch: ${evt.pos}, Mouse: ${GraphEvent.last.pos}");

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

    for (var active in getActiveControllers(evt)) {
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
    graph.onMouseOut();
    canvas.onMouseOut();
    menu.onMouseOut();
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

  void onMouseDoubleTap() {
    onMouseOutCanvas();
    onMouseOutTabs();

    canvas.onMouseDoubleTap();
    tabs.onMouseDoubleTap();
    graph.onMouseDoubleTap();
    canvas.stopPanning();
    editor.hideMenu();
  }

  void onMouseDownTabs(GraphEvent evt) {
    onMouseOutCanvas();
    tabs.onMouseDown(evt);
  }

  bool shouldAutoPan(GraphEvent evt) {
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

    for (var active in getActiveControllers(evt, true)) {
      active.onMouseDown(evt);
    }
  }

  void onMouseDown(GraphEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;
    if (evt.buttons == 2) return;

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

    graph.onContextMenu(evt);
  }

  void onContextMenuTabs(GraphEvent evt) {
    onMouseOutCanvas();
  }

  void onContextMenu(GraphEvent evt, BuildContext context, bool isActive) {
    evt.preventDefault();

    if (!isActive) return;

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

    canvas.onMouseWheel(evt);
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
