import 'dart:html';

import 'package:flutter_web/material.dart';

import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';

class KeyboardHandler {
  bool handleTabKeys(CanvasTabsState tabs, KeyboardEvent evt) {
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

  bool handleCanvasKeys(CanvasState state, KeyboardEvent evt) {
    if (evt.key == "h") {
      state.reset();
      return true;
    }
    return false;
  }

  void onKeyPress(KeyboardEvent evt, BuildContext context, bool isActive) {}

  void onKeyUp(KeyboardEvent evt, BuildContext context, bool isActive) {}

  var reFuncKey = RegExp(r"F\d\d?");

  void onKeyDown(KeyboardEvent evt, BuildContext context, bool isActive) {
    // Always allow the chrome dev tools
    if (evt.key == "I" && evt.ctrlKey) return;
    // Always allow a full refresh
    if (evt.key == "R" && evt.ctrlKey) return;

    // Stop all the other browser shortcuts
    if (evt.ctrlKey || evt.altKey || reFuncKey.hasMatch(evt.key)) {
      evt.preventDefault();
    }

    if (evt.key.startsWith("F"))
    // Only handle the keypress if the graph editor is the active page
    if (!isActive) {
      if (evt.key == "Backspace" && evt.ctrlKey) {
        Navigator.pop(context);
      }
      return;
    }

    // Ctrl+? switches to the about / help page
    if (evt.key == "?" && evt.ctrlKey) {
      Navigator.pushNamed(context, "/about");
      return;
    }

    var state = Provider.of<CanvasState>(context, listen: false);
    if (handleCanvasKeys(state, evt)) return;

    var tabs = Provider.of<CanvasTabsState>(context, listen: false);
    if (handleTabKeys(tabs, evt)) return;

    if (evt.key != "Control" && evt.key != "Alt" && evt.key != "Shift") {
      print(
          "Key Down: ${evt.ctrlKey ? 'Ctrl+' : ''}${evt.shiftKey ? 'Shift+' : ''}${evt.altKey ? 'Alt+' : ''}${evt.key}");
    }
  }
}
