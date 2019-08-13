import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';
import 'graph_editor_controller.dart';

typedef ExecuteCommand(GraphEditorController editor);
typedef CommandCondition(GraphEditorController editor);

class GraphEditorCommand {
  ExecuteCommand handler;
  CommandCondition condition;
  Duration waitUntil = Duration.zero;
  int waitTicks = 0;

  // ************************************************************
  //
  //  Radial Menu Commands
  //
  // ************************************************************

  GraphEditorCommand.openMenu(MenuItemSet items, [Offset pt]) {
    handler = (GraphEditorController editor) {
      editor.openMenu(items, pt);
    };
  }

  GraphEditorCommand.pushMenu(MenuItemSet items, [Offset pt]) {
    handler = (GraphEditorController editor) {
      editor.pushMenu(items, pt);
    };
  }

  GraphEditorCommand.popMenu() {
    handler = (GraphEditorController editor) {
      editor.popMenu();
    };
  }

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
    handler = (GraphEditorController editor) {
      var menu = editor.getGraphMenu(graph)..icon = graph.icon;
      editor.openMenu(menu, pt);
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
    handler = (GraphEditorController editor) {
      var menu = editor.getNodeMenu(node)..icon = node.icon;
      editor.openMenu(menu, pt);
    };
  }

  // ************************************************************
  //
  //  Pan and Zoom Commands
  //
  // ************************************************************

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

  // ************************************************************
  //
  //  Tab Commands
  //
  // ************************************************************

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
