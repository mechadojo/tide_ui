import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
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

  GraphController(this.editor);

  MouseMoveMode moveMode = MouseMoveMode.none;

  Offset moveStart = Offset.zero;
  Offset moveEnd = Offset.zero;
  Offset panOffset = Offset.zero;
  Rect selectRect = Rect.zero;

  NodePort linkStart;
  int nextGroup = 0;

  bool get selecting => moveMode == MouseMoveMode.selecting;
  bool get dragging => moveMode == MouseMoveMode.dragging;
  bool get linking => moveMode == MouseMoveMode.linking;

  double longPressRadius = 0;
  Offset longPressPos = Offset.zero;

  bool hoverCanceled = false; // tracks if hovering needs to be canceled
  bool updating = false;

  void applyCommand(GraphCommand cmd) {
    graph.beginUpdate();
    if (cmd is GraphCommandGroup) {
      for (var inner in cmd.cmds) {
        applyCommand(inner);
      }
    }

    if (cmd is GraphMoveCommand) {
      var node = graph.getNode(cmd.node.name);
      node.moveTo(cmd.toPos.dx, cmd.toPos.dy);
    }

    if (cmd is GraphLinkCommand) {
      var link = graph.unpackLink(cmd.link);

      if (cmd.type == "add") {
        addLink(link.outPort, link.inPort, group: link.group, save: false);
      } else if (cmd.type == "remove") {
        removeLink(link.outPort, link.inPort, save: false);
      }
    }

    graph.endUpdate(true);
  }

  void undoHistory() {
    if (!graph.history.canUndo) return;

    graph.beginUpdate();
    var cmd = graph.history.undo();
    applyCommand(cmd.reverse);

    clearSelection();
    graph.endUpdate(true);
  }

  void redoHistory() {
    if (!graph.history.canRedo) return;
    graph.beginUpdate();
    var cmd = graph.history.redo();
    applyCommand(cmd);
    graph.history.push(cmd, false);

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
      var cmd = GraphLinkCommand.remove(link);
      graph.history.push(cmd);
    }
  }

  void addLink(NodePort fromPort, NodePort toPort,
      {int group = -1, bool replace = false, bool save = true}) {
    var outport = fromPort.isOutport ? fromPort : toPort;
    var inport = fromPort.isInport ? fromPort : toPort;

    var idx = graph.findLink(outport, inport);
    if (idx >= 0 || replace) return;

    graph.beginUpdate();
    if (idx >= 0) graph.links.removeAt(idx);

    var link = graph.addLink(outport, inport, group);

    graph.endUpdate(true);

    if (save) {
      var cmd = GraphLinkCommand.add(link);
      graph.history.push(cmd);
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
      yield* node.inports;
      yield* node.outports;
      yield node;
    }

    for (GraphLink link in graph.links) {
      if (selection.contains(link.outPort.node) &&
          selection.contains(link.inPort.node)) {
        yield link;
      }
    }
  }

  Iterable<GraphObject> walkGraph() sync* {
    for (var node in graph.nodes.reversed) {
      if (node.selected) continue;
      yield* node.inports;
      yield* node.outports;
      yield node;
    }

    yield* graph.links.reversed;

    for (var node in graph.nodes.reversed) {
      if (!node.selected) continue;
      yield* node.inports;
      yield* node.outports;
      yield node;
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
      }

      for (var port in node.outports) {
        if (port.isHovered(gpt)) {
          editor.dispatch(GraphEditorCommand.showPortMenu(port, pt));
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
      var cmd = GraphCommandGroup.moveAll(selection);
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

    for (var item in walkGraph()) {
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
  bool onMouseDoubleTap() {
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

    if (key == "z" && evt.ctrlKey) {
      undoHistory();
      return true;
    }

    if (key == "y" && evt.ctrlKey) {
      redoHistory();
      return true;
    }

    return false;
  }
}
