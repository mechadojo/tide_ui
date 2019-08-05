import 'package:flutter_web/material.dart';

mixin CanvasInteractive {
  bool disabled = false;
  bool selected = false;
  bool hovered = false;
  bool selecting = false;
  bool alerted = false;
  bool dragging = false;

  Rect hitbox = Rect.zero;
  Offset pos = Offset.zero;

  Offset dragStart = Offset.zero;
  String alertText = "";

  bool checkHovered(Offset pt) {
    if (hovered != hitbox.contains(pt)) {
      hovered = !hovered;
      return true;
    }
    return false;
  }
}
