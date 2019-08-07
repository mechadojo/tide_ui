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
    final List<Widget> widgets = [...graph.nodes.map((n) => GraphWidget(n))];

    //print("Rebuild Canvas");
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasGridPainter(
          pos: state.pos,
          scale: state.scale,
        ),
        child: Container(
          alignment: Alignment.topLeft,
          child: Flow.unwrapped(
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
    var pen = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, pen);
    canvas.drawLine(rect.topLeft, rect.bottomRight, pen);
    canvas.drawLine(rect.bottomLeft, rect.topRight, pen);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GraphFlowDelegate extends FlowDelegate {
  double scale;
  Offset pos;
  GraphState graph;
  List<Widget> children;

  GraphFlowDelegate({this.scale, this.pos, this.graph, this.children});

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      var m = Matrix4.identity();

      var child = children[i];
      if (child is GraphWidget) {
        child.obj.scale = scale;
        child.obj.offset = pos;
      } else {
        m.scale(scale, scale);
        m.translate(pos.dx, pos.dy);
      }

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
