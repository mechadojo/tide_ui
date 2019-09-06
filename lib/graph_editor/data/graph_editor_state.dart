import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/mouse_handler.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

import 'canvas_tab.dart';
import 'update_notifier.dart';

enum GraphDragMode { panning, selecting, viewing }

class GraphEditorState extends UpdateNotifier {
  final Map<String, CanvasTab> tabs = {};
  final List<String> imports = [];

  String branch = "";
  String source = "";
  String merge = "";
  String origin = "";

  Iterable<GraphState> get sheets sync* {
    for (var tab in tabs.values) {
      if (tab.graph.isOpMode || tab.graph.isBehavior) {
        yield tab.graph;
      }
    }
  }

  Iterable<GraphLibraryState> get library sync* {
    for (var tab in tabs.values) {
      if (tab.graph is GraphLibraryState) {
        yield tab.graph;
      }
    }
  }

  GraphEditorController controller;
  MouseHandler mouseHandler;
  KeyboardHandler keyboardHandler;

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

  String get version {
    List<String> parts = [
      source ?? "",
      merge ?? "",
      branch ?? "",
      ...sheets.map((g) => "${g.id}:${g.version}"),
      ...library.where((x) => !x.imported).map((g) => "${g.id}:${g.version}"),
      ...imports
    ];

    var content = Utf8Encoder().convert(parts.join(";"));
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    var result = hex.encode(digest.bytes);
    //print("Version: ${result.substring(0, 7)}\n${parts.join("\n")}");

    return result;
  }

  String lastVersion = "";
  bool get isDirty => lastVersion != version;

  void dispatch(GraphEditorCommand cmd) {
    controller.dispatch(cmd);
  }

  void saveChanges() {
    lastVersion = version;
    controller.updateVersion();
  }
}
