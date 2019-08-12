import 'graph_editor_controller.dart';

typedef ExecuteCommand(GraphEditorController editor);
typedef CommandCondition(GraphEditorController editor);

class GraphEditorCommand {
  ExecuteCommand handler;
  CommandCondition condition;

  Duration waitUntil = Duration.zero;
  int waitTicks = 0;

  GraphEditorCommand.autoPan() {
    handler = (GraphEditorController editor) {
      editor.panAtEdges();
    };
  }

  GraphEditorCommand.zoomToFit() {
    handler = (GraphEditorController editor) {
      editor.zoomToFit();
    };
  }

  GraphEditorCommand.newTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.add(select: true);
      editor.dispatch(GraphEditorCommand.zoomToFit(), afterTicks: 1);
    };
  }

  GraphEditorCommand.scrollTab(double direction) {
    handler = (GraphEditorController editor) {
      editor.tabs.controller.scroll(direction);
    };
  }

  GraphEditorCommand.closeTab(String tabname) {
    handler = (GraphEditorController editor) {
      editor.tabs.remove(tabname);
    };
  }

  GraphEditorCommand.restoreTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.restore(true);
    };
  }

  GraphEditorCommand.prevTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.selectPrev();
    };
  }

  GraphEditorCommand.nextTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.selectNext();
    };
  }
}
