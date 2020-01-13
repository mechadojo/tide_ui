import 'package:flutter/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'canvas_interactive.dart';
import 'graph_state.dart';
import 'menu_item.dart';

class CanvasTab with CanvasInteractive {
  final CanvasState canvas = CanvasState();
  final GraphState graph;

  String get icon => graph.icon;
  String get title => graph.title;
  String get name => graph.name;
  MenuItem closeBtn = MenuItem(name: "close-tab");

  CanvasTab(GraphEditorController editor, this.graph) {
    canvas.controller = editor.canvasController;
    graph.controller = editor.graphController;
  }

  @override
  Iterable<CanvasInteractive> interactive() sync* {
    yield closeBtn;
    yield this;
  }

  void zoomToFit() {
    if (graph.nodes.isNotEmpty) {
      graph.layout();
      var rect = graph.extents.inflate(50);
      canvas.zoomToFit(rect, canvas.size);
    } else {
      canvas.scale = 1.0;
      canvas.pos = Offset.zero;
    }
  }
}
