import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

class GraphController with MouseController, KeyboardController {
  GraphState graph;

  GraphController(this.graph);
}
