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

  void onTapDown(TapDownDetails evt, BuildContext context) {
    int dx = evt.globalPosition.dx.toInt();
    int dy = evt.globalPosition.dy.toInt();
    print("Tap down $dx,$dy");
    var mevt = MouseEvent("", screenX: dx, screenY: dy);

    onMouseDown(mevt, context, true);
  }

  void onTapUp(TapUpDetails evt, BuildContext context) {
    int dx = evt.globalPosition.dx.toInt();
    int dy = evt.globalPosition.dy.toInt();
    print("Tap Up $dx,$dy");
    var mevt = MouseEvent("", screenX: dx, screenY: dy);

    onMouseUp(mevt, context, true);
  }

  void onMouseMoveTabs(MouseEvent evt, Offset pt) {
    onMouseOutCanvas();
    tabs.onMouseMove(evt, pt);
  }

  void onMouseMoveCanvas(MouseEvent evt, Offset pt) {
    onMouseOutTabs();

    if (canvas.panning) {
      canvas.onMouseMove(evt, pt);
    } else {
      var gpt = canvas.toGraphCoord(pt);
      editor.onMouseMove(evt, gpt);
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

  //
  // Mouse Down
  //

  void onMouseDownTabs(MouseEvent evt, Offset pt) {
    evt = evt ?? keyboard.mouse;

    onMouseOutCanvas();
    graph.onMouseOut();
    tabs.onMouseDown(evt, pt);
  }

  void onMouseDownCanvas(MouseEvent evt, Offset pt) {
    evt = evt ?? keyboard.mouse;

    onMouseOutTabs();
    if (evt.shiftKey && !evt.ctrlKey) {
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

  //
  // Mouse Up
  //

  void onMouseUpTabs(MouseEvent evt, Offset pt) {
    evt = evt ?? keyboard.mouse;
    onMouseOutCanvas();
    graph.onMouseOut();
    tabs.onMouseUp(evt);
  }

  void onMouseUpCanvas(MouseEvent evt, [Offset pt = Offset.zero]) {
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

  //
  // Context Menu
  //
  void onContextMenuCanvas(MouseEvent evt, Offset pt) {
    onMouseOutTabs();
    print("Open Radial Menu: $pt");
  }

  void onContextMenuTabs(MouseEvent evt, Offset pt) {
    onMouseOutCanvas();
    print("Open Tabs Context Menu: $pt");
  }

  void onContextMenu(MouseEvent evt, BuildContext context, bool isActive) {
    // Stop the default context menu
    evt.preventDefault();
    if (!isActive) return;

    dispatchEvent(
      evt,
      context,
      onTabs: onContextMenuTabs,
      onCanvas: onContextMenuCanvas,
    );
  }

  void onMouseDoubleTap() {
    onMouseOutCanvas();
    onMouseOutTabs();

    canvas.onMouseDoubleTap();
    tabs.onMouseDoubleTap();
    graph.onMouseDoubleTap();
  }

  void onMouseWheelTabs(WheelEvent evt, Offset pt) {
    onMouseOutCanvas();
  }

  void onMouseWheelCanvas(WheelEvent evt, Offset pt) {
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
