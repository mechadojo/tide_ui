import 'dart:js' as js;

import 'graph_editor_controller.dart';

mixin GraphEditorBrowser on GraphEditorControllerBase {
  String pointer = "default";

  void refreshWindow() {
    var result = js.context["window"];
    result.location.reload();
  }

  void setCursor(String next) {
    if (pointer != next) {
      var result = js.context["window"];
      pointer = next;
      result.document.body.style.cursor = pointer;
    }
  }
}
