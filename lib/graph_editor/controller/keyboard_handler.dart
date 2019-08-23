import 'dart:html';
import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'graph_event.dart';

class KeyboardHandler {
  GraphEditorController editor;
  CanvasTabsController get tabs => editor.tabs.controller;
  CanvasController get canvas => editor.canvas.controller;
  GraphController get graph => editor.graph.controller;

  bool ctrlKey = false;
  bool shiftKey = false;
  bool altKey = false;

  KeyboardHandler(this.editor);

  final reFuncKey = RegExp(r"F\d\d?");

  void onKeyPress(GraphEvent evt, BuildContext context, bool isActive) {}

  void onKeyUp(GraphEvent evt, BuildContext context, bool isActive) {
    if (evt.key == "Control") ctrlKey = false;
    if (evt.key == "Alt") altKey = false;
    if (evt.key == "Shift") shiftKey = false;
  }

  void onKeyDown(GraphEvent evt, BuildContext context, bool isActive) {
    if (evt.key == "Control") ctrlKey = true;
    if (evt.key == "Alt") altKey = true;
    if (evt.key == "Shift") shiftKey = true;

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

    if (evt.key == "Escape" && editor.closeBottomSheet != null) {
      editor.closeBottomSheet();
      return;
    }

    if (editor.isModalActive) return;

    // Ctrl+? switches to the about / help page
    if (evt.key == "?" && evt.ctrlKey) {
      Navigator.pushNamed(context, "/about");
      return;
    }

    if (editor.onKeyDown(evt)) return;
    if (canvas.onKeyDown(evt)) return;
    if (tabs.onKeyDown(evt)) return;
    if (graph.onKeyDown(evt)) return;

    if (evt.key != "Control" && evt.key != "Alt" && evt.key != "Shift") {
      print(
          "Key Down: ${evt.ctrlKey ? 'Ctrl+' : ''}${evt.shiftKey ? 'Shift+' : ''}${evt.altKey ? 'Alt+' : ''}${evt.key}");
    }
  }
}
