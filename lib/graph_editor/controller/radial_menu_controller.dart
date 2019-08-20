import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';

import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';

import 'graph_event.dart';

class RadialMenuController with MouseController, KeyboardController {
  GraphEditorController editor;
  RadialMenuState get menu => editor.menu;

  RadialMenuController(this.editor);

  List<MenuItemSet> menuStack = [];

  bool allowClose = false;

  void openMenu(MenuItemSet items) {
    allowClose = false;
    menu.beginUpdate();
    menu.setMenuItems(items);
    menu.endUpdate(true);
  }

  MenuItemSet pushMenu(MenuItemSet items) {
    allowClose = false;

    var last = menu.getMenuItems();
    menuStack.add(last);
    openMenu(items);
    editor.setCursor("default");
    return last;
  }

  MenuItemSet popMenu() {
    allowClose = false;

    if (menuStack.isEmpty) return null;
    var next = menuStack.removeLast();
    var last = menu.getMenuItems();
    openMenu(next);
    editor.setCursor("default");
    return last;
  }

  @override
  bool onMouseDown(GraphEvent evt) {
    allowClose = true;
    return true;
  }

  @override
  bool onContextMenu(GraphEvent evt) {
    // allow graph to select a different menu
    var dist = (menu.pos - evt.pos).distance;
    if (dist < Graph.RadialMenuSize) {
      editor.dispatch(menu.center.command);
      return true;
      
    }
    return editor.graph.controller.onContextMenu(evt);
  }

  @override
  bool onMouseMove(GraphEvent evt) {
    var pt = getPos(evt.pos);
    menu.beginUpdate();
    bool changed = false;
    bool pointer = false;

    changed != menu.center.checkHovered(pt);
    if (changed && menu.center.hovered) allowClose = true;

    pointer |= (menu.center.hovered && menu.center.command != null);

    for (var sector in menu.sectors) {
      changed |= sector.checkHovered(pt);
      pointer |= (sector.hovered && sector.command != null);
    }

    if (changed) {
      editor.dispatch(
          GraphEditorCommand.setCursor(pointer ? "pointer" : "default"));
    }
    menu.endUpdate(changed);

    // pass mouse events back to graph so that items can be hovered
    var dist = (evt.pos - menu.pos).distance;
    if (dist < Graph.RadialMenuSize) {
      editor.graph.controller.onMouseOut();
    } else {
      return editor.graph.controller.onMouseMove(evt);
    }

    return true;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    if (allowClose) {
      RadialMenuItem selected;

      if (menu.center.hovered) {
        if (menu.center.command == null) return true;
        selected = menu.center;
      } else {
        selected =
            menu.sectors.firstWhere((x) => x.hovered, orElse: () => null);
      }

      if (selected == null) {
        editor.dispatch(GraphEditorCommand.hideMenu());
        editor.cancelEditing();
      }

      if (selected != null && selected.command != null) {
        editor.dispatch(GraphEditorCommand.thenCloseMenu(selected.command),
            afterTicks: 5);
        editor.cancelEditing();
      }
    }
    return true;
  }
}
