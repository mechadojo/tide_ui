import 'dart:html';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/graph_tabs.dart';

class MouseHandler {
  CanvasTabsController tabs;
  CanvasController canvas;
  GraphController graph;

  MouseHandler(this.canvas, this.tabs, this.graph);

  void onMouseMove(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      graph.onMouseOut();
      tabs.onMouseMove(evt, pt);
    } else {
      tabs.onMouseOut();

      var gpt =
          canvas.toGraphCoord(pt.translate(0, -GraphTabs.DefaultTabHeight));
      graph.onMouseMove(evt, gpt);
    }
  }

  void onMouseOut(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    tabs.onMouseOut();
    graph.onMouseOut();
  }

  void onMouseDown(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      graph.onMouseOut();
      tabs.onMouseDown(evt, pt);
    } else {
      tabs.onMouseOut();

      var gpt =
          canvas.toGraphCoord(pt.translate(0, -GraphTabs.DefaultTabHeight));
      graph.onMouseDown(evt, gpt);
    }
  }

  void onMouseUp(MouseEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    if (pt.dy < GraphTabs.DefaultTabHeight) {
      graph.onMouseOut();
      tabs.onMouseUp(evt, pt);
    } else {
      tabs.onMouseOut();

      var gpt =
          canvas.toGraphCoord(pt.translate(0, -GraphTabs.DefaultTabHeight));
      graph.onMouseUp(evt, gpt);
    }
  }

  void onContextMenu(MouseEvent evt, BuildContext context, bool isActive) {
    // Stop the default context menu
    evt.preventDefault();
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    // adjust coordinates for only events on the graph canvas not the tabs
    if (pt.dy < GraphTabs.DefaultTabHeight) {
      graph.onMouseOut();
      tabs.onContextMenu(evt, pt);
    } else {
      tabs.onMouseOut();
      var gpt =
          canvas.toGraphCoord(pt.translate(0, -GraphTabs.DefaultTabHeight));
      graph.onContextMenu(evt, gpt);
    }
  }

  void onMouseWheel(WheelEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    // adjust coordinates for only events on the graph canvas not the tabs
    if (pt.dy < GraphTabs.DefaultTabHeight) return;

    var gpt = canvas.toGraphCoord(pt.translate(0, -GraphTabs.DefaultTabHeight));

    canvas.onMouseWheel(evt, gpt);
  }
}