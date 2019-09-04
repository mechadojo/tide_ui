import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/gamepad_state.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/widget_state.dart';

import 'gamepad_painter.dart';

class WidgetNodePainter {
  static Map<WidgetNodeType, WidgetNodePainter> widgetPainters = {
    WidgetNodeType.gamepad: GamepadPainter()
  };

  static Map<WidgetNodeType, WidgetState> widgetDefaultState = {
    WidgetNodeType.gamepad: GamepadState()
  };

  static void paintNode(Canvas canvas, GraphNode node,
      {WidgetState state, double scale = 1}) {
    var painter = widgetPainters[node.widget];
    if (painter == null) return;

    canvas.save();
    canvas.translate(node.pos.dx, node.pos.dy);

    state = state ?? widgetDefaultState[node.widget];
    painter.paint(canvas, node.size, state, scale, node: node);
    canvas.restore();

    painter.drawNode(canvas, node, scale);
  }

  void drawNode(Canvas canvas, GraphNode node, double scale) {}

  static void paintWidget(Canvas canvas, WidgetNodeType type, Size size,
      [WidgetState state, double scale = 1]) {
    var painter = widgetPainters[type];

    if (painter != null) {
      state = state ?? widgetDefaultState[type];
      painter.paint(canvas, size, state, scale);
    }
  }

  static Size measureWidget(WidgetNodeType type, Size size,
      [WidgetState state, double scale = 1]) {
    var painter = widgetPainters[type];

    if (painter != null) {
      state = state ?? widgetDefaultState[type];
      return painter.measure(size, state, scale);
    } else {
      return size;
    }
  }

  Size measure(Size size, WidgetState state, double scale) {
    return size;
  }

  void paint(Canvas canvas, Size size, WidgetState state, double scale,
      {GraphNode node}) {}
}
