import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_history.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';

import 'graph_event.dart';

enum MouseMoveMode {
  none,
  selecting,
  dragging,
  linking,
}

enum MouseSelectMode { none, add, replace, toggle }

class GraphController with MouseController, KeyboardController {
  GraphEditorController editor;

  GraphState get graph => editor.graph;
  GraphObject focus;

  List<GraphNode> selection = [];
  List<GraphNode> savedSelection = [];

  GraphSelection dropping;

  GraphController(this.editor);

  MouseMoveMode moveMode = MouseMoveMode.none;

  Offset moveStart = Offset.zero;
  Offset moveEnd = Offset.zero;
  Offset panOffset = Offset.zero;
  Rect selectRect = Rect.zero;

  NodePort linkStart;
  int nextGroup = 0;
  int dragRelease = 0; // allows extra mouse down events without canceling
  bool dragDrop = false; // allows escape to cancel and undo last action

  double paddingRight = 0;

  bool get selecting => moveMode == MouseMoveMode.selecting;
  bool get dragging => moveMode == MouseMoveMode.dragging;
  bool get linking => moveMode == MouseMoveMode.linking;

  bool hoverCanceled = false; // tracks if hovering needs to be canceled
  bool updating = false;

  void applyCommand(TideChartCommand cmd, {bool reverse = false}) {
    if (cmd.isLocked && reverse) return;

    graph.beginUpdate();

    switch (cmd.whichCommand()) {
      case TideChartCommand_Command.group:
        for (var inner in cmd.group.commands) {
          applyCommand(inner, reverse: reverse);
        }
        break;
      case TideChartCommand_Command.move:
        {
          var node = graph.getNode(cmd.move.node);

          var dx = reverse
              ? cmd.move.fromPosX.toDouble()
              : cmd.move.toPosX.toDouble();
          var dy = reverse
              ? cmd.move.fromPosY.toDouble()
              : cmd.move.toPosY.toDouble();

          node.moveTo(dx, dy);
        }
        break;

      case TideChartCommand_Command.link:
        {
          var packed = GraphCommand.getLink(cmd.link);
          var link = graph.unpackLink(packed);

          if (GraphCommand.isNotUpdating(cmd.link.type)) {
            if (GraphCommand.isAdding(cmd.link.type, reverse)) {
              addLink(link.outPort, link.inPort,
                  group: link.group, save: false);
            } else {
              removeLink(link.outPort, link.inPort, save: false);
            }
          }
        }
        break;
      case TideChartCommand_Command.node:
        {
          var packed = GraphCommand.getNode(cmd.node);
          var node = graph.unpackNode(packed);

          if (GraphCommand.isNotUpdating(cmd.node.type)) {
            if (GraphCommand.isAdding(cmd.node.type, reverse)) {
              addNode(node, save: false);
            } else {
              removeNode(node, save: false);
            }
          }
        }
        break;
      default:
        break;
    }

    graph.endUpdate(true);
  }

  void previewDrop(GraphSelection dropping) {
    graph.beginUpdate();
    this.dropping = dropping;
    graph.endUpdate(true);
  }

  void cancelDrop() {
    if (dropping == null) return;

    graph.beginUpdate();
    dropping = null;
    graph.endUpdate(true);
  }

  void startDrop(GraphSelection dropping) {
    // used by external drop/drop or clipboard
    // need to set dropping mode

    graph.beginUpdate();
    dropping = dropping;
    graph.endUpdate(true);
  }

  void endDrop(GraphSelection dropping) {
    graph.beginUpdate();
    this.dropping = null;
    var dx = dropping.pos.dx;
    var dy = dropping.pos.dy;

    print("Drop at $dx, $dy");
    var cmd = TideChartCommand()..group = TideChartGroupCommand();

    for (var node in dropping.nodes) {
      var next = graph.clone(node);
      next.moveBy(dx, dy);

      cmd.group.commands.add(GraphCommand.addNode(next));
    }

    if (cmd.group.commands.isNotEmpty) {
      applyCommand(cmd);
      graph.history.push(cmd);
    }

    graph.endUpdate(true);
  }

  void undoHistory() {
    if (!graph.history.canUndo) return;
    if (graph.history.undoCmds.isEmpty) return;

    var cmd = graph.history.undo();
    if (cmd.isLocked) {
      undoHistory();
      return;
    }

    graph.beginUpdate();

    applyCommand(cmd, reverse: true);

    clearSelection();
    graph.endUpdate(true);
  }

