import 'package:provider/provider.dart';

import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';

import 'canvas_controller.dart';
import 'graph_controller.dart';
import 'keyboard_controller.dart';
import 'mouse_controller.dart';

class GraphEditorController with MouseController, KeyboardController {
  final GraphEditorState editor = GraphEditorState();
  final CanvasTabsState tabs = CanvasTabsState(menu: [
    MenuItem(name: "app-menu", icon: "ellipsisV"),
    MenuItem(name: "save", icon: "solidSave", iconAlt: "save"),
    MenuItem(name: "open", icon: "solidFolderOpen", iconAlt: "folderOpen"),
    MenuItem(name: "tab-new", icon: "solidPlusSquare", iconAlt: "plusSquare"),
  ]);

  final GraphState graph = GraphState();
  final CanvasState canvas = CanvasState();

  void onChangeTabs() {
    editor.onChangeTab(tabs.current, canvas, graph);
  }

  GraphEditorController() {
    editor.controller = this;
    tabs.controller = CanvasTabsController(tabs);
    graph.controller = GraphController(graph);
    canvas.controller = CanvasController(canvas);

    tabs.addListener(onChangeTabs);
  }

  List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => editor),
      ChangeNotifierProvider(builder: (_) => canvas),
      ChangeNotifierProvider(builder: (_) => tabs),
      ChangeNotifierProvider(builder: (_) => graph),
    ];
  }
}
