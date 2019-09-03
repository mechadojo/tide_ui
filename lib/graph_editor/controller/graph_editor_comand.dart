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
  List<GraphEditorCommand> after = [];

  void then(GraphEditorCommand cmd) {
    after.add(cmd);
  }

  GraphEditorCommand(this.handler);

  GraphEditorCommand.all(Iterable<GraphEditorCommand> cmds) {
    handler = (GraphEditorController editor) {
      for (var cmd in cmds) {
        editor.dispatch(cmd);
      }
    };
  }
  GraphEditorCommand.ensureVisible(GlobalKey item) {
    handler = (GraphEditorController editor) {
      Scrollable.ensureVisible(item.currentContext);
    };
  }

  GraphEditorCommand.requestFocus(FocusNode item) {
    handler = (GraphEditorController editor) {
      item.requestFocus();
    };
  }

  GraphEditorCommand.selectAll(TextEditingController controller) {
    handler = (GraphEditorController editor) {
      controller.value = controller.value.copyWith(
          selection: TextSelection(
              baseOffset: 0, extentOffset: controller.text.length),
          composing: TextRange.empty);
    };
  }

  GraphEditorCommand.selectNone(TextEditingController controller) {
    handler = (GraphEditorController editor) {
      print("Select None");
      controller.value = controller.value.copyWith(
          selection: TextSelection.collapsed(offset: 0),
          composing: TextRange.empty);
    };
  }

  GraphEditorCommand.saveChanges() {
    handler = (GraphEditorController editor) {
      editor.saveChanges();
    };
  }

  GraphEditorCommand.newFile([FileSourceType source]) {
    handler = (GraphEditorController editor) {
      editor.newFile();
    };
  }

  GraphEditorCommand.saveFile([FileSourceType source]) {
    handler = (GraphEditorController editor) {
      editor.saveFileType(source);
    };
  }

  GraphEditorCommand.deleteLocalFile(String filename) {
    handler = (GraphEditorController editor) {
      editor.deleteLocalFile(filename);
    };
  }

  GraphEditorCommand.openFile([FileSourceType source, String filename]) {
    handler = (GraphEditorController editor) {
      editor.openFileType(source, filename);
    };
  }

  GraphEditorCommand.popLibraryTabs([LibraryDisplayMode mode, LibraryTab tab]) {
    handler = (GraphEditorController editor) {
      editor.popLibraryTabs();
    };
  }

  GraphEditorCommand.showLibrary(LibraryDisplayMode mode, {LibraryTab tab}) {
    handler = (GraphEditorController editor) {
      editor.showLibrary(mode, tab: tab);
    };
  }

  GraphEditorCommand.showLibraryTab(LibraryTab tab) {
    handler = (GraphEditorController editor) {
      editor.showLibrary(LibraryDisplayMode.tabs, tab: tab);
    };
  }

  GraphEditorCommand.expandLibrary() {
    handler = (GraphEditorController editor) {
      if (!editor.library.isExpanded) {
        editor.showLibrary(editor.library.lastExpanded);
      }
    };
  }

  GraphEditorCommand.nextLibrary() {
    handler = (GraphEditorController editor) {
      editor.nextLibrary();
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

  // ************************************************************
  //
  //  Graph Commands
  //
  // ************************************************************

  GraphEditorCommand.convertToLibrary(GraphState graph) {
    handler = (GraphEditorController editor) {
      editor.convertToLibrary(graph);
    };
  }

  GraphEditorCommand.deleteGraph(GraphState graph) {
    handler = (GraphEditorController editor) {
      editor.deleteGraph(graph);
    };
  }

  GraphEditorCommand.editGraph(GraphState graph) {
    handler = (GraphEditorController editor) {
      editor.editGraph(graph);
    };
  }

  GraphEditorCommand.editNode(GraphNode node, {NodePort port, String focus}) {
    handler = (GraphEditorController editor) {
      editor.editNode(node, port: port, focus: focus);
    };
  }

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

  GraphEditorCommand.removePort(NodePort port) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.removePort(port);
    };
  }

  GraphEditorCommand.addOutport(GraphNode node) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.addOutport(node);
    };
  }

  GraphEditorCommand.addInport(GraphNode node) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.addInport(node);
    };
  }

  GraphEditorCommand.changeNodeType(GraphNode node, GraphNodeType type) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.changeNodeType(node, type);
    };
  }

  GraphEditorCommand.setPortValue(NodePort port, String value) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.setPortValue(port, value);
    };
  }
  GraphEditorCommand.setPortLink(NodePort port, String link) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.setPortLink(port, link);
    };
  }
  GraphEditorCommand.setPortTrigger(NodePort port, String trigger) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.setPortTrigger(port, trigger);
    };
  }

  GraphEditorCommand.setPortEvent(NodePort port, String event) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.setPortEvent(port, event);
    };
  }

  GraphEditorCommand.removePortFlag(NodePort port) {
    handler = (GraphEditorController editor) {
      editor.graph.controller.removePortFlag(port);
    };
  }

  GraphEditorCommand.addNode(GraphNode node,
      {List<GraphLink> links, bool drag = false, double offset = 0}) {
    handler = (GraphEditorController editor) {
      editor.addNode(node, links: links, drag: drag, offset: offset);
    };
  }

  GraphEditorCommand.copyNode(GraphNode node,
      {NodePort attach, bool drag = false}) {
    handler = (GraphEditorController editor) {
      double offset = 0;
      node = editor.graph.clone(node);

      List<GraphLink> links = [];
      if (attach != null) {
        if (attach.isInport) {
          offset = -2;
          links.add(GraphLink.link(node.defaultOutport, attach));
        } else {
          offset = 2;
          links.add(GraphLink.link(attach, node.defaultInport));
        }
      }

      editor.addNode(node, links: links, drag: drag, offset: offset);
    };
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

  factory GraphEditorCommand.pushIfNotEmpty(MenuItemSet menu, [Offset pt]) {
    if (menu.items.isEmpty) return null;
    if (menu.items.length == 1) return menu.items.first.command;

    return GraphEditorCommand.pushMenu(menu, pt);
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

  GraphEditorCommand.printGraph() {
    handler = (GraphEditorController editor) {
      editor.printFile();
    };
  }

  GraphEditorCommand.showToolsMenu() {
    handler = (GraphEditorController editor) {
      var menu = editor.getToolsMenu();
      editor.openMenu(menu, Offset(0, 0));
    };
  }

  GraphEditorCommand.showAppMenu() {
    handler = (GraphEditorController editor) {};
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
      var menu = editor.getPortMenu(port);

      editor.openMenu(menu, pt);
    };
  }

  GraphEditorCommand.showPortValueMenu(NodePort port, Offset pt) {
    print("Show Port value menu: $port");
    handler = (GraphEditorController editor) {
      var menu = port.isInport
          ? editor.getInportValueMenu(port)
          : editor.getOutportValueMenu(port);

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

  GraphEditorCommand.selectTab(String name) {
    handler = (GraphEditorController editor) {
      editor.selectTab(name);
    };
  }

  GraphEditorCommand.newTab([bool random = false]) {
    handler = (GraphEditorController editor) {
      editor.newTab(random);
    };
  }

  GraphEditorCommand.scrollTab(double direction) {
    handler = (GraphEditorController editor) {
      editor.tabs.controller.scroll(direction);
      editor.selectTab(editor.tabs.selected, reload: true);
    };
  }

  GraphEditorCommand.closeTab(String tabname) {
    handler = (GraphEditorController editor) {
      print("Closing Tab: $tabname");
      editor.tabs.remove(tabname);
      editor.selectTab(editor.tabs.selected, reload: true);
    };
  }

  GraphEditorCommand.restoreTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.restore(true);
      editor.selectTab(editor.tabs.selected, reload: true);
    };
  }

  GraphEditorCommand.prevTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.selectPrev();
      editor.selectTab(editor.tabs.selected, reload: true);
    };
  }

  GraphEditorCommand.nextTab() {
    handler = (GraphEditorController editor) {
      editor.tabs.selectNext();
      editor.selectTab(editor.tabs.selected, reload: true);
    };
  }

  // ************************************************************
  //
  //  Chart File Commands
  //
  // ************************************************************

  GraphEditorCommand.restoreCharts() {
    handler = (GraphEditorController editor) {
      editor.openLastFile();
    };
  }
}
