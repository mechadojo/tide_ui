import 'dart:html';
import 'dart:js' as js;
import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';

class CanvasController with MouseController, KeyboardController {
  GraphEditorController editor;
  CanvasState get canvas => editor.canvas;

  bool get touchMode => canvas.touchMode;

  CanvasController(this.editor);

  /// The region of the graph that is visible
  Rect clipRect = Rect.zero;

  /// A region of the graph that pans while dragging
  Rect panRectGraph = Rect.zero;
  Rect panRectScreen = Rect.zero;

  bool panning = false;
  bool zooming = false;

  double scaleStart = 0;
  Offset centerStart = Offset.zero;
  Offset posStart = Offset.zero;
  Offset panStart = Offset.zero;

  String cursor = "default";

  void setTouchMode(bool mode) {
    if (mode == canvas.touchMode) return;
    canvas.beginUpdate();
    canvas.touchMode = mode;
    canvas.endUpdate(true);
  }

  Rect setClip(Rect clip, Rect pan) {
    panRectScreen = pan;
    clipRect = Rect.fromPoints(
        toGraphCoord(clip.topLeft), toGraphCoord(clip.bottomRight));
    panRectGraph = Rect.fromPoints(
        toGraphCoord(pan.topLeft), toGraphCoord(pan.bottomRight));

    return clipRect;
  }

  void setCursor(String next) {
    if (cursor != next) {
      var result = js.context["window"];
      cursor = next;
      result.document.body.style.cursor = cursor;
    }
  }

  void startPanning(Offset pt, Offset center) {
    if (pt.dx > panRectScreen.right) {
      setCursor("zoom-in");
      zooming = true;
    } else {
      panning = true;
      setCursor("grab");
    }

    scaleStart = canvas.scale;
    centerStart = center;

    posStart = canvas.pos;
    panStart = pt;
  }

  void stopPanning() {
    setCursor("default");
    zooming = false;
    panning = false;
  }

  @override
  bool onMouseMove(MouseEvent evt, Offset pt) {
    if (zooming) {
      var rect = panRectScreen;
      rect = rect.inflate(Graph.AutoPanMargin); // convert to full canvas

      if (pt.dy > panStart.dy) {
        var ratio = 1 - (pt.dy - panStart.dy) / (rect.bottom - panStart.dy);
        var scale = scaleStart * ratio;
        if (scale < Graph.MinZoomScale) scale = Graph.MinZoomScale;

        canvas.zoomAt(scale, centerStart);
      } else {
        var ratio = (pt.dy - panStart.dy) / (rect.top - panStart.dy);
        var scale = scaleStart + Graph.MaxZoomScale * ratio;
        if (scale > Graph.MaxZoomScale) scale = Graph.MaxZoomScale;

        canvas.zoomAt(scale, centerStart);
      }
    }

    if (panning) {
      var dx = posStart.dx + (pt.dx - panStart.dx) / canvas.scale;
      var dy = posStart.dy + (pt.dy - panStart.dy) / canvas.scale;

      canvas.scrollTo(Offset(dx, dy));
    }
    return true;
  }

  @override
  bool onKeyDown(KeyboardEvent evt) {
    if (evt.key == "h") {
      canvas.reset();
      return true;
    }
    return false;
  }

  @override
  bool onMouseWheel(WheelEvent evt, Offset pt) {
    // Control Scroll = Zoom at Cursor
    if (evt.ctrlKey) {
      if (evt.deltaY > 0) {
        canvas.zoomOut(focus: pt);
      } else {
        canvas.zoomIn(focus: pt);
      }
    } else if (evt.shiftKey) {
      // Pan Left/Right
      canvas.scrollBy(evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize, 0);
    } else {
      // Pan Up/Down
      canvas.scrollBy(0, evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize);
    }

    return true;
  }

  Offset toGraphCoord(Offset screen) {
    return canvas.toGraphCoord(screen);
  }

  Offset toScreenCoord(Offset graph) {
    return canvas.toScreenCoord(graph);
  }
}