  void redoHistory() {
    if (!graph.history.canRedo) return;
    graph.beginUpdate();
    var cmd = graph.history.redo();

    applyCommand(cmd);
    graph.history.push(cmd, clear: false);

    clearSelection();
    graph.endUpdate(true);
  }

  void clearSelection() {
    if (selection.isEmpty) return;

    graph.beginUpdate();
    for (var node in selection) {
      node.selected = false;
    }
    selection.clear();
    graph.endUpdate(true);
  }

  void addSelection(GraphNode node) {
    if (selection.contains(node)) return;

    selection.add(node);

    graph.beginUpdate();
    node.selected = true;
    graph.endUpdate(true);
  }

  void removeLink(NodePort fromPort, NodePort toPort, {bool save = true}) {
    var outport = fromPort.isOutport ? fromPort : toPort;
    var inport = fromPort.isInport ? fromPort : toPort;
    var idx = graph.findLink(outport, inport);

    if (idx < 0) return;

    graph.beginUpdate();
    var link = graph.links.removeAt(idx);
    graph.endUpdate(true);

    if (save) {
      var cmd = GraphCommand.removeLink(link);
      graph.history.push(cmd);
    }
  }

  void setPortValue(NodePort port, String value, {bool save = true}) {
    // not allowed to set a value on a port that also has a link
    if (value != null) {
      if (!graph.allowAddFlag(port)) {
        return;
      }
    }

    graph.beginUpdate();
    port.setValue(value);
    graph.endUpdate(true);
  }

  void setPortTrigger(NodePort port, String trigger, {bool save = true}) {
    // not allowed to set a value on a port that also has a link
    if (trigger != null) {
      if (!graph.allowAddFlag(port)) {
        return;
      }
    }

    graph.beginUpdate();
    port.setTrigger(trigger);
    graph.endUpdate(true);
  }

  void setPortLink(NodePort port, String link, {bool save = true}) {
    // not allowed to set a value on a port that also has a link
    if (link != null) {
      if (!graph.allowAddFlag(port)) {
        return;
      }
    }

    graph.beginUpdate();
    port.setLink(link);
    graph.endUpdate(true);
  }

  void setPortEvent(NodePort port, String event, {bool save = true}) {
    // not allowed to set a value on a port that also has a link
    if (event != null) {
      if (!graph.allowAddFlag(port)) {
        return;
      }
    }

    graph.beginUpdate();
    port.setEvent(event);
    graph.endUpdate(true);
  }

  void removePortFlag(NodePort port, {bool save = true}) {
    // not allowed to set a value on a port that also has a link
    graph.beginUpdate();

    port.clearFlag();

    graph.endUpdate(true);
  }

  void changeNodeType(GraphNode node, GraphNodeType type, {bool save = true}) {
    graph.beginUpdate();
    node.type = type;
    if (type == GraphNodeType.inport) node.icon = "sign-in-alt";
    if (type == GraphNodeType.outport) node.icon = "sign-out-alt";
    if (type == GraphNodeType.event || type == GraphNodeType.trigger) {
      node.icon = "bolt";
    }
    node.resize();
    graph.endUpdate(true);
  }

  void removeNodes(List<GraphNode> nodes,
      {bool save = true, bool locked = false, bool relink = false}) {
    List<TideChartCommand> cmds = [];

    graph.beginUpdate();

    for (var node in nodes) {
      var idx = graph.findNode(node);
      if (idx < 0) continue;
      node = graph.nodes.removeAt(idx);
      cmds.add(GraphCommand.removeNode(node));

      var links = graph.getNodeLinks(node).toList();
      for (var link in links) {
        removeLink(link.outPort, link.inPort, save: false);
        cmds.add(GraphCommand.removeLink(link));
      }
    }

    graph.endUpdate(true);

    if (save) {
      graph.history.push(GraphCommand.all(cmds), locked: locked);
    }
  }

