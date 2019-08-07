import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/canvas_grid_painter.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/graph_node_painter.dart';

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
      nodePainter.paint(canvas, size, state.pos, state.scale, node);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return true;
  }
}
