import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/graph_node_painter.dart';
import 'data/canvas_state.dart';
import 'canvas_grid_painter.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CanvasState>(context, listen: true);
    final graph = Provider.of<GraphState>(context, listen: true);
    final List<GraphWidget> widgets = [
      ...graph.nodes.map((n) => GraphWidget(n))
    ];

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
                children: widgets),
            children: widgets,
          ),
        ),
      ),
    );
  }
}

class GraphWidget extends StatelessWidget {
  final GraphObject obj;

  GraphWidget(this.obj);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: obj.size.width,
      height: obj.size.height,
      child: CustomPaint(
        child: Container(),
        painter: getPainter(),
      ),
    );
  }

  CustomPainter getPainter() {
    if (obj is GraphNode) return GraphNodePainter(obj as GraphNode);
    return EmptyPainter();
  }
}

class EmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GraphFlowDelegate extends FlowDelegate {
  double scale;
  Offset pos;
  GraphState graph;
  List<GraphWidget> children;

  GraphFlowDelegate({this.scale, this.pos, this.graph, this.children});

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      var m = Matrix4.identity();

      m.scale(scale, scale);
      m.translate(pos.dx, pos.dy);

      var child = children[i];
      m.translate(child.obj.pos.dx, child.obj.pos.dy);

      context.paintChild(i, transform: m);
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
