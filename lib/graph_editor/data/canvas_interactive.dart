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
  Size size = Size.zero;

  Offset dragStart = Offset.zero;
  String alertText = "";

  bool isHovered(Offset pt) {
    return hitbox.contains(pt);
  }

  bool checkHovered(Offset pt) {
    if (hovered != isHovered(pt)) {
      hovered = !hovered;
      return true;
    }
    return false;
  }

  Iterable<CanvasInteractive> interactive() sync* {
    yield this;
  }

  void moveBy(double dx, double dy) {
    pos = pos.translate(dx, dy);
    hitbox =
        Rect.fromCenter(center: pos, width: size.width, height: size.height);
  }

  bool moveTo(double dx, double dy) {
    if (pos.dx != dx || pos.dy != dy) {
      pos = Offset(dx, dy);
      hitbox =
          Rect.fromCenter(center: pos, width: size.width, height: size.height);
      return true;
    }
    return false;
  }

  bool resizeTo(double width, double height) {
    if (size.width != width || size.height != height) {
      size = Size(width, height);
      hitbox = Rect.fromCenter(center: pos, width: width, height: height);
      return true;
    }
    return false;
  }
}
