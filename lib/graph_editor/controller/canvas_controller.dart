import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';

import 'graph_editor_comand.dart';
import 'graph_event.dart';

class CanvasController with MouseController, KeyboardController {
  GraphEditorController editor;
  CanvasState get canvas => editor.canvas;

  CanvasController(this.editor);

  Size size = Size.zero;

  /// The region of the graph that is visible
  Rect clipRect = Rect.zero;

  /// A region of the graph that pans while dragging
  Rect panRectGraph = Rect.zero;
  Rect panRectScreen = Rect.zero;
  Rect menuLimits = Rect.zero;

  bool panning = false;
  bool zooming = false;

  double scaleStart = 0;
  Offset centerStart = Offset.zero;
  Offset posStart = Offset.zero;
  Offset panStart = Offset.zero;

  void setTouchMode(bool mode) {
    if (mode == editor.isTouchMode) return;

    canvas.beginUpdate();
    editor.setTouchMode(mode);
    canvas.endUpdate(true);
  }

  Rect setClip(Rect clip, Rect pan) {
    menuLimits = clip.deflate(Graph.RadialMenuMargin);

    panRectScreen = pan;
    clipRect = Rect.fromPoints(
        toGraphCoord(clip.topLeft), toGraphCoord(clip.bottomRight));
    panRectGraph = Rect.fromPoints(
        toGraphCoord(pan.topLeft), toGraphCoord(pan.bottomRight));

    return clipRect;
  }

  void startPanning(Offset pt, Offset center) {
    if (pt.dy > panRectScreen.bottom) {
      editor.dispatch(GraphEditorCommand.setCursor("zoom-in"));
      zooming = true;
    } else {
      panning = true;
      editor.dispatch(GraphEditorCommand.setCursor("grab"));
    }

    scaleStart = canvas.scale;
    centerStart = center;

    posStart = canvas.pos;
    panStart = pt;
  }

  void stopPanning() {
    editor.dispatch(GraphEditorCommand.setCursor("default"));
    zooming = false;
    panning = false;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    stopPanning();
    return true;
  }

  @override
  bool onMouseDown(GraphEvent evt) {
    var center = editor.graph.controller.selection.isEmpty
        ? panRectGraph.center
        : editor.graph.selectionExtents.center;

    startPanning(evt.pos, center);
    return true;
  }

  @override
  bool onMouseMove(GraphEvent evt) {
    var pt = getPos(evt.pos);

    if (zooming) {
      var rect = panRectScreen;
      rect = rect.inflate(Graph.AutoPanMargin); // convert to full canvas

      var delta = Graph.MaxZoomScale - Graph.MinZoomScale;

      var width =
          rect.width - Graph.ZoomSliderLeftMargin - Graph.ZoomSliderRightMargin;
      var cx = (evt.pos.dx - Graph.ZoomSliderLeftMargin) / width;
      var scale = cx * delta + Graph.MinZoomScale;

      if (scale < Graph.MinZoomScale) scale = Graph.MinZoomScale;
      if (scale > Graph.MaxZoomScale) scale = Graph.MaxZoomScale;

      editor.dispatch(GraphEditorCommand.setCursor(
          scale < canvas.scale ? "zoom-out" : "zoom-in"));

      canvas.beginUpdate();
      canvas.zoomAt(scale, centerStart);
      canvas.endUpdate(true);
    }

    if (panning) {
      var dx = posStart.dx + (pt.dx - panStart.dx) / canvas.scale;
      var dy = posStart.dy + (pt.dy - panStart.dy) / canvas.scale;

      canvas.beginUpdate();
      canvas.scrollTo(Offset(dx, dy));
      canvas.endUpdate(true);
    }
    return true;
  }

  @override
  bool onKeyDown(GraphEvent evt) {
    if (evt.key == "h") {
      canvas.beginUpdate();
      canvas.reset();
      canvas.endUpdate(true);
      return true;
    }
    return false;
  }

  @override
  bool onMouseWheel(GraphEvent evt) {
    var pt = toGraphCoord(evt.pos);

    // Control Scroll = Zoom at Cursor
    if (evt.ctrlKey) {
      canvas.beginUpdate();
      if (evt.deltaY > 0) {
        canvas.zoomOut(focus: pt);
      } else {
        canvas.zoomIn(focus: pt);
      }
      canvas.endUpdate(true);
    } else if (evt.shiftKey) {
      // Pan Left/Right

      canvas.beginUpdate();
      canvas.scrollBy(evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize, 0);
      canvas.endUpdate(true);
    } else {
      // Pan Up/Down
      canvas.beginUpdate();
      canvas.scrollBy(0, evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize);
      canvas.endUpdate(true);
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
