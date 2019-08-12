import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/painter/graph_link_painter.dart';

import '../data/canvas_state.dart';
import '../data/graph_state.dart';
import '../utility/dashed_path.dart';
import '../data/graph.dart';

import 'canvas_grid_painter.dart';
import 'graph_node_painter.dart';

class CanvasPainter extends CustomPainter {
  final CanvasState state;
  final GraphState graph;

  final CanvasGridPainter gridPainter = CanvasGridPainter();
  final GraphNodePainter nodePainter = GraphNodePainter();
  final GraphLinkPainter linkPainter = GraphLinkPainter();

  CanvasPainter(this.state, this.graph);

  @override
  void paint(Canvas canvas, Size size) {
    var screen = Rect.fromLTRB(0, 0, size.width, size.height);
    state.size = size;

    state.controller.setClip(
      screen,
      screen.inflate(-Graph.AutoPanMargin),
    );

    gridPainter.paint(canvas, size, state.pos, state.scale);

    canvas.save();

    canvas.scale(state.scale, state.scale);
    canvas.translate(state.pos.dx, state.pos.dy);

    for (var link in graph.links) {
      linkPainter.paint(canvas, size, state.pos, state.scale, link);
    }

    if (graph.controller.linking) {
      var p1 = graph.controller.linkStart.pos;
      var p2 = graph.controller.moveEnd;
      if (graph.controller.linkStart.type == NodePortType.outport) {
        linkPainter.paintPoints(canvas, size, state.pos, state.scale, p1, p2);
      } else {
        linkPainter.paintPoints(canvas, size, state.pos, state.scale, p2, p1);
      }
    }

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
