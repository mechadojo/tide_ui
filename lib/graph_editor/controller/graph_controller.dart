import 'dart:html';

import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_controller.dart';
import 'package:tide_ui/graph_editor/controller/mouse_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

enum MouseMoveMode {
  none,
  selecting,
  dragging,
  linking,
}

class GraphController with MouseController, KeyboardController {
  GraphState graph;
  GraphObject focus;

  List<GraphNode> selection = [];
  List<GraphNode> savedSelection = [];

  GraphController(this.graph);

  MouseMoveMode moveMode = MouseMoveMode.none;
  Offset moveStart = Offset.zero;
  Offset moveEnd = Offset.zero;
  Offset panOffset = Offset.zero;
  Rect selectRect = Rect.zero;

  NodePort linkStart;

  bool get selecting => moveMode == MouseMoveMode.selecting;
  bool get dragging => moveMode == MouseMoveMode.dragging;
  bool get linking => moveMode == MouseMoveMode.linking;

  bool hoverCanceled = false; // tracks if hovering needs to be canceled

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

  Iterable<GraphObject> walkGraph() sync* {
    for (var node in graph.nodes.reversed) {
      if (node.selected) continue;
      yield* node.inports;
      yield* node.outports;
      yield node;
    }

    yield* graph.links;

    for (var node in graph.nodes.reversed) {
      if (!node.selected) continue;
      yield* node.inports;
      yield* node.outports;
      yield node;
    }
  }

  @override
  bool onMouseDown(MouseEvent evt, Offset pt) {
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

      if (evt.shiftKey && evt.ctrlKey) {
        addSelection(node);
      } else if (evt.ctrlKey) {
        toggleSelection(node);
      } else {
        if (selection.length == 1 || !selection.contains(node)) {
          setSelection(node);
        }
      }

      startDragging(pt);
    } else if (focus is NodePort) {
      linkStart = focus as NodePort;
      moveMode = MouseMoveMode.linking;
    }
    return true;
  }

  @override
  bool onMouseUp(MouseEvent evt, Offset pt) {
    if (moveMode == MouseMoveMode.none) return true;

    if (focus == null && dragging && moveStart == moveEnd) {
      clearSelection();
      return true;
    }

    selectRect = Rect.zero;

    graph.beginUpdate();
    moveMode = MouseMoveMode.none;
    graph.endUpdate(true);
    return true;
  }

  @override
  bool onMouseMove(MouseEvent evt, Offset pt) {
    hoverCanceled = false;
    moveEnd = pt;
    graph.beginUpdate();

    var changed = false;
    switch (moveMode) {
      case MouseMoveMode.none:
        changed = onMouseHover(evt, pt);
        break;
      case MouseMoveMode.dragging:
        changed = onMouseDrag(evt, pt);
        changed |= onMouseHover(evt, pt);
        break;
      case MouseMoveMode.linking:
        changed = onMouseLink(evt, pt);
        changed |= onMouseHover(evt, pt);
        break;
      case MouseMoveMode.selecting:
        changed = onMouseSelect(evt, pt);
        changed |= onMouseHover(evt, pt);
        break;
    }

    graph.endUpdate(changed);
    return changed;
  }

  void startDragging(Offset pt) {
    moveMode = MouseMoveMode.dragging;
    for (var node in selection) {
      node.dragStart = node.pos - pt;
    }
  }

  bool onMouseDrag(MouseEvent evt, Offset pt) {
    if (selection.isEmpty) return false;

    var dx = pt.dx;
    var dy = pt.dy;

    for (var node in selection) {
      node.moveTo(node.dragStart.dx + dx, node.dragStart.dy + dy);
      //node.moveTo(node.dragStart.dx + dx, node.dragStart.dy + dy);
    }

    return true;
  }

  bool onMouseSelect(MouseEvent evt, Offset pt) {
    lassoSelection(Rect.fromPoints(moveStart, moveEnd));
    return true;
  }

  bool onMouseLink(MouseEvent evt, Offset pt) {
    return false;
  }

  bool onMouseHover(MouseEvent evt, Offset pt) {
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
}
