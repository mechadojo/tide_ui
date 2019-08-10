import 'dart:html';
import 'package:flutter_web/material.dart';

mixin MouseController {
  bool onMouseMove(MouseEvent evt, Offset pt) {
    return false;
  }

  bool onMouseUp(MouseEvent evt) {
    return false;
  }

  bool onMouseDown(MouseEvent evt, Offset pt) {
    return false;
  }

  bool onMouseOut() {
    return false;
  }

  bool onMouseDoubleTap() {
    return false;
  }

  bool onMouseWheel(WheelEvent evt, Offset pt) {
    return false;
  }

  bool onContextMenu(MouseEvent evt, Offset pt) {
    return false;
  }

  bool onDoubleClick(Offset pt) {
    return false;
  }

  bool onLongPress(Offset pt) {
    return false;
  }
}