  void removeNode(GraphNode node,
      {bool save = true, bool locked = false, bool relink = false}) {
    var idx = graph.findNode(node);
    if (idx < 0) return;

    List<TideChartCommand> cmds = [];

    graph.beginUpdate();
    node = graph.nodes.removeAt(idx);
    cmds.add(GraphCommand.removeNode(node));

    var links = graph.getNodeLinks(node).toList();
    for (var link in links) {
      removeLink(link.outPort, link.inPort, save: false);
      cmds.add(GraphCommand.removeLink(link));
    }

    graph.endUpdate(true);

    if (save) {
      graph.history.push(GraphCommand.all(cmds), locked: locked);
    }
  }

  void addNode(GraphNode node,
      {bool save = true, bool replace = false, List<GraphLink> links}) {
    var idx = graph.findNode(node);
    if (idx >= 0 || replace) return;

    List<TideChartCommand> cmds = [];

    graph.beginUpdate();
    if (idx >= 0) graph.nodes.removeAt(idx);
    graph.nodes.add(node);
    cmds.add(GraphCommand.addNode(node));

    links = links ?? [];
    for (var link in links) {
      addLink(link.outPort, link.inPort, group: link.group, save: false);
      cmds.add(GraphCommand.addLink(link));
    }

    graph.endUpdate(true);

    if (save) {
      graph.history.push(GraphCommand.all(cmds));
    }
  }

  void addLink(NodePort outPort, NodePort inPort,
      {int group = -1, bool replace = false, bool save = true}) {
    var outport = outPort.isOutport ? outPort : inPort;
    var inport = outPort.isInport ? outPort : inPort;

    var idx = graph.findLink(outport, inport);
    if (idx >= 0 || replace) return;

    List<TideChartCommand> cmds = [];

    graph.beginUpdate();
    if (idx >= 0) graph.links.removeAt(idx);

    if (outPort.value != null) {
      setPortValue(outPort, null, save: false);
    }

    if (inPort.value != null) {
      setPortValue(inPort, null, save: false);
    }

    var link = graph.addLink(outport, inport, group);
    cmds.add(GraphCommand.addLink(link));

    graph.endUpdate(true);

    if (save) {
      graph.history.push(GraphCommand.all(cmds));
    }
  }

  void lassoSelection(Rect rect) {
    bool changed = rect != selectRect;
    selectRect = rect;
    graph.beginUpdate();
    selection = [...savedSelection];
    for (var node in graph.nodes) {
      var selected = node.hitbox.overlaps(rect);
      if (selected != node.selected) {
        changed = true;
      }

      node.selected = selected || savedSelection.contains(node);
      if (selected && !selection.contains(node)) {
        selection.add(node);
      }
    }
    graph.endUpdate(changed);
  }

  void setSelection(GraphNode node) {
    if (selection.length == 1 && selection.contains(node)) return;

    graph.beginUpdate();

    for (var selected in selection) {
      selected.selected = false;
    }

    selection.clear();
    node.selected = true;
    selection.add(node);

    graph.endUpdate(true);
  }

  void toggleSelection(GraphNode node) {
    graph.beginUpdate();
    if (selection.contains(node)) {
      node.selected = false;
      selection.remove(node);
    } else {
      node.selected = true;
      selection.add(node);
    }
    graph.endUpdate(true);
  }

  Iterable<GraphObject> walkSelection() sync* {
    for (GraphNode node in selection) {
      yield* node.walkNode();
    }

    for (GraphLink link in graph.links) {
      if (selection.contains(link.outPort.node) &&
          selection.contains(link.inPort.node)) {
        yield link;
      }
    }
  }

  @override
  Offset getPos(Offset pt) {
    return editor.canvas.toGraphCoord(pt);
  }

  @override
  bool onContextMenu(GraphEvent evt) {
    var gpt = getPos(evt.pos);
    var pt = editor.canvas.toScreenCoord(gpt);

    for (var node in graph.nodes.reversed) {
      for (var port in node.inports) {
        if (port.isHovered(gpt)) {
          editor.dispatch(GraphEditorCommand.showPortMenu(port, pt));
          return true;
        }

        if (port.flag.isHovered(gpt)) {
          editor.dispatch(GraphEditorCommand.showPortValueMenu(port, pt));
          return true;
        }
      }

      for (var port in node.outports) {
        if (port.isHovered(gpt)) {
          editor.dispatch(GraphEditorCommand.showPortMenu(port, pt));
          return true;
        }

        if (port.flag.isHovered(gpt)) {
          editor.dispatch(GraphEditorCommand.showPortValueMenu(port, pt));
          return true;
        }
      }

      if (node.isHovered(gpt)) {
        editor.dispatch(GraphEditorCommand.showNodeMenu(node, pt));
        return true;
      }
    }

    for (var link in graph.links.reversed) {
      if (link.isHovered(gpt)) {
        editor.dispatch(GraphEditorCommand.showLinkMenu(link, pt));
        return true;
      }
    }

    editor.dispatch(GraphEditorCommand.showGraphMenu(graph, pt));
    return true;
  }

