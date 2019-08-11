import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';

class GraphLinkPainter {
  Path createPath(Offset p1, Offset p2) {
    var ctrl = GraphLink.getControlPoints(p1, p2);
    var path = GraphLink.getPath(p1, p2, ctrl);
    return path;
  }

  Map<int, Paint> linkPaints = {};

  Paint getLinkPaint([int group = -1, bool disabled = false]) {
    var result = linkPaints[group];
    if (result != null) return result;

    var color = group == -1
        ? Graph.DefaultLinkColor
        : Graph.getGroupColor(group, disabled);

    result = Paint()
      ..color = color.withAlpha(200)
      ..strokeWidth = Graph.LinkPathWidth
      ..style = PaintingStyle.stroke;

    linkPaints[group] = result;
    return result;
  }

  void drawPath(Canvas canvas, Path path,
      [int group = -1, bool disabled = false, bool hovered = false]) {
    if (hovered) {
      canvas.drawPath(path, Graph.LinkShadowColor);
    }

    var pen = getLinkPaint(group, disabled);
    canvas.drawPath(path, pen);
  }

  void paintPoints(Canvas canvas, Size size, Offset pos, double scale,
      Offset p1, Offset p2) {
    var path = createPath(p1, p2);
    drawPath(canvas, path);
  }

  void paint(
      Canvas canvas, Size size, Offset pos, double scale, GraphLink link) {
    if (link.changed) link.update();

    drawPath(canvas, link.path, link.group);
  }
}
