import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';

class GraphLinkPainter {
  Path createPath(Offset p1, Offset p2) {
    var ctrl = GraphLink.getControlPoints(p1, p2);
    var path = GraphLink.getPath(p1, p2, ctrl);
    return path;
  }

  Path createArrow(Offset p1, Offset p2) {
    var ctrl = GraphLink.getControlPoints(p1, p2);
    var path = GraphLink.getArrowPath(.5, p1, p2, ctrl);
    return path;
  }

  Map<int, Paint> linkPaints = {};
  Map<int, Paint> arrowPaints = {};

  Paint getLinkPaint([int group = -1, bool disabled = false]) {
    var result = linkPaints[group];
    if (result != null) return result;

    var color = group == -1
        ? Graph.DefaultLinkColor
        : Graph.getGroupColor(group, disabled);

    result = Paint()
      ..color = color
      ..strokeWidth = Graph.LinkPathWidth
      ..style = PaintingStyle.stroke;

    linkPaints[group] = result;
    return result;
  }

  Paint getArrowPaint([int group = -1, bool disabled = false]) {
    var result = arrowPaints[group];
    if (result != null) return result;

    var color = group == -1
        ? Graph.DefaultLinkColor
        : Graph.getGroupColor(group, disabled);

    result = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    arrowPaints[group] = result;
    return result;
  }

  void drawLink(Canvas canvas, Path path,
      {int group = -1,
      bool disabled = false,
      bool hovered = false,
      List<Path> arrows}) {
    if (arrows == null) arrows = [];

    var shadow =
        hovered ? Graph.LinkArrowHoverShadowColor : Graph.LinkArrowShadowColor;
    for (var arrow in arrows) {
      canvas.drawPath(arrow, shadow);
    }
    shadow = hovered ? Graph.LinkHoverShadowColor : Graph.LinkShadowColor;
    canvas.drawPath(path, shadow);

    var pen = getLinkPaint(group, disabled);
    canvas.drawPath(path, pen);
    var fill = getArrowPaint(group, disabled);
    for (var arrow in arrows) {
      canvas.drawPath(arrow, fill);
    }
  }

  void paintPoints(Canvas canvas, Size size, Offset pos, double scale,
      Offset p1, Offset p2) {
    var path = createPath(p1, p2);
    var arrow = createArrow(p1, p2);
    drawLink(canvas, path, arrows: [arrow]);
  }

  void paint(
      Canvas canvas, Size size, Offset pos, double scale, GraphLink link) {
    if (link.inPort.isLocal && link.inPort.node.hideLocalInports) return;
    if (link.outPort.isLocal && link.outPort.node.hideLocalOutports) return;

    if (link.changed) link.update();

    drawLink(canvas, link.path,
        group: link.group, arrows: link.arrows, hovered: link.hovered);

    //drawHitPath(canvas, link);
  }

  void drawHitPath(Canvas canvas, GraphLink link) {
    canvas.drawRect(link.hitbox, Graph.redPen);
    var last = link.hitPath[0];
    for (int i = 1; i < link.hitPath.length; i++) {
      var next = link.hitPath[i];
      canvas.drawLine(last, next, Graph.redPen);

      last = next;
    }
  }
}