  @override
  bool onMouseDown(GraphEvent evt) {
    var pt = getPos(evt.pos);

    moveStart = pt;

    if (moveMode == MouseMoveMode.dragging) {
      --dragRelease;
      return true;
    }

    if (focus == null) {
      if (selection.length <= 1 || evt.ctrlKey) {
        moveMode = MouseMoveMode.selecting;
        if (evt.shiftKey) {
          savedSelection = [...selection];
        } else {
          savedSelection = [];
          clearSelection();
        }

        selectRect = Rect.zero;
      } else {
        startDragging(pt);
      }
      return true;
    }

    if (focus is GraphNode) {
      var node = focus as GraphNode;

      switch (getSelectMode(evt, node)) {
        case MouseSelectMode.none:
          return true;

        case MouseSelectMode.add:
          addSelection(node);
          break;
        case MouseSelectMode.toggle:
          toggleSelection(node);
          break;
        case MouseSelectMode.replace:
          setSelection(node);
          break;
      }

      startDragging(pt);
    } else if (focus is NodePort) {
      linkStart = focus as NodePort;
      moveMode = MouseMoveMode.linking;
      nextGroup = GraphNode.nodeRandom.nextInt(Graph.MaxGroupNumber);
    }
    return true;
  }

  MouseSelectMode getSelectMode(GraphEvent evt, GraphNode node) {
    if (evt.ctrlKey) return MouseSelectMode.toggle;

    if (selection.length == 1 || !selection.contains(node)) {
      return MouseSelectMode.replace;
    } else {
      return MouseSelectMode.add;
    }
  }

  @override
  bool onMouseUp(GraphEvent evt) {
    if (moveMode == MouseMoveMode.none) return true;
    if (moveMode == MouseMoveMode.dragging && dragRelease > 0) return true;

    dragDrop = false;

    if (focus == null && dragging && moveStart == moveEnd) {
      print("Cancel Selection and Editing");

      clearSelection();
      editor.cancelEditing();
      return true;
    }

    if (focus is NodePort && linkStart != null) {
      var port = focus as NodePort;
      if (linkStart.canLinkTo(port)) {
        addLink(linkStart, port, group: nextGroup);
      }
    }

    if (focus is GraphLink && linkStart != null) {
      var link = focus as GraphLink;
      var target = linkStart.isInport ? link.outPort : link.inPort;
      addLink(linkStart, target, group: nextGroup);
    }

    selectRect = Rect.zero;

    graph.beginUpdate();

    if (dragging && selection.isNotEmpty) {
      var cmd = GraphCommand.moveAll(selection);
      graph.history.push(cmd);
    }

    moveMode = MouseMoveMode.none;
    if (editor.isTouchMode && focus != null) {
      focus.hovered = false;
      focus = null;
    }

    graph.endUpdate(true);
    return true;
  }

  @override
  bool onMouseMove(GraphEvent evt) {
    var pt = getPos(evt.pos);
    hoverCanceled = false;
    moveEnd = pt;
    graph.beginUpdate();

    var changed = false;
    switch (moveMode) {
      case MouseMoveMode.none:
        changed = onMouseHover(evt);
        break;
      case MouseMoveMode.dragging:
        changed = onMouseDrag(evt);
        changed |= onMouseHover(evt);
        break;
      case MouseMoveMode.linking:
        changed = onMouseLink(evt);
        changed |= onMouseHover(evt);
        break;
      case MouseMoveMode.selecting:
        changed = onMouseSelect(evt);
        changed |= onMouseHover(evt);
        break;
    }

    graph.endUpdate(changed);
    return changed;
  }

  void startDragging(Offset pt) {
    moveMode = MouseMoveMode.dragging;
    for (var node in selection) {
      node.dragOffset = node.pos - pt;
      node.dragStart = node.pos;
    }
    dragRelease = 0;
  }

