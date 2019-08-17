import 'package:flutter_web/material.dart';
import 'package:flutter_web_ui/ui.dart' as ui show Gradient;
import 'package:tide_ui/graph_editor/controller/library_controller.dart';

import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

class LibraryPainter {
  void paint(Canvas canvas, Size size, LibraryState library) {
    var width = library.controller.width;
    var rect = Rect.fromLTWH(size.width - width, 0, width, size.height);

    var shadow = Paint()
      ..shader = ui.Gradient.linear(
          Offset(rect.left - Graph.LibraryShadowWidth, 0),
          Offset(rect.left, 0),
          [Graph.LibraryShadowStart, Graph.LibraryShadowEnd]);

    canvas.drawRect(
        Rect.fromLTWH(rect.left - Graph.LibraryShadowWidth, rect.top,
            Graph.LibraryShadowWidth, rect.height),
        shadow);

    canvas.drawRect(rect, Graph.LibraryColor);

    canvas.drawLine(rect.topLeft, rect.bottomLeft, Graph.LibraryEdgeColor);
    drawExpandIcon(canvas, library, rect);
    drawTopIcons(canvas, library, rect);
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        drawToolbox(canvas, library, rect);
        break;
      case LibraryDisplayMode.collapsed:
        drawCollapsed(canvas, library, rect);
        break;
      case LibraryDisplayMode.expanded:
        drawExpanded(canvas, library, rect);
        break;
      case LibraryDisplayMode.detailed:
        drawDetailed(canvas, library, rect);
        break;

      default:
        break;
    }
  }

  void drawTopIcons(Canvas canvas, LibraryState library, Rect rect) {
    var cy =
        rect.top + Graph.LibraryTopIconSize / 2 + Graph.LibraryTopIconPadding;
    var cx = rect.center.dx;

    cx -= ((library.menu.length - 1) * Graph.LibraryTopIconSpacing) / 2;

    for (var item in library.menu) {
      var pt = Offset(cx, cy);
      cx += Graph.LibraryTopIconSpacing;

      var sz = Graph.LibraryTopIconSize * ((item.hovered) ? 1.25 : 1.0);

      var paint = item.selected
          ? Graph.LibraryTopIconSelectedColor
          : item.hovered
              ? Graph.LibraryTopIconHoverColor
              : Graph.LibraryTopIconColor;

      var icon = ((item.hovered || item.selected) && item.hasIconAlt)
          ? item.iconAlt
          : item.icon;

      var spacing = Graph.LibraryTopIconSpacing - 2;

      item.hitbox =
          Rect.fromCenter(center: pt, width: spacing, height: spacing);

      VectorIcons.paint(canvas, icon, pt, sz, fill: paint);
    }
  }

  void drawToolbox(Canvas canvas, LibraryState library, Rect rect) {}

  void drawCollapsed(Canvas canvas, LibraryState library, Rect rect) {}

  void drawExpanded(Canvas canvas, LibraryState library, Rect rect) {}

  void drawDetailed(Canvas canvas, LibraryState library, Rect rect) {}

  void drawExpandIcon(Canvas canvas, LibraryState library, Rect rect) {
    var sz = Graph.LibraryExpandSize;

    var cx = rect.left - sz - Graph.LibraryExpandIconPadding;
    var cy = rect.top + sz + Graph.LibraryExpandIconPadding;
    var pt = Offset(cx, cy);

    var radial = Paint()..color = Color(0xff333333).withAlpha(20);
    canvas.drawCircle(pt, sz + 3, radial);
    canvas.drawCircle(pt, sz, Graph.LibraryColor);
    canvas.drawCircle(pt, sz, Graph.LibraryExpandIconEdgeColor);
    VectorIcons.paint(canvas, library.isHidden ? "angle-left" : "angle-right",
        pt, Graph.LibraryExpandIconSize,
        fill: Graph.LibraryExpandIconColor);

    library.hitbox = Rect.fromCenter(center: pt, width: sz * 2, height: sz * 2);
  }
}