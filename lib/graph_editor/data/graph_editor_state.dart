import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/mouse_handler.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'canvas_tab.dart';

enum GraphDragMode { panning, selecting }

class GraphEditorState with ChangeNotifier {
  final Map<String, CanvasTab> tabs = Map<String, CanvasTab>();
  GraphEditorController controller;
  MouseHandler mouseHandler;
  KeyboardHandler keyboardHandler;
  CanvasTab currentTab;

  GraphDragMode dragMode = GraphDragMode.panning;

  void dispatch(GraphEditorCommand cmd) {
    controller.dispatch(cmd);
  }

  void beginUpdate() {}

  void endUpdate(bool changed) {
    if (changed) {
      notifyListeners();
    }
  }

  void onChangeTab(CanvasTab tab, CanvasState canvas, GraphState graph) {
    // Save current canvas and graph state
    if (currentTab != null) {
      if (tab != null && currentTab.name == tab.name) {
        return;
      }

      currentTab.canvas.copy(canvas);
      currentTab.graph.copy(graph);
    }

    beginUpdate();

    if (tab != null) {
      var next = tabs[tab.name];
      if (next == null) {
        next = CanvasTab()..copy(tab);
        tabs[next.name] = next;
      }

      canvas.copy(next.canvas);
      graph.copy(next.graph);
      currentTab = next;
    } else {
      canvas.reset();
      graph.clear();
      currentTab = null;
    }

    endUpdate(true);
  }
}
