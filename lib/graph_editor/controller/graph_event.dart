import 'dart:html';

import 'package:flutter/material.dart';

typedef PreventDefault();

Offset globalToLocal(RenderBox rb, Offset pt) {
  if (rb == null) return pt;
  try {
    return rb.globalToLocal(pt);
  } catch (ex) {
    print(ex.toString());
    return null;
  }
}

class GraphTouch {
  int id = 0;

  Offset pos = Offset.zero;

  Size radius = Size.zero;
  double force = 0;
  double angle = 0;

  bool changed = true;

  GraphTouch.touch(Touch touch, [this.changed = true, RenderBox rb]) {
    id = touch.identifier;
    pos = globalToLocal(rb, Offset(touch.client.x, touch.client.y));
    radius = Size(touch.radiusX.toDouble(), touch.radiusY.toDouble());
    force = touch.force;
    angle = touch.rotationAngle;
  }
}

class GraphEvent {
  static GraphEvent last = GraphEvent();
  static GraphEvent start = GraphEvent();

  PreventDefault preventDefault;

  Offset pos = Offset.zero;
  bool ctrlKey = false;
  bool shiftKey = false;
  bool altKey = false;
  bool metaKey = false;
  int buttons = 0;

  int deltaX = 0;
  int deltaY = 0;
  int deltaZ = 0;

  String key = "";
  int keyCode = 0;
  Duration timer = Duration.zero;

  Map<int, GraphTouch> touches = {};

  GraphEvent();

  GraphEvent.copy(GraphEvent other) {
    preventDefault = other.preventDefault;
    pos = other.pos;
    ctrlKey = other.ctrlKey;
    shiftKey = other.shiftKey;
    altKey = other.altKey;
    metaKey = other.metaKey;
    buttons = other.buttons;
    deltaX = other.deltaX;
    deltaY = other.deltaY;
    deltaZ = other.deltaZ;
    key = other.key;
    keyCode = other.keyCode;
    timer = other.timer;
    for (var key in other.touches.keys) {
      touches[key] = other.touches[key];
    }
  }

  GraphEvent.mouse(MouseEvent evt, [RenderBox rb]) {
    pos = globalToLocal(rb, Offset(evt.client.x, evt.client.y));
    ctrlKey = evt.ctrlKey;
    shiftKey = evt.shiftKey;
    altKey = evt.altKey;
    metaKey = evt.metaKey;
    buttons = evt.buttons;

    last.pos = pos;
    last.ctrlKey = ctrlKey;
    last.shiftKey = shiftKey;
    last.altKey = altKey;
    last.metaKey = metaKey;

    last.buttons = buttons;
    preventDefault = evt.preventDefault;
  }

  factory GraphEvent.wheel(WheelEvent evt, [RenderBox rb]) {
    var result = GraphEvent.mouse(evt, rb);

    result.deltaX = evt.deltaX.round();
    result.deltaY = evt.deltaY.round();
    result.deltaZ = evt.deltaZ.round();

    return result;
  }

  GraphEvent.key(KeyboardEvent evt) {
    pos = last.pos;
    buttons = last.buttons;

    ctrlKey = evt.ctrlKey;
    shiftKey = evt.shiftKey;
    altKey = evt.altKey;
    metaKey = evt.metaKey;

    key = evt.key;
    keyCode = evt.keyCode;

    last.ctrlKey = ctrlKey;
    last.shiftKey = shiftKey;
    last.altKey = altKey;
    last.metaKey = metaKey;
    last.key = key;
    last.keyCode = keyCode;

    preventDefault = evt.preventDefault;
  }

  GraphEvent.touch(TouchEvent evt, [RenderBox rb]) {
    ctrlKey = evt.ctrlKey;
    shiftKey = evt.shiftKey;
    altKey = evt.altKey;
    metaKey = evt.metaKey;

    Set<int> changed = {};
    changed.addAll(evt.changedTouches.map((x) => x.identifier));

    for (var touch in evt.touches) {
      touches[touch.identifier] =
          GraphTouch.touch(touch, changed.contains(touch.identifier), rb);
    }

    last.touches = touches;

    last.ctrlKey = ctrlKey;
    last.shiftKey = shiftKey;
    last.altKey = altKey;
    last.metaKey = metaKey;

    preventDefault = evt.preventDefault;
  }

  void moveBy(double dx, double dy) {
    pos = pos.translate(dx, dy);
    for (var touch in touches.values) {
      touch.pos = touch.pos.translate(dx, dy);
    }
  }
}
