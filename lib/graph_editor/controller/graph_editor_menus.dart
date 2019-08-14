import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';

import 'graph_controller.dart';
import 'graph_editor_controller.dart';

mixin GraphEditorMenus on GraphEditorControllerBase {
  MenuItemSet getNodeMenu(GraphNode node) {
    switch (node.type) {
      case GraphNodeType.action:
        return MenuItemSet([
          MenuItem(icon: "edit"),
          MenuItem(icon: "chevron-circle-right"),
          MenuItem(icon: "trash-alt"),
          MenuItem(icon: "chevron-circle-left"),
        ]);
      default:
        return MenuItemSet([
          MenuItem(icon: "edit"),
          MenuItem(icon: "trash-alt"),
        ]);
    }
  }

  MenuItemSet getLinkMenu(GraphLink link) {
    return MenuItemSet([
      MenuItem(icon: "edit"),
      MenuItem(icon: "trash-alt"),
    ]);
  }

  MenuItemSet getGraphMenu(GraphState graph) {
    return MenuItemSet([
      MenuItem(icon: "edit"),
      MenuItem(icon: "save"),
      MenuItem(icon: "upload"),
      MenuItem(icon: "mobile-alt"),
    ]);
  }

  // *************************************************************
  //
  //  Menu Implementation for Graph Editor Controller
  //
  // *************************************************************

  void showMenu([Offset pt]) {
    graph.controller.moveMode = MouseMoveMode.none;
    graph.controller.clearSelection();

    menu.beginUpdate();
    menu.clearInteractive(); // clears ui interactive states

    moveMenu(pt);

    menu.controller.allowClose = false;
    menu.visible = true;
    menu.endUpdate(true);
  }

  void moveMenu(Offset pt) {
    tabs.beginUpdate();

    if (pt != null) {
      var sz = Graph.RadialMenuSize * 2;

      var rect = Rect.fromCenter(center: pt, width: sz, height: sz);
      var limits = canvas.controller.menuLimits;

      var dx = rect.left < limits.left ? limits.left - rect.left : 0;
      var dy = rect.top < limits.top ? limits.top - rect.top : 0;
      dx = rect.right > limits.right ? limits.right - rect.right : dx;
      dy = rect.bottom > limits.bottom ? limits.bottom - rect.bottom : dy;

      menu.moveTo(pt.translate(dx, dy));
    }

    tabs.endUpdate(true);
  }

  void hideMenu({bool resetMoveMode = true, bool resetPanning = true}) {
    if (resetMoveMode) {
      graph.controller.moveMode = MouseMoveMode.none;
    }

    menu.beginUpdate();
    menu.visible = false;
    menu.endUpdate(true);

    if (resetPanning) {
      canvas.controller.stopPanning();
    }
  }

  void openMenu(MenuItemSet items, [Offset pt, bool resetStack = true]) {
    menu.beginUpdate();
    if (resetStack) {
      menu.controller.menuStack.clear();
    }

    menu.controller.openMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }

    menu.endUpdate(true);
  }

  void pushMenu(MenuItemSet items, [Offset pt]) {
    menu.beginUpdate();
    menu.controller.pushMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }
    menu.endUpdate(true);
  }

  void popMenu([bool autoClose = false]) {
    menu.beginUpdate();
    var last = menu.controller.popMenu();
    if (last == null) {
      if (autoClose) {
        hideMenu();
      }
    } else {
      if (!menu.visible) {
        showMenu();
      }
    }

    menu.endUpdate(true);
  }
}
