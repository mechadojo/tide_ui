import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'canvas_interactive.dart';
import 'graph_state.dart';
import 'menu_item.dart';

class CanvasTab with CanvasInteractive {
  final CanvasState canvas = CanvasState();
  final GraphState graph = GraphState();

  String get icon => graph.icon;
  String get title => graph.title;
  String get name => graph.name;
  MenuItem closeBtn = MenuItem(name: "close-tab");
  CanvasTab({String icon, String title, String name}) {
    graph.icon =
        icon == null || icon.isEmpty ? VectorIcons.getRandomName() : icon;
    graph.title = title;
    graph.name = name;
  }

  @override
  Iterable<CanvasInteractive> interactive() sync* {
    yield closeBtn;
    yield this;
  }

  void copy(CanvasTab other) {
    canvas.copy(other.canvas);
    graph.copy(other.graph);
  }
}
