import 'dart:html';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/graph_tabs.dart';

typedef OnMouseEvent(MouseEvent evt, Offset pt);
typedef OnWheelEvent(WheelEvent evt, Offset pt);

class MouseHandler {
  GraphEditorController editor;
  CanvasTabsController get tabs => editor.tabs.controller;
  CanvasController get canvas => editor.canvas.controller;
  GraphController get graph => editor.graph.controller;
  KeyboardHandler get keyboard => editor.keyboardHandler;

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

  void dispatchEvent(MouseEvent evt, BuildContext context,
      {OnMouseEvent onTabs, OnMouseEvent onCanvas}) {
    RenderBox rb = context.findRenderObject();

    var pt = globalToLocal(rb, Offset(evt.client.x, evt.client.y));
    if (pt == null) return;

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      if (onTabs != null) {
        onTabs(evt, pt);
      }
    } else {
      pt = pt.translate(0, -GraphTabs.DefaultTabHeight);
      if (onCanvas != null) {
        onCanvas(evt, pt);
      }
    }
  }

  void dispatchWheelEvent(WheelEvent evt, BuildContext context,
      {OnWheelEvent onTabs, OnWheelEvent onCanvas}) {
    RenderBox rb = context.findRenderObject();
    var pt = globalToLocal(rb, Offset(evt.client.x, evt.client.y));
    if (pt == null) return;

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      if (onTabs != null) {
        onTabs(evt, pt);
      }
    } else {
      pt = pt.translate(0, -GraphTabs.DefaultTabHeight);
      if (onCanvas != null) {
        onCanvas(evt, pt);
      }
    }
  }

  // ***************************************************************
  //
  //  Mouse Move Events
  //
  // ***************************************************************

  void onMouseMoveTabs(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
    tabs.onMouseMove(evt, pt);
  }

  void onMouseMoveCanvas(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();

    if (canvas.panning) {
      canvas.onMouseMove(evt, pt);
    } else {
      editor.onMouseMove(evt, pt);

      var gpt = canvas.toGraphCoord(pt);
      graph.onMouseMove(evt, gpt);
    }
  }

  void onMouseMove(MouseEvent evt, BuildContext context, bool isActive) {
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
  }

  void onMouseOut(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    tabs.onMouseOut();
    graph.onMouseOut();
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
  }

  void onMouseDownTabs(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
    graph.onMouseOut();
    tabs.onMouseDown(evt, pt);
  }

  bool shouldAutoPan(MouseEvent evt) {
    if (evt.ctrlKey) return false;
    if (graph.focus != null) return false;
    if (!canvas.touchMode && graph.selection.length > 1) {
      return false;
    }

    return evt.shiftKey || editor.isPanMode;
  }

  void onMouseDownCanvas(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.touchMode) return;

    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();

    if (shouldAutoPan(evt)) {
      canvas.startPanning(pt);
    } else {
      var gpt = canvas.toGraphCoord(pt);

      graph.onMouseDown(evt, gpt);
    }
  }

  void onMouseDown(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

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

  void onMouseUpTabs(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
    graph.onMouseOut();
    tabs.onMouseUp(evt);
  }

  void onMouseUpCanvas(MouseEvent evt, [Offset pt = Offset.zero]) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();
    canvas.stopPanning();
    graph.onMouseUp(evt);
  }

  void onMouseUp(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;
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

  void onContextMenuCanvas(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();
    print("Open Radial Menu: $pt");
  }

  void onContextMenuTabs(MouseEvent evt, Offset pt) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
    print("Open Tabs Context Menu: $pt");
  }

  void onContextMenu(MouseEvent evt, BuildContext context, bool isActive) {
    evt.preventDefault();

    if (!isActive) return;

    dispatchEvent(
      evt,
      context,
      onTabs: onContextMenuTabs,
      onCanvas: onContextMenuCanvas,
    );
  }

  void onMouseWheelTabs(WheelEvent evt, Offset pt) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
  }

  void onMouseWheelCanvas(WheelEvent evt, Offset pt) {
    if (evt == null && !canvas.canvas.touchMode) return;
    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();

    var gpt = canvas.toGraphCoord(pt);
    canvas.onMouseWheel(evt, gpt);
  }

  void onMouseWheel(WheelEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    dispatchWheelEvent(
      evt,
      context,
      onTabs: onMouseWheelTabs,
      onCanvas: onMouseWheelCanvas,
    );
  }
}
