import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';
import 'package:tide_ui/graph_editor/painter/graph_link_painter.dart';

import '../data/canvas_state.dart';
import '../data/graph_state.dart';
import '../utility/dashed_path.dart';
import '../data/graph.dart';

import 'canvas_grid_painter.dart';
import 'graph_node_painter.dart';

class CanvasPainter extends CustomPainter {
  final GraphEditorController editor;

  CanvasState get state => editor.canvas;
  GraphState get graph => editor.graph;

  final CanvasGridPainter gridPainter = CanvasGridPainter();
  final GraphNodePainter nodePainter = GraphNodePainter();
  final GraphLinkPainter linkPainter = GraphLinkPainter();

  CanvasPainter(this.editor);

  @override
  void paint(Canvas canvas, Size size) {
    var screen = Rect.fromLTRB(
        0, 0, size.width - graph.controller.paddingRight, size.height);
    state.controller.size = screen.size;
    var pan = screen.inflate(-Graph.AutoPanMargin);

    state.controller.setClip(
      screen,
      pan,
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
      nodePainter.paint(canvas, state.scale, node);
    }

    for (var node in graph.nodes) {
      if (!node.selected) continue;
      nodePainter.paint(canvas, state.scale, node);
    }

    if (graph.controller.dropping != null) {
      drawDropPreview(canvas, graph.controller.dropping);
    }

    canvas.restore();

    if (graph.controller.selecting) {
      var sr = graph.controller.selectRect;

      var p1 = state.toScreenCoord(sr.topLeft);
      var p2 = state.toScreenCoord(sr.bottomRight);

      drawSelectBorder(canvas, Rect.fromPoints(p1, p2));
    }

    drawZoomSlider(canvas, size);

    if (Graph.ShowPanRect) {
      canvas.drawRect(pan, Graph.redPen);
    }
  }

  void drawDropPreview(Canvas canvas, GraphSelection dropping) {
    canvas.save();
    canvas.translate(dropping.pos.dx, dropping.pos.dy);

    for (var node in dropping.nodes) {
      nodePainter.paint(canvas, state.scale, node);
    }

    canvas.restore();
  }

  void drawZoomSlider(Canvas canvas, Size size) {
    var delta = Graph.MaxZoomScale - Graph.MinZoomScale;
    var pos = (state.scale - Graph.MinZoomScale) / delta;

    var cx = size.width -
        Graph.ZoomSliderLeftMargin -
        Graph.ZoomSliderRightMargin -
        graph.controller.paddingRight;

    cx *= pos;
    cx += Graph.ZoomSliderLeftMargin;

    var cy = size.height - Graph.ZoomSliderBottomMargin;
    var p0 = Offset(cx, cy);
    var p1 = Offset(Graph.ZoomSliderLeftMargin, cy);
    var p2 = Offset(
        size.width -
            Graph.ZoomSliderRightMargin -
            graph.controller.paddingRight,
        cy);

    canvas.drawLine(p1, p0, Graph.ZoomSliderLeftLine);
    canvas.drawLine(p0, p2, Graph.ZoomSliderRightLine);
    canvas.drawCircle(p0, Graph.ZoomSliderSize, Graph.ZoomSliderColor);
    canvas.drawCircle(p0, Graph.ZoomSliderSize, Graph.ZoomSliderOutline);

    VectorIcons.paint(canvas, "search", p0, Graph.ZoomSliderSize,
        fill: Graph.ZoomSliderIconColor);
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
