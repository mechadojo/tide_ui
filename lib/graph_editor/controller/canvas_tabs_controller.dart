import 'dart:math';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';

import 'graph_editor_controller.dart';
import 'graph_event.dart';

class CanvasTabsController with MouseController, KeyboardController {
  GraphEditorController editor;

  CanvasTabsState get tabs => editor.tabs;

  CanvasTabsController(this.editor);

  bool hoverCanceled = false;
  Offset cursorPos = Offset.zero;

  Offset swipeStart = Offset.zero;
  Offset swipeLast = Offset.zero;

  void updateVersion() {
    var dirty = editor.isDirty;

    if (dirty != GraphEditorControllerBase.saveButton.disabled) return;

    tabs.beginUpdate();
    GraphEditorControllerBase.saveButton.disabled = !dirty;
    tabs.endUpdate(true);
  }

  void startSwipe(Offset pt) {
    swipeStart = pt;
  }

  void updateSwipe(Offset pt) {
    swipeLast = pt;
  }

  void endSwipe(double velocity) {
    var direction = velocity;
    if (direction == 0) {
      direction = swipeLast.dx - swipeStart.dx;
    }
    scroll(direction);
  }

  void scroll(double velocity) {
    if (tabs.length < 1) return;

    var idx = tabs.selectedIndex;

    if (velocity < 0) {
      tabs.shiftLeft();
    } else {
      tabs.shiftRight();
    }

    for (var item in tabs.interactive()) {
      if (item.hovered) {
        item.hovered = false;
      }
    }
    tabs.requirePaint = true;
    tabs.selectIndex(idx);
  }

  @override
  bool onMouseOut() {
    if (hoverCanceled) return true;

    tabs.beginUpdate();
    bool notify = false;
    for (var item in tabs.interactive()) {
      if (item.hovered) {
        item.hovered = false;
        notify = true;
      }
    }

    tabs.endUpdate(notify);

    editor.dispatch(GraphEditorCommand.setCursor("default"));

    hoverCanceled = true;
    return true;
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    var delta = evt.pos.dx - GraphEvent.start.pos.dx;
    var dist = delta.abs();

    if (dist > Graph.TabSwipeDelta) {
      editor.dispatch(GraphEditorCommand.scrollTab(delta));
    }
    return true;
  }

  @override
  bool onMouseDown(GraphEvent evt) {
    var pt = getPos(evt.pos);

    cursorPos = pt;

    if (pt.dx < Graph.DefaultTabReloadMargin) {
      editor.dispatch(GraphEditorCommand.showAppMenu());
      return true;
    }

    for (var item in tabs.menu) {
      if (item.hitbox.contains(pt) && !item.disabled) {
        if (item.command != null) {
          editor.dispatch(item.command);
        }

        return true;
      }
    }

    for (var tab in tabs.tabs) {
      if (tab.closeBtn.hitbox.contains(pt) && !tab.closeBtn.disabled) {
        editor.dispatch(GraphEditorCommand.closeTab(tab.name));
        return true;
      }

      if (tab.hitbox.contains(pt) && !tab.disabled) {
        editor.dispatch(GraphEditorCommand.selectTab(tab.name));

        return true;
      }
    }

    return false;
  }

  @override
  bool onMouseMove(GraphEvent evt) {
    if (tabs.requirePaint) return false;

    var pt = getPos(evt.pos);
    cursorPos = pt;

    bool notify = false;
    hoverCanceled = false;
    bool hovered = false;

    tabs.beginUpdate();
    for (var item in tabs.interactive()) {
      if (item.disabled) {
        if (item.hovered) {
          item.hovered = false;
          notify = true;
        }
      } else {
        notify = notify || item.checkHovered(pt);
        hovered = hovered || item.hovered;
      }
    }

    tabs.endUpdate(notify);

    editor.setCursor(hovered ? "pointer" : "default");

    return true;
  }

  @override
  bool onKeyDown(GraphEvent evt) {
    var key = evt.key.toLowerCase();

    // Ctrl+n = Open new tab
    if (key == "n" && evt.ctrlKey) {
      editor.dispatch(GraphEditorCommand.newTab(evt.shiftKey));
      return true;
    }

    // Ctrl+tab = Select next tab
    if (key == "tab" && evt.ctrlKey) {
      if (evt.shiftKey) {
        editor.dispatch(GraphEditorCommand.prevTab());
      } else {
        editor.dispatch(GraphEditorCommand.nextTab());
      }

      return true;
    }

    // Ctrl+w = Close current tab
    if (key == "w" && evt.ctrlKey) {
      var tab = tabs.current;
      if (tab != null) {
        editor.dispatch(GraphEditorCommand.closeTab(tab.name));
      }
      return true;
    }

    // Ctrl+Shift+t = Restore last closed tab
    if (key == "t" && evt.ctrlKey && evt.shiftKey) {
      editor.dispatch(GraphEditorCommand.restoreTab());
      return true;
    }

    return false;
  }
}
