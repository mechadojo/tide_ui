import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';

class GraphState with ChangeNotifier {
  GraphController controller;

  bool copy(GraphState other) {
    return false;
  }

  void clear() {}
}
