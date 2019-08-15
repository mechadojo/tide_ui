import 'package:flutter_web/material.dart';

import 'graph_event.dart';

mixin MouseController {
  Offset getPos(Offset pt) {
    return pt;
  }

  bool onMouseMove(GraphEvent evt) {
    return false;
  }

  bool onMouseUp(GraphEvent evt) {
    return false;
  }

  bool onMouseDown(GraphEvent evt) {
    return false;
  }

  bool onMouseOut() {
    return false;
  }

  bool onMouseDoubleTap() {
    return false;
  }

  bool onMouseWheel(GraphEvent evt) {
    return false;
  }

  bool onContextMenu(GraphEvent evt) {
    return false;
  }

  bool onDoubleClick(GraphEvent evt) {
    return false;
  }

  bool onLongPress(GraphEvent evt) {
    return false;
  }
}
