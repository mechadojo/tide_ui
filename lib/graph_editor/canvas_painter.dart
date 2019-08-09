import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/canvas_grid_painter.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/graph_node_painter.dart';
import 'package:tide_ui/graph_editor/utility/dashed_path.dart';

import 'data/graph.dart';

class CanvasPainter extends CustomPainter {
  final CanvasState state;
  final GraphState graph;

  final CanvasGridPainter gridPainter = CanvasGridPainter();
  final GraphNodePainter nodePainter = GraphNodePainter();

  CanvasPainter(this.state, this.graph);

  @override
  void paint(Canvas canvas, Size size) {
    gridPainter.paint(canvas, size, state.pos, state.scale);

    canvas.save();

    canvas.scale(state.scale, state.scale);
    canvas.translate(state.pos.dx, state.pos.dy);

    for (var node in graph.nodes) {
      if (node.selected) continue;
      nodePainter.paint(canvas, size, state.pos, state.scale, node);
    }

    for (var node in graph.nodes) {
      if (!node.selected) continue;
      nodePainter.paint(canvas, size, state.pos, state.scale, node);
    }

    canvas.restore();

    if (graph.controller.selecting) {
      var sr = graph.controller.selectRect;

      var p1 = state.toScreenCoord(sr.topLeft);
      var p2 = state.toScreenCoord(sr.bottomRight);

      drawSelectBorder(canvas, Rect.fromPoints(p1, p2));
    }
  }

  void drawSelectBorder(Canvas canvas, Rect rect) {
    var perim = rect.width * 2 + rect.height * 2;

    var dash = Graph.SelectDashSize;
    if (perim < dash * 5) {
      canvas.drawRect(rect, Graph.SelectionBorder);
      return;
    }

    Path path = createDashedPath(rect, dash);

    canvas.drawPath(path, Graph.SelectionBorder);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return true;
  }
}
