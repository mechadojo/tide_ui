import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';
import 'graph_editor_controller.dart';
import 'graph_editor_filesource.dart';
import 'graph_event.dart';
import 'library_controller.dart';

typedef ExecuteCommand(GraphEditorController editor);
typedef CommandCondition(GraphEditorController editor);

class GraphEditorCommand {
  ExecuteCommand handler;
  CommandCondition condition;
  Duration waitUntil = Duration.zero;
  int waitTicks = 0;

  GraphEditorCommand.loadChartJson(String content, String filename) {
    handler = (GraphEditorController editor) {
      editor.loadChartJson(content, filename);
    };
  }

  GraphEditorCommand.saveChanges() {
    handler = (GraphEditorController editor) {
      editor.saveChanges();
    };
  }

  GraphEditorCommand.saveFile() {
    handler = (GraphEditorController editor) {
      editor.saveFile();
    };
  }

  GraphEditorCommand.openFolder([FileSourceType source]) {
    handler = (GraphEditorController editor) {
      editor.openFolderType(source);
    };
  }

  GraphEditorCommand.showTab(String name) {
    handler = (GraphEditorController editor) {
      editor.showTab(name);
    };
  }

  GraphEditorCommand.showLibrary([LibraryDisplayMode mode]) {
    handler = (GraphEditorController editor) {
      editor.showLibrary(mode);
    };
  }

  GraphEditorCommand.expandLibrary() {
    handler = (GraphEditorController editor) {
      if (!editor.library.isExpanded) {
        editor.showLibrary(editor.library.lastExpanded);
      }
    };
  }

  GraphEditorCommand.collapseLibrary() {
    handler = (GraphEditorController editor) {
      if (!editor.library.isCollapsed) {
        editor.showLibrary(editor.library.lastCollapsed);
      }
    };
  }

  GraphEditorCommand.hideLibrary() {
    handler = (GraphEditorController editor) {
      editor.hideLibrary();
    };
  }

  GraphEditorCommand.onContextMenu(GraphEvent evt) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.onContextMenu(evt);
    };
  }

  GraphEditorCommand.undoHistory() {
    handler = (GraphEditorController editor) {
      editor.graph.controller.undoHistory();
    };
  }

  GraphEditorCommand.redoHistory() {
    handler = (GraphEditorController editor) {
      editor.graph.controller.redoHistory();
    };
  }

  GraphEditorCommand.thenCloseMenu(GraphEditorCommand cmd) {
    handler = (GraphEditorController editor) {
      var result = cmd.handler(editor);

      if (result == null) {
        editor.dispatch(GraphEditorCommand.hideMenu());
      }
    };
  }

  GraphEditorCommand.refreshWindow() {
    handler = (GraphEditorController editor) {
      editor.refreshWindow();
    };
  }

  GraphEditorCommand.setCursor(String cursor) {
    handler = (GraphEditorController editor) {
      editor.setCursor(cursor);
    };
  }

  GraphEditorCommand.openFile() {
    handler = (GraphEditorController editor) {
      print("Open File");
    };
  }

  // ************************************************************
  //
  //  Graph Commands
  //
  // ************************************************************

  GraphEditorCommand.removeLink(GraphLink link) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.removeLink(link.outPort, link.inPort);
    };
  }

  GraphEditorCommand.removeNode(GraphNode node) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.removeNode(node);
    };
  }

  GraphEditorCommand.addNode(GraphNode node,
      {List<GraphLink> links, bool drag = false, double offset = 0}) {
    handler = (GraphEditorController editor) {
      editor.addNode(node, links: links, drag: drag, offset: offset);
    };
  }

  factory GraphEditorCommand.addGraphOutport(
      {NodePort attach, bool drag = false}) {
    var node = GraphNode.outport();
    List<GraphLink> links = [];
    if (attach != null) {
      links.add(GraphLink.link(attach, node.defaultInport));
    }
    return GraphEditorCommand.addNode(node,
        links: links, drag: drag, offset: 2);
  }

  factory GraphEditorCommand.addGraphInport(
      {NodePort attach, bool drag = false}) {
    var node = GraphNode.inport();
    List<GraphLink> links = [];
    if (attach != null) {
      links.add(GraphLink.link(node.defaultOutport, attach));
    }
    return GraphEditorCommand.addNode(node,
        links: links, drag: drag, offset: -2);
  }

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
    items.command = GraphEditorCommand.popMenu();

    handler = (GraphEditorController editor) {
      editor.pushMenu(items, pt);
      return false;
    };
  }

  GraphEditorCommand.popMenu() {
    handler = (GraphEditorController editor) {
      editor.popMenu();
      return false;
    };
  }

  GraphEditorCommand.hideMenu() {
    handler = (GraphEditorController editor) {
      if (editor.menu.visible) {
        editor.hideMenu();
      }
    };
  }
  GraphEditorCommand.print(String text) {
    handler = (GraphEditorController editor) {
      print(text);
    };
  }

  GraphEditorCommand.showAppMenu() {
    handler = (GraphEditorController editor) {
      var menu = editor.getAppMenu();
      editor.openMenu(menu, Offset(0, 0));
    };
  }

  GraphEditorCommand.showGraphMenu(GraphState graph, Offset pt) {
    handler = (GraphEditorController editor) {
      var menu = editor.getGraphMenu(graph)..icon = "cogs";
      editor.openMenu(menu, pt);
    };
  }

  GraphEditorCommand.showLinkMenu(GraphLink link, Offset pt) {
    handler = (GraphEditorController editor) {
      var menu = editor.getLinkMenu(link)..icon = "share-alt";
      editor.openMenu(menu, pt);
    };
  }

  GraphEditorCommand.showPortMenu(NodePort port, Offset pt) {
    handler = (GraphEditorController editor) {
      var menu = editor.getPortMenu(port)
        ..icon = port.node.icon
        ..title = port.name;

      editor.openMenu(menu, pt);
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

  GraphEditorCommand.zoomToFit([bool selected = true]) {
    handler = (GraphEditorController editor) {
      editor.zoomToFit(selected);
    };
  }

  // ************************************************************
  //
  //  Tab Commands
  //
  // ************************************************************

  GraphEditorCommand.newTab() {
    handler = (GraphEditorController editor) {
      editor.newTab();
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

  // ************************************************************
  //
  //  Chart File Commands
  //
  // ************************************************************

  GraphEditorCommand.restoreCharts() {
    handler = (GraphEditorController editor) {
      editor.dispatch(GraphEditorCommand.newTab());
    };
  }
}
