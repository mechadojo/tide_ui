import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/painter/canvas_painter.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'data/canvas_state.dart';
import 'data/graph_editor_state.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  Offset globalToLocal(BuildContext context, Offset pt) {
    try {
      RenderBox rb = context.findRenderObject();

      return rb.globalToLocal(pt);
    } catch (ex) {
      print(ex.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<GraphEditorState>(context, listen: false);
    final canvas = Provider.of<CanvasStateNotifier>(context, listen: true);
    final graph = Provider.of<GraphStateNotifier>(context, listen: true);

    if (canvas.canvas == null || graph.graph == null) return Container();

    //print("Rebuild Canvas");
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasPainter(editor.controller),
        child: Container(
          alignment: Alignment.topLeft,
          child: Container(),
        ),
      ),
    );
  }
}
