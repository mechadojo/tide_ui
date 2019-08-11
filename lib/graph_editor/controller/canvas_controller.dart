import 'dart:html';
import 'dart:js' as js;
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

class CanvasController with MouseController, KeyboardController {
  CanvasState canvas;

  CanvasController(this.canvas);

  /// The region of the graph that is visible
  Rect clipRect = Rect.zero;

  /// A region of the graph that pans while dragging
  Rect panRect = Rect.zero;

  bool panning = false;
  Offset posStart = Offset.zero;
  Offset panStart = Offset.zero;

  String cursor = "default";

  Rect setClip(Rect clip, Rect pan) {
    clipRect = Rect.fromPoints(
        toGraphCoord(clip.topLeft), toGraphCoord(clip.bottomRight));
    panRect = Rect.fromPoints(
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

  void startPanning(Offset pt) {
    setCursor("grab");
    panning = true;
    posStart = canvas.pos;
    panStart = pt;
  }

  void stopPanning() {
    setCursor("default");
    panning = false;
  }

  @override
  bool onMouseMove(MouseEvent evt, Offset pt) {
    if (evt.buttons != 1) {
      stopPanning();
      return true;
    }

    var dx = posStart.dx + (pt.dx - panStart.dx) / canvas.scale;
    var dy = posStart.dy + (pt.dy - panStart.dy) / canvas.scale;

    canvas.scrollTo(Offset(dx, dy));
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
