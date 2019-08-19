import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/mouse_handler.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'canvas_tab.dart';
import 'update_notifier.dart';

enum GraphDragMode { panning, selecting, viewing }

class GraphEditorState extends UpdateNotifier {
  final Map<String, CanvasTab> tabs = {};

  GraphEditorController controller;
  MouseHandler mouseHandler;
  KeyboardHandler keyboardHandler;
  CanvasTab currentTab;

  GraphDragMode dragMode = GraphDragMode.panning;
  bool touchMode = false;
  bool multiMode = false;
  bool snapImage = false;

  int moveCounter = 0; // number of mouse moves since last reset

  String get platformIcon {
    var platform = (controller.platform ?? "").split(".").last;
    platform = "web";

    switch (platform) {
      case "web":
        return "chrome-brands";
      case "ios":
        return "apple-brands";
      case "android":
        return "android-brands";
      case "windows":
        return "windows-brands";
      default:
        return "thumbtack";
    }
  }

  void dispatch(GraphEditorCommand cmd) {
    controller.dispatch(cmd);
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

    if (tab == null) {
      if (tabs.isNotEmpty) {
        controller.showTab(tabs.keys.first, reload: true);
      }
      return;
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
      controller.hideMenu();
      currentTab = next;
    } else {
      canvas.reset();
      graph.clear();
      currentTab = null;
    }

    endUpdate(true);
  }
}
