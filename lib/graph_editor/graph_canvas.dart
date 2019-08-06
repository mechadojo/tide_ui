import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'data/canvas_state.dart';
import 'canvas_grid_painter.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CanvasState>(context, listen: true);
    final graph = Provider.of<GraphState>(context, listen: true);

    //print("Rebuild Canvas");
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasGridPainter(
          pos: state.pos,
          scale: state.scale,
        ),
        child: Container(
          alignment: Alignment.topLeft,
          child: Flow(
            delegate: GraphFlowDelegate(
              pos: state.pos,
              scale: state.scale,
              graph: graph,
            ),
            children: [...graph.getNodes(state.scale)],
          ),
        ),
      ),
    );
  }
}

class GraphFlowDelegate extends FlowDelegate {
  double scale;
  Offset pos;
  GraphState graph;
  GraphFlowDelegate({this.scale, this.pos, this.graph});

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = 0.0;
    double dx = 0.0;
    for (int i = 0; i < context.childCount; ++i) {
      var m = Matrix4.identity();

      m.scale(scale, scale);
      m.translate(pos.dx, pos.dy);

      m.translate(dx, dy);

      context.paintChild(i, transform: m);
      dx += 50;
      dy += 50;
    }
  }

  @override
  bool shouldRepaint(GraphFlowDelegate oldDelegate) {
    return scale != oldDelegate.scale ||
        pos != oldDelegate.pos ||
        graph.version != oldDelegate.graph.version ||
        graph.id != oldDelegate.graph.id;
  }
}
