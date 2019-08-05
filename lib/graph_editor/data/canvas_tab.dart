import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'canvas_interactive.dart';
import 'graph_state.dart';
import 'menu_item.dart';

class CanvasTab with CanvasInteractive {
  final CanvasState canvas = CanvasState();
  final GraphState graph = GraphState();

  String icon;
  String title;
  String name;
  MenuItem closeBtn = MenuItem(name: "close-tab");
  CanvasTab({this.icon, this.title, this.name});

  void copy(CanvasTab other) {
    icon = other.icon;
    title = other.title;
    name = other.name;

    canvas.copy(other.canvas);
    graph.copy(other.graph);
  }
}
