import 'package:flutter/material.dart';

mixin CanvasInteractive {
  bool disabled = false;
  bool selected = false;
  bool hovered = false;
  bool selecting = false;
  bool alerted = false;
  bool dragging = false;

  Rect hitbox = Rect.zero;
  Rect extents = Rect.zero;
  Offset pos = Offset.zero;
  Size size = Size.zero;

  Offset dragStart = Offset.zero;
  Offset dragOffset = Offset.zero;

  String alertText = "";

  bool isHovered(Offset pt) {
    return hitbox.contains(pt);
  }

  bool clearInteractive() {
    var changed = false;
    for (var item in interactive()) {
      changed |= item.disabled;
      item.disabled = false;
      changed |= item.selected;
      item.selected = false;
      changed |= item.hovered;
      item.hovered = false;
      changed |= item.selected;
      item.selected = false;
      changed |= item.alerted;
      item.alerted = false;
      changed |= item.dragging;
      item.dragging = false;

      if (dragStart != Offset.zero) changed = true;
      dragStart = Offset.zero;

      if (dragOffset != Offset.zero) changed = true;
      dragOffset = Offset.zero;

      if (alertText.isNotEmpty) changed = true;
      alertText = "";
    }

    return changed;
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

  bool moveTo(double dx, double dy, {bool update = false}) {
    if (pos.dx != dx || pos.dy != dy || update) {
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