  bool onMouseDrag(GraphEvent evt) {
    var pt = getPos(evt.pos);
    if (selection.isEmpty) return false;

    var dx = pt.dx;
    var dy = pt.dy;

    for (var node in selection) {
      node.moveTo(node.dragOffset.dx + dx, node.dragOffset.dy + dy);
    }

    return true;
  }

  bool onMouseSelect(GraphEvent evt) {
    lassoSelection(Rect.fromPoints(moveStart, moveEnd));
    return true;
  }

  bool onMouseLink(GraphEvent evt) {
    return true;
  }

  bool onMouseHover(GraphEvent evt) {
    var pt = getPos(evt.pos);
    bool changed = false;
    bool isHovering = false;

    for (var item in graph.walkGraph()) {
      // only one item at a time can have hovering focus
      if (isHovering) {
        if (item.hovered) {
          item.hovered = false;
          changed = true;
        }
      } else {
        isHovering = item.isHovered(pt);
        if (isHovering != item.hovered) {
          item.hovered = isHovering;
          changed = true;
        }
        if (isHovering) focus = item;
      }
    }

    if (!isHovering) {
      focus = null;
    }

    return changed;
  }

  @override
  bool onMouseDoubleTap(GraphEvent evt) {
    graph.beginUpdate();
    onMouseOut();
    clearSelection();
    moveMode = MouseMoveMode.none;
    if (focus != null) {
      focus.hovered = false;
      focus = null;
    }
    graph.endUpdate(true);
    return true;
  }

  void addFromToolbox([int hotkey = -1, GraphEvent evt]) {
    if (editor.library.isCollapsed) {
      editor
          .dispatch(GraphEditorCommand.showLibrary(LibraryDisplayMode.toolbox));
    }

    var node = graph.clone(editor.library.getToolboxNode(hotkey, evt));
    if (node != null) {
      List<GraphLink> links = [];

      if (linking) {
        if (linkStart.isInport) {
          links.add(GraphLink.link(node.defaultOutport, linkStart));
        } else {
          links.add(GraphLink.link(linkStart, node.defaultInport));
        }
      }

      editor
          .dispatch(GraphEditorCommand.addNode(node, links: links, drag: true));
    }
  }

  @override
  bool onMouseOut() {
    if (hoverCanceled) return true;

    graph.beginUpdate();

    bool changed = false;
    if (focus != null) {
      changed = focus.hovered;
      focus.hovered = false;
    }

    graph.endUpdate(changed);
    hoverCanceled = true;
    return true;
  }

  @override
  bool onKeyDown(GraphEvent evt) {
    var key = evt.key.toLowerCase();

    if (key == "escape") {
      if (dragDrop) {
        undoHistory();
      }

      if (dragging) {
        for (var node in selection) {
          node.moveTo(node.dragStart.dx, node.dragStart.dy);
        }
      }

      clearSelection();
      editor.cancelDrop();
      editor.cancelEditing();

      return true;
    }
    if (key == "z" && evt.ctrlKey) {
      undoHistory();
      return true;
    }

    if (key == "y" && evt.ctrlKey) {
      redoHistory();
      return true;
    }

    // toggle the librTary panels
    if (key == 't') {
      if (evt.shiftKey) {
        if (editor.library.isExpanded) {
          editor.dispatch(GraphEditorCommand.collapseLibrary());
        } else {
          editor.dispatch(GraphEditorCommand.expandLibrary());
        }
      } else {
        if (!editor.library.isExpanded) {
          var mode = editor.library.mode == LibraryDisplayMode.toolbox
              ? LibraryDisplayMode.collapsed
              : LibraryDisplayMode.toolbox;
          editor.dispatch(GraphEditorCommand.showLibrary(mode));
        } else {
          var mode = editor.library.mode == LibraryDisplayMode.expanded
              ? LibraryDisplayMode.detailed
              : LibraryDisplayMode.expanded;
          editor.dispatch(GraphEditorCommand.showLibrary(mode));
        }
      }
    }

    if (evt.keyCode >= 48 && evt.keyCode <= 57) {
      int hotkey = evt.keyCode == 48 ? 9 : evt.keyCode - 49;
      addFromToolbox(hotkey, evt);
    }

    if (key == " ") {
      addFromToolbox(-1, evt);
      return true;
    }

    return false;
  }
}
