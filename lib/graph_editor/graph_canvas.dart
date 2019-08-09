import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/painter/canvas_painter.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'data/canvas_state.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    final canvas = Provider.of<CanvasState>(context, listen: true);
    final graph = Provider.of<GraphState>(context, listen: true);

    //print("Rebuild Canvas");
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasPainter(
          canvas,
          graph,
        ),
        child: Container(
          alignment: Alignment.topLeft,
          child: Container(),
        ),
      ),
    );
  }
}
