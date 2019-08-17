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

  void paint(Canvas canvas, RadialMenuState menu) {
    if (!menu.visible) return;

    canvas.drawCircle(menu.pos, Graph.RadialMenuSize, Graph.RadialMenuColor);

    var iconSize = getIconSize(menu);
    var rect = Rect.fromCenter(
        center: menu.pos,
        width: Graph.RadialMenuSize * 2,
        height: Graph.RadialMenuSize * 2);

    for (var sector in menu.sectors) {
      var disabled = sector.command == null;

      if (sector.hovered && !disabled) {
        canvas.drawArc(rect, sector.startAngle, sector.sectorTheta, true,
            Graph.RadialMenuHoverColor);
      }

      var pos = Offset.fromDirection(sector.startAngle, Graph.RadialMenuSize);
      pos = pos.translate(menu.pos.dx, menu.pos.dy);
      canvas.drawLine(menu.pos, pos, Graph.RadialMenuSectorBorder);

      pos = Offset.fromDirection(
          (sector.startAngle + sector.endAngle) / 2, Graph.RadialMenuIconPos);
      pos = pos.translate(menu.pos.dx, menu.pos.dy);

      VectorIcons.paint(
        canvas,
        sector.icon,
        pos,
        sector.hovered && !disabled ? iconSize * 1.25 : iconSize,
        fill: getIconPaint(sector, disabled),
      );
    }
    canvas.drawCircle(menu.pos, Graph.RadialMenuSize, Graph.RadialMenuBorder);
    canvas.drawCircle(
        menu.pos, Graph.RadialMenuCenter, Graph.RadialMenuCenterColor);
    canvas.drawCircle(
        menu.pos, Graph.RadialMenuCenter, Graph.RaidalMenuCenterBorder);

    var centerSize = Graph.RadialMenuIconSize;
    var centerPaint = Graph.RadialMenuIconColor;
    if (menu.center.hovered && menu.center.command != null) {
      centerSize *= 1.25;
      centerPaint = Graph.RadialMenuHoverIconColor;
    }

    VectorIcons.paint(canvas, menu.center.icon, menu.pos, centerSize,
        fill: centerPaint);
  }
}
