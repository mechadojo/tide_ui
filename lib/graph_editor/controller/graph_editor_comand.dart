import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';
import 'graph_editor_controller.dart';

typedef ExecuteCommand(GraphEditorController editor);
typedef CommandCondition(GraphEditorController editor);

class GraphEditorCommand {
  ExecuteCommand handler;
  CommandCondition condition;

  Duration waitUntil = Duration.zero;
  int waitTicks = 0;

  GraphEditorCommand.hideMenu() {
    handler = (GraphEditorController editor) {
      editor.hideMenu();
    };
  }
  GraphEditorCommand.print(String text) {
    handler = (GraphEditorController editor) {
      print(text);
    };
  }
  GraphEditorCommand.showGraphMenu(GraphState graph, Offset pt) {
    print("show graph menu: ${graph.id}");

    handler = (GraphEditorController editor) {
      editor.showMenu(pt);
    };
  }

  GraphEditorCommand.showLinkMenu(GraphLink link, Offset pt) {
    print("show link menu: $link");
    handler = (GraphEditorController editor) {
      editor.showMenu(pt);
    };
  }

  GraphEditorCommand.showPortMenu(NodePort port, Offset pt) {
    print("show port menu: $port");
    handler = (GraphEditorController editor) {
      editor.showMenu(pt);
    };
  }

  GraphEditorCommand.showNodeMenu(GraphNode node, Offset pt) {
    print("show node menu: $node");
    handler = (GraphEditorController editor) {
      editor.showMenu(pt);
    };
  }

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
