import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

class RadialMenuPainter {
  Paint getIconPaint(RadialMenuItem item, bool disabled) {
    if (disabled) return Graph.RadialMenuDisabledIconColor;
    if (item.hovered) return Graph.RadialMenuHoverIconColor;
    return Graph.RadialMenuIconColor;
  }

  double getIconSize(RadialMenuState menu) {
    int sectors = menu.sectors.length;
    double radius = Graph.RadialMenuSize;
    double center = Graph.RadialMenuCenter;

    return (radius - center) *
        ((sectors > 6) ? ((sectors > 10) ? .3 : .4) : .5);
  }

  double getSectorLabelSize(int total) {
    if (total < 4) return 16;

    return 12;
  }

  void paint(Canvas canvas, RadialMenuState menu) {
    if (!menu.visible) return;

    canvas.drawCircle(menu.pos, Graph.RadialMenuSize, Graph.RadialMenuColor);

    var iconSize = getIconSize(menu);
    var rect = Rect.fromCircle(center: menu.pos, radius: Graph.RadialMenuSize);

    var title = menu.center.hasTitle ? menu.center.title : "";
    var centerIcon = menu.center.icon;
    var labelSize = getSectorLabelSize(menu.sectors.length);
    for (var sector in menu.sectors) {
      var disabled = sector.command == null;

      if (sector.hovered && !disabled) {
        canvas.drawArc(rect, sector.startAngle, sector.sectorTheta, true,
            Graph.RadialMenuHoverColor);

        if (sector.hasTitle && sector.hasIcon) {
          title = sector.title;
          centerIcon = sector.icon;
        }
      }

      var pos = Offset.fromDirection(sector.startAngle, Graph.RadialMenuSize);
      pos = pos.translate(menu.pos.dx, menu.pos.dy);
      canvas.drawLine(menu.pos, pos, Graph.RadialMenuSectorBorder);

      pos = Offset.fromDirection(
          (sector.startAngle + sector.endAngle) / 2, Graph.RadialMenuIconPos);
      pos = pos.translate(menu.pos.dx, menu.pos.dy);
      var iconPaint = getIconPaint(sector, disabled);

      if (sector.hasIcon) {
        VectorIcons.paint(
          canvas,
          sector.icon,
          pos,
          sector.hovered && !disabled ? iconSize * 1.25 : iconSize,
          fill: iconPaint,
        );
      } else if (sector.hasTitle) {
        Graph.font.paint(canvas, sector.title, pos, labelSize,
            fill: iconPaint,
            alignment: Alignment.center,
            width: Graph.RadialMenuSize,
            style: "Bold");
      }
    }
    canvas.drawCircle(menu.pos, Graph.RadialMenuSize, Graph.RadialMenuBorder);
    canvas.drawCircle(
        menu.pos, Graph.RadialMenuCenter, Graph.RadialMenuCenterColor);
    canvas.drawCircle(
        menu.pos, Graph.RadialMenuCenter, Graph.RaidalMenuCenterBorder);

    var centerSize = Graph.RadialMenuIconSize;
    var centerPaint = Graph.RadialMenuIconColor;
    var centerPos = menu.pos;

    if (menu.center.hovered && menu.center.command != null) {
      centerSize *= 1.25;
      centerPaint = Graph.RadialMenuHoverIconColor;
    }

    if (title.isNotEmpty) {
      centerSize *= .875;
      centerPos = menu.pos.translate(0, -10);
      var textPos = centerPos.translate(0, centerSize / 2 + 4);

      Graph.font.paint(canvas, title, textPos, 10,
          fill: centerPaint,
          width: Graph.RadialMenuSize,
          alignment: Alignment.topCenter);
    }

    VectorIcons.paint(canvas, centerIcon, centerPos, centerSize,
        fill: centerPaint);
  }
}
