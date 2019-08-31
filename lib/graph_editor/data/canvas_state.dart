import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/data/graph.dart';

import 'update_notifier.dart';

class CanvasStateNotifier extends UpdateNotifier {
  GraphEditorController editor;
  CanvasState get canvas => editor.canvas;
  CanvasController get controller => editor.canvas.controller;
  CanvasStateNotifier(this.editor);
}

class CanvasState {
  CanvasController controller;

  double get minScale => Graph.MinZoomScale;
  double get maxScale => Graph.MaxZoomScale;
  double get stepSize => 100 / scale;

  Size get size => controller.size;

  Offset pos = Offset.zero;
  Offset get screenPos => toScreenCoord(pos);
  double scale = 1.0;

  Offset toGraphCoord(Offset screen) {
    var dx = screen.dx / scale - pos.dx;
    var dy = screen.dy / scale - pos.dy;

    return Offset(dx, dy);
  }

  Offset toScreenCoord(Offset graph) {
    var dx = (graph.dx + pos.dx) * scale;
    var dy = (graph.dy + pos.dy) * scale;
    return Offset(dx, dy);
  }

  void beginUpdate() {
    controller.editor.canvasNotifier.beginUpdate();
  }

  void endUpdate(bool changed) {
    controller.editor.canvasNotifier.endUpdate(changed);
  }

  void scrollTo(Offset pos) {
    this.pos = pos;
    //log("Position: ${pos.dx}, ${pos.dy}");
  }

  void scrollBy(double dx, double dy) {
    scrollTo(pos.translate(dx, dy));
  }

  void reset() {
    pos = Offset.zero;
    scale = 1.0;
    print("Reset Canvas State");
  }

  void zoomToFit(Rect rect, Size size) {
    var scaleX = size.width / rect.width;
    var scaleY = size.height / rect.height;

    if (scaleX < scaleY) {
      scale = scaleX;
    } else {
      scale = scaleY;
    }

    var dx = ((size.width / scale) - rect.width) / 2;
    var dy = ((size.height / scale) - rect.height) / 2;

    pos = -rect.topLeft;
    pos = pos.translate(dx, dy);
  }

  void zoomAt(double next, Offset center) {
    if (next > maxScale) next = maxScale;
    if (next < minScale) next = minScale;

    var dx = (center.dx + pos.dx) * scale / next - pos.dx - center.dx;
    var dy = (center.dy + pos.dy) * scale / next - pos.dy - center.dy;
    pos = pos.translate(dx, dy);
    scale = next;
  }

  void zoomIn({Offset focus = Offset.zero}) {
    var next = scale * 1.5;
    if (next > maxScale) next = maxScale;

    if (next != scale) {
      zoomAt(next, focus);
    }
  }

  void zoomOut({Offset focus = Offset.zero}) {
    var next = scale / 1.5;
    if (next < minScale) next = minScale;

    if (next != scale) {
      zoomAt(next, focus);
    }
  }
}
