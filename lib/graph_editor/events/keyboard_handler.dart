import 'dart:html';

import 'package:flutter_web/material.dart';

import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

class KeyboardHandler {
  void onKeyDown(KeyboardEvent evt, BuildContext context, bool isActive) {
    var canvas = Provider.of<CanvasState>(context);
    // Stop the default chrome hotkeys
    if (evt.ctrlKey) evt.preventDefault();

    // Only handle the keypress if the graph editor is the active page
    if (!isActive) {
      if (evt.key == "Backspace" && evt.ctrlKey) {
        Navigator.pop(context);
      }
      return;
    }

    if (evt.key == "h") {
      canvas.reset();
      return;
    }

    if (evt.key == "?" && evt.ctrlKey) {
      Navigator.pushNamed(context, "/about");
      return;
    }

    if (evt.key != "Control" && evt.key != "Alt" && evt.key != "Shift") {
      print("Key Down: ${evt.key}");
    }
  }
}
