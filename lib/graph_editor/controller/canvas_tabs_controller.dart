import 'dart:html';
import 'dart:js' as js;

import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';

class CanvasTabsController with MouseController, KeyboardController {
  CanvasTabsState tabs;

  CanvasTabsController(this.tabs);

  bool hoverCanceled = false;
  Offset cursorPos = Offset.zero;
  String cursor = "default";

  Offset swipeStart = Offset.zero;
  Offset swipeLast = Offset.zero;

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

  void setCursor(bool hovered) {
    var next = hovered ? "pointer" : "default";
    if (cursor != next) {
      var result = js.context["window"];
      cursor = next;
      result.document.body.style.cursor = cursor;
    }
  }

  void scroll(double velocity) {
    print(velocity);
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
    if (notify) print("dehover tabs");

    tabs.endUpdate(notify);

    setCursor(false);
    hoverCanceled = true;
    return true;
  }

  @override
  bool onMouseDown(MouseEvent evt, Offset pt) {
    cursorPos = pt;
    tabs.beginUpdate();

    for (var item in tabs.menu) {
      if (item.hitbox.contains(pt) && !item.disabled) {
        switch (item.name) {
          case "tab-new":
            tabs.add(select: true);
            break;
          case "tab-next":
            scroll(1);
            break;
          case "tab-prev":
            scroll(-1);
            break;
          default:
            print("Select menu: ${item.name} [${item.group}]");

            break;
        }

        tabs.endUpdate(true);
        return true;
      }
    }

    for (var tab in tabs.tabs) {
      if (tab.closeBtn.hitbox.contains(pt) && !tab.closeBtn.disabled) {
        tabs.remove(tab.name);
        tabs.endUpdate(true);
        return true;
      }

      if (tab.hitbox.contains(pt) && !tab.disabled) {
        tabs.select(tab.name);
        tabs.endUpdate(true);
        return true;
      }
    }
    tabs.endUpdate(false);
    return false;
  }

  @override
  bool onMouseUp(MouseEvent evt) {
    // This helps with tabs that get removed on mouse down
    // Its not perfect but we cannot call state changes from inside the re-paint
    return onMouseMove(evt, cursorPos);
  }

  @override
  bool onMouseMove(MouseEvent evt, Offset pt) {
    if (tabs.requirePaint) return false;

    cursorPos = pt;

    bool notify = false;
    hoverCanceled = false;
    bool hovered = false;

    tabs.beginUpdate();
    for (var item in tabs.interactive()) {
      notify = notify || item.checkHovered(pt);
      hovered = hovered || item.hovered;
    }

    tabs.endUpdate(notify);

    setCursor(hovered);
    return true;
  }

  @override
  bool onKeyDown(KeyboardEvent evt) {
    var key = evt.key.toLowerCase();

    // Ctrl+n = Open new tab
    if (key == "n" && evt.ctrlKey) {
      print("Open new tab");
      tabs.add(select: true);
      return true;
    }

    // Ctrl+tab = Select next tab
    if (key == "tab" && evt.ctrlKey) {
      if (evt.shiftKey) {
        tabs.selectPrev();
      } else {
        tabs.selectNext();
      }

      return true;
    }

    // Ctrl+w = Close current tab
    if (key == "w" && evt.ctrlKey) {
      var tab = tabs.current;
      if (tab != null) {
        print("Close tab ${tab.name}");
        tabs.remove(tab.name);
      }
      return true;
    }

    // Ctrl+Shift+t = Restore last closed tab
    if (key == "t" && evt.ctrlKey && evt.shiftKey) {
      tabs.restore(true);
      return true;
    }

    return false;
  }
}
