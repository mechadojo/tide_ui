import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';
import '../controller/radial_menu_controller.dart';
import 'graph.dart';
import 'menu_item.dart';
import 'update_notifier.dart';

import 'canvas_interactive.dart';

class RadialMenuItem extends MenuItem {
  double majorRadius = Graph.RadialMenuSize;
  double minorRadius = Graph.RadialMenuCenter;
  double startAngle = 0;
  double endAngle = 2 * pi;
  double sectorTheta = 0;

  RadialMenuItem.center() {
    majorRadius = Graph.RadialMenuCenter;
    minorRadius = 0;
  }

  RadialMenuItem.sector(int index, int total, [double origin = 0]) {
    sectorTheta = 2 * pi / total;

    var offset = -(pi / 2) - sectorTheta / 2;

    startAngle = index * sectorTheta + origin + offset;
    endAngle = startAngle + sectorTheta;
    if (startAngle < -pi) {
      startAngle += 2 * pi;
      endAngle += 2 * pi;
    }
    if (startAngle > pi) {
      startAngle -= 2 * pi;
      endAngle -= 2 * pi;
    }
  }

  @override
  bool isHovered(Offset pt) {
    var delta = pt - pos;

    var dist = delta.distance;
    if (dist > majorRadius) return false;
    if (minorRadius == 0) return true; // center button
    if (dist <= minorRadius) return false;

    var angle = delta.direction;
    if (angle.sign != startAngle.sign) {
      if (angle < 0) {
        angle += 2 * pi;
      }
    }

    var theta = angle - startAngle;
    if (theta < 0) return false; // not allowed to be CCW of start angle
    return theta < sectorTheta; // not allowed to be bigger than sector
  }
}

class RadialMenuState extends UpdateNotifier {
  RadialMenuController controller;

  List<RadialMenuItem> sectors = [];
  RadialMenuItem center;

  Offset pos = Offset.zero;
  bool visible = false;

  MenuItemSet getMenuItems() {
    var result = MenuItemSet()..copy(center);
    for (var sector in sectors) {
      result.items.add(MenuItem()..copy(sector));
    }
    return result;
  }

  void setMenuItems(MenuItemSet items) {
    center = RadialMenuItem.center()..copy(items);
    if (!center.hasIcon) {
      center.icon = VectorIcons.getRandomName();
    }

    sectors.clear();

    for (int i = 0; i < items.length; i++) {
      var next = RadialMenuItem.sector(i, items.length)..copy(items.get(i));

/*
      if (!next.hasIcon) {
        next.icon = VectorIcons.getRandomName();
      }
*/

      sectors.add(next);
    }
  }

  factory RadialMenuState() {
    return RadialMenuState.sectors(
        [for (int i = 0; i < 4; i++) MenuItem(name: "Item $i")]);
  }

  RadialMenuState.sectors(List<MenuItem> sectors, [MenuItem center]) {
    setMenuItems(MenuItemSet([...sectors])..copy(center));
  }

  void clearInteractive() {
    for (var sector in sectors) {
      sector.hovered = false;
    }
  }

  void moveTo(Offset pos) {
    this.pos = pos;
    this.center.pos = pos;
    for (var sector in sectors) {
      sector.pos = pos;
    }
  }

  Iterable<CanvasInteractive> interactive() sync* {
    if (center != null) {
      yield center;
    }

    yield* sectors;
  }
}
