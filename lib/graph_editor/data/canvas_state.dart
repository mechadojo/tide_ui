import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';

class CanvasState with ChangeNotifier {
  CanvasController controller;

  final double minScale = 0.1316872427983539;
  final double maxScale = 5.0625;
  double get stepSize => 100 / scale;

  Offset pos = Offset.zero;
  Offset get screenPos => toScreenCoord(pos);
  double scale = 1.0;
  bool debugMode = true;
  bool touchMode = false;

  void beginUpdate() {}

  void endUpdate(bool changed) {
    if (changed) notifyListeners();
  }

  bool copy(CanvasState other) {
    bool changed = false;

    beginUpdate();
    if (this.scale != other.scale) {
      this.scale = other.scale;
      changed = true;
    }

    if (this.pos != other.pos) {
      this.pos = other.pos;
      changed = true;
    }

    endUpdate(changed);
    return changed;
  }

  void scrollTo(Offset pos) {
    this.pos = pos;
    //log("Position: ${pos.dx}, ${pos.dy}");
    notifyListeners();
  }

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

  void scrollBy(double dx, double dy) {
    scrollTo(pos.translate(dx, dy));
  }

  void log(Object object, [bool debug = true]) {
    if (debugMode || !debug) {
      print(object);
    }
  }

  void reset() {
    pos = Offset.zero;
    scale = 1.0;
    log("Reset Canvas State");
    notifyListeners();
  }

  void zoomAt(double next, Offset center) {
    if (next > maxScale) next = maxScale;
    if (next < minScale) next = minScale;

    var dx = (center.dx + pos.dx) * scale / next - pos.dx - center.dx;
    var dy = (center.dy + pos.dy) * scale / next - pos.dy - center.dy;
    pos = pos.translate(dx, dy);
    scale = next;

    //log("Scale To: $scale  $center");
    notifyListeners();
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
