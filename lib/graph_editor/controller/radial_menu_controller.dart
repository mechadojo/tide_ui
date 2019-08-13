import 'dart:html';
import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';

import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/radial_menu_state.dart';

class RadialMenuController with MouseController, KeyboardController {
  GraphEditorController editor;
  RadialMenuState get menu => editor.menu;

  RadialMenuController(this.editor);
  bool allowClose = false;

  @override
  bool onMouseDown(MouseEvent evt, Offset pt) {
    allowClose = true;
    return true;
  }

  @override
  bool onMouseMove(MouseEvent evt, Offset pt) {
    menu.beginUpdate();
    bool changed = false;

    changed != menu.center.checkHovered(pt);
    for (var sector in menu.sectors) {
      if (sector.disabled) {
        sector.hovered = false;
        continue;
      }
      changed |= sector.checkHovered(pt);
    }
    menu.endUpdate(changed);
    return true;
  }

  @override
  bool onMouseUp(MouseEvent evt) {
    if (allowClose) {
      RadialMenuItem selected;

      if (menu.center.hovered) {
        if (menu.center.command == null) return true;
        selected = menu.center;
      } else {
        selected =
            menu.sectors.firstWhere((x) => x.hovered, orElse: () => null);
      }

      editor.dispatch(GraphEditorCommand.hideMenu());
      if (selected != null && selected.command != null) {
        editor.dispatch(selected.command, afterTicks: 5);
      }
    }
    return true;
  }
}
