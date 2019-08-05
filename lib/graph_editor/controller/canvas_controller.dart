import 'dart:html';

import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

class CanvasController with MouseController, KeyboardController {
  CanvasState canvas;

  CanvasController(this.canvas);

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
