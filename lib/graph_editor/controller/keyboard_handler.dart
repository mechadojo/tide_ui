import 'dart:html';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';

class KeyboardHandler {
  CanvasTabsController tabs;
  CanvasController canvas;
  GraphController graph;

  KeyboardHandler(this.canvas, this.tabs, this.graph);

  final reFuncKey = RegExp(r"F\d\d?");

  void onKeyPress(KeyboardEvent evt, BuildContext context, bool isActive) {}

  void onKeyUp(KeyboardEvent evt, BuildContext context, bool isActive) {}

  void onKeyDown(KeyboardEvent evt, BuildContext context, bool isActive) {
    // Always allow the chrome dev tools
    if (evt.key.toLowerCase() == "i" && evt.ctrlKey && evt.shiftKey) return;
    // Always allow a full refresh
    if (evt.key.toLowerCase() == "r" && evt.ctrlKey && evt.shiftKey) return;
    // Stop all the other browser shortcuts
    if (evt.ctrlKey || evt.altKey || reFuncKey.hasMatch(evt.key)) {
      evt.preventDefault();
    }

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

    if (canvas.onKeyDown(evt)) return;
    if (tabs.onKeyDown(evt)) return;
    if (graph.onKeyDown(evt)) return;

    if (evt.key != "Control" && evt.key != "Alt" && evt.key != "Shift") {
      print(
          "Key Down: ${evt.ctrlKey ? 'Ctrl+' : ''}${evt.shiftKey ? 'Shift+' : ''}${evt.altKey ? 'Alt+' : ''}${evt.key}");
    }
  }
}