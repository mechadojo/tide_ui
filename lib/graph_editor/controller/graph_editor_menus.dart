import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_filesource.dart';
import 'package:tide_ui/graph_editor/controller/library_controller.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_link.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/data/node_port.dart';

import 'graph_controller.dart';
import 'graph_editor_controller.dart';

mixin GraphEditorMenus on GraphEditorControllerBase {
  MenuItemSet getToolsMenu() {
    return MenuItemSet([
      MenuItem(
        icon: "history",
        title: "History",
        command: GraphEditorCommand.showLibraryTab(LibraryTab.history),
      ),
      MenuItem(
        icon: "print",
        title: "Print",
        command: GraphEditorCommand.printGraph(),
      ),
      MenuItem(
        icon: "save",
        title: "Save",
        command: GraphEditorCommand.pushMenu(getSaveFileMenu()),
      ),
      MenuItem(
        icon: "folder-open-solid",
        title: "Open",
        command: GraphEditorCommand.pushMenu(getOpenFileMenu()),
      ),
      MenuItem(
        icon: "file",
        title: "New",
        command: GraphEditorCommand.newFile(),
      ),
      MenuItem(
        icon: "upload",
        title: "Connect",
        command: GraphEditorCommand.pushMenu(getConnectMenu()),
      ),
    ])
      ..icon = "tools";
  }

  MenuItemSet getOpenCloudMenu() {
    return MenuItemSet([
      MenuItem(
        icon: "github-brands",
        title: "GitHub",
        command: GraphEditorCommand.openFile(FileSourceType.github),
      ),
      MenuItem(
        icon: "google-drive-brands",
        title: "Google",
        command: GraphEditorCommand.openFile(FileSourceType.google),
      ),
      MenuItem(
        icon: "dropbox-brands",
        title: "DropBox",
        command: GraphEditorCommand.openFile(FileSourceType.dropbox),
      ),
      MenuItem(
        icon: "microsoft-brands",
        title: "One Drive",
        command: GraphEditorCommand.openFile(FileSourceType.onedrive),
      ),
      MenuItem(
        icon: "slack-brands",
        title: "Slack",
        command: GraphEditorCommand.openFile(FileSourceType.slack),
      ),
    ])
      ..icon = "cloud";
  }

  MenuItemSet getSaveCloudMenu() {
    return MenuItemSet([
      MenuItem(
        icon: "github-brands",
        title: "GitHub",
        command: GraphEditorCommand.saveFile(FileSourceType.github),
      ),
      MenuItem(
        icon: "google-drive-brands",
        title: "Google",
        command: GraphEditorCommand.saveFile(FileSourceType.google),
      ),
      MenuItem(
        icon: "dropbox-brands",
        title: "DropBox",
        command: GraphEditorCommand.saveFile(FileSourceType.dropbox),
      ),
      MenuItem(
        icon: "microsoft-brands",
        title: "One Drive",
        command: GraphEditorCommand.saveFile(FileSourceType.onedrive),
      ),
      MenuItem(
        icon: "slack-brands",
        title: "Slack",
        command: GraphEditorCommand.saveFile(FileSourceType.slack),
      ),
    ])
      ..icon = "cloud";
  }

  MenuItemSet getOpenFileMenu() {
    return MenuItemSet([
      MenuItem(
          icon: "code-branch",
          title: "Branch",
          command: GraphEditorCommand.openFile(FileSourceType.branch)),
      MenuItem(
          icon: editor.platformIcon,
          title: "Local",
          command: GraphEditorCommand.openFile(FileSourceType.local)),
      MenuItem(
          icon: "file-archive",
          title: "File",
          command: GraphEditorCommand.openFile(FileSourceType.file)),
      MenuItem(
          icon: "cloud",
          title: "Cloud",
          command: GraphEditorCommand.pushMenu(getOpenCloudMenu())),
      MenuItem(
          icon: "mobile-alt",
          title: "Device",
          command: GraphEditorCommand.openFile(FileSourceType.device)),
    ])
      ..icon = "folder-open-solid";
  }

  MenuItemSet getSaveFileMenu() {
    return MenuItemSet([
      MenuItem(
          icon: "code-branch",
          title: "Branch",
          command: GraphEditorCommand.saveFile(FileSourceType.branch)),
      MenuItem(
          icon: editor.platformIcon,
          title: "Local",
          command: GraphEditorCommand.saveFile(FileSourceType.local)),
      MenuItem(
          icon: "file-archive",
          title: "File",
          command: GraphEditorCommand.saveFile(FileSourceType.file)),
      MenuItem(
          icon: "cloud",
          title: "Cloud",
          command: GraphEditorCommand.pushMenu(getSaveCloudMenu())),
      MenuItem(
          icon: "mobile-alt",
          title: "Device",
          command: GraphEditorCommand.saveFile(FileSourceType.device)),
    ])
      ..icon = "folder-open-solid";
  }

  MenuItemSet getConnectMenu() {
    return MenuItemSet([
      MenuItem(icon: "lightbulb-solid"),
      MenuItem(icon: "bug"),
      MenuItem(icon: "cloud"),
      MenuItem(icon: "wifi"),
      MenuItem(icon: "mobile-alt"),
    ])
      ..icon = "upload";
  }

  MenuItemSet getSelectOutportMenu(GraphNode node) {
    if (node.outports.length == 1) {
      return getOutportMenu(node.outports.first);
    }

    var result = MenuItemSet();

    for (var port in node.outports) {
      result.items.add(MenuItem(
          title: port.name,
          command: GraphEditorCommand.pushMenu(getPortMenu(port))));
    }
    return result
      ..icon = node.icon
      ..title = node.title ?? node.name;
  }

  MenuItemSet getSelectInportMenu(GraphNode node) {
    if (node.inports.length == 1) {
      return getInportMenu(node.inports.first);
    }

    var result = MenuItemSet();
    for (var port in node.inports) {
      result.items.add(MenuItem(
          title: port.name,
          command: GraphEditorCommand.pushMenu(getPortMenu(port))));
    }
    return result
      ..icon = node.icon
      ..title = node.hasTitle ? node.title : node.name;
  }

  MenuItemSet getAttachToolboxMenu(NodePort port) {
    var nodes = library.toolbox.map((x) => x.dropNode);
    return getAttachNodesMenu(port, nodes);
  }

  MenuItemSet getAttachNodesMenu(NodePort port, Iterable<GraphNode> nodes) {
    var result = MenuItemSet();
    for (var node in nodes) {
      if (port.isInport) {
        if (node.outports.isEmpty) continue;
      } else {
        if (node.inports.isEmpty) continue;
      }

      result.items.add(MenuItem(
          icon: node.icon,
          title: node.hasTitle ? node.title : node.name,
          command:
              GraphEditorCommand.copyNode(node, attach: port, drag: true)));
    }

    return result
      ..icon = port.icon
      ..title = port.name;
  }

  MenuItemSet getMethodNodeMenu(GraphNode node) {
    var refs =
        editor.controller.usingMethod(node.library, node.method).toList();

    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "chevron-circle-right",
          command: GraphEditorCommand.addOutport(node)),
      MenuItem(
        icon: "search",
        title: "Find",
        command: refs.isEmpty ? null : GraphEditorCommand.print("find nodes"),
      ),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: refs.isNotEmpty ? null : GraphEditorCommand.removeNode(node),
      ),
      MenuItem(
          icon: "chevron-circle-left",
          command: GraphEditorCommand.addInport(node)),
    ]);
  }

  MenuItemSet getActionNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "chevron-circle-right",
          command: GraphEditorCommand.pushMenu(getSelectOutportMenu(node))),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: GraphEditorCommand.removeNode(node),
      ),
      MenuItem(
          icon: "chevron-circle-left",
          command: GraphEditorCommand.pushMenu(getSelectInportMenu(node))),
    ]);
  }

  MenuItemSet getTriggerNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "chevron-circle-right",
          command: GraphEditorCommand.pushMenu(getSelectOutportMenu(node))),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: GraphEditorCommand.removeNode(node),
      ),
      MenuItem(
          icon: "sign-in-alt",
          command:
              GraphEditorCommand.changeNodeType(node, GraphNodeType.inport)),
    ]);
  }

  MenuItemSet getEventNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "sign-out-alt",
          command:
              GraphEditorCommand.changeNodeType(node, GraphNodeType.outport)),
      MenuItem(
          icon: "trash-alt",
          title: "Delete",
          command: GraphEditorCommand.removeNode(node)),
      MenuItem(
          icon: "chevron-circle-left",
          command: GraphEditorCommand.pushMenu(getSelectInportMenu(node))),
    ]);
  }

  MenuItemSet getInportNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "chevron-circle-right",
          command: GraphEditorCommand.pushMenu(getSelectOutportMenu(node))),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: GraphEditorCommand.removeNode(node),
      ),
      MenuItem(
          icon: "bolt",
          command:
              GraphEditorCommand.changeNodeType(node, GraphNodeType.trigger)),
    ]);
  }

  MenuItemSet getOutportNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
          icon: "bolt",
          command:
              GraphEditorCommand.changeNodeType(node, GraphNodeType.event)),
      MenuItem(
          icon: "trash-alt",
          title: "Delete",
          command: GraphEditorCommand.removeNode(node)),
      MenuItem(
          icon: "chevron-circle-left",
          command: GraphEditorCommand.pushMenu(getSelectInportMenu(node))),
    ]);
  }

  MenuItemSet getBehaviorNodeMenu(GraphNode node) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(node, focus: "title")),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: GraphEditorCommand.removeNode(node),
      ),
    ]);
  }

  MenuItemSet getNodeMenu(GraphNode node) {
    switch (node.type) {
      case GraphNodeType.action:
        return graph.isLibrary
            ? getMethodNodeMenu(node)
            : getActionNodeMenu(node);
      case GraphNodeType.behavior:
        return getBehaviorNodeMenu(node);
      case GraphNodeType.inport:
        return getInportNodeMenu(node);
      case GraphNodeType.outport:
        return getOutportNodeMenu(node);
      case GraphNodeType.trigger:
        return getTriggerNodeMenu(node);
      case GraphNodeType.event:
        return getEventNodeMenu(node);
      default:
        return MenuItemSet([
          MenuItem(
              icon: "edit",
              title: "Edit",
              command: GraphEditorCommand.editNode(node, focus: "title")),
          MenuItem(
            icon: "trash-alt",
            title: "Delete",
            command: GraphEditorCommand.removeNode(node),
          ),
        ]);
    }
  }

  MenuItemSet getLinkMenu(GraphLink link) {
    return MenuItemSet([
      MenuItem(icon: "edit"),
      MenuItem(icon: "link"),
      MenuItem(
        icon: "trash-alt",
        title: "Delete",
        command: GraphEditorCommand.removeLink(link),
      ),
    ]);
  }

  MenuItemSet getOutportValueMenu(NodePort port) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "value")),
      MenuItem(
          icon: "link",
          title: "Link",
          command: port.hasLink
              ? null
              : GraphEditorCommand.setPortLink(
                  port, port.flagLabel ?? GraphNode.randomName())),
      MenuItem(
          icon: "trash-alt", command: GraphEditorCommand.removePortFlag(port)),
      MenuItem(
          icon: "bolt",
          title: "Event",
          command: port.hasEvent
              ? null
              : GraphEditorCommand.setPortEvent(
                  port, port.flagLabel ?? GraphNode.randomName())),
    ])
      ..title = port.name
      ..icon = port.icon;
  }

  MenuItemSet getInportValueMenu(NodePort port) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "value")),
      MenuItem(
          icon: "bolt",
          title: "Trigger",
          command: port.hasTrigger
              ? null
              : GraphEditorCommand.setPortTrigger(
                  port, port.flagLabel ?? GraphNode.randomName())),
      MenuItem(
          icon: "link",
          title: "Link",
          command: port.hasLink
              ? null
              : GraphEditorCommand.setPortLink(
                  port, port.flagLabel ?? GraphNode.randomName())),
      MenuItem(
          icon: "trash-alt", command: GraphEditorCommand.removePortFlag(port)),
      MenuItem(
          icon: "hashtag",
          title: "Value",
          command: port.hasValue
              ? null
              : GraphEditorCommand.setPortValue(
                  port, port.flagLabel ?? GraphNode.randomName())),
    ])
      ..title = port.name
      ..icon = port.icon;
  }

  MenuItemSet getMethodInportMenu(NodePort port) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "name")),
      MenuItem(icon: "trash-alt", command: GraphEditorCommand.removePort(port)),
      MenuItem(
          icon: "hashtag",
          title: "Value",
          command: port.hasValue
              ? null
              : GraphEditorCommand.setPortValue(
                  port, port.flagLabel ?? GraphNode.randomName())),
    ]);
  }

  MenuItemSet getInportMenu(NodePort port) {
    var toolboxMenu = getAttachToolboxMenu(port);

    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "name")),
      MenuItem(
          icon: "hashtag",
          title: "Value",
          command: port.hasValue || port.node.allowAddFilter
              ? null
              : GraphEditorCommand.setPortValue(
                  port, port.flagLabel ?? GraphNode.randomName())),
      MenuItem(
          icon: "toolbox",
          title: "Toolbox",
          command: GraphEditorCommand.pushIfNotEmpty(toolboxMenu)),
      MenuItem(
          icon: "bolt",
          title: "Trigger",
          command: GraphEditorCommand.copyNode(GraphNode.trigger(),
              attach: port, drag: true)),
      MenuItem(
          icon: "sign-in-alt",
          title: "Inport",
          command: GraphEditorCommand.copyNode(GraphNode.inport(),
              attach: port, drag: true)),
    ]);
  }

  MenuItemSet getOutportMenu(NodePort port) {
    var toolboxMenu = getAttachToolboxMenu(port);

    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "name")),
      MenuItem(
          icon: "sign-out-alt",
          title: "Outport",
          command: GraphEditorCommand.copyNode(GraphNode.outport(),
              attach: port, drag: true)),
      MenuItem(
          icon: "bolt",
          title: "Event",
          command: GraphEditorCommand.copyNode(GraphNode.event(),
              attach: port, drag: true)),
      MenuItem(
          icon: "toolbox",
          title: "Toolbox",
          command: GraphEditorCommand.pushIfNotEmpty(toolboxMenu)),
      MenuItem(
          icon: "link",
          title: "Link",
          command: port.hasLink || port.node.allowAddFilter
              ? null
              : GraphEditorCommand.setPortLink(
                  port, port.flagLabel ?? GraphNode.randomName())),
    ]);
  }

  MenuItemSet getMethodOutportMenu(NodePort port) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editNode(port.node,
              port: port, focus: "name")),
      MenuItem(
          icon: "bolt",
          title: "Event",
          command: port.hasLink
              ? null
              : GraphEditorCommand.setPortEvent(
                  port, port.flagLabel ?? GraphNode.randomName())),
      MenuItem(icon: "trash-alt", command: GraphEditorCommand.removePort(port)),
    ]);
  }

  MenuItemSet getPortMenu(NodePort port) {
    if (graph.isLibrary) {
      if (port.isInport) {
        return getMethodInportMenu(port)
          ..icon = port.icon
          ..title = port.name;
      } else {
        return getMethodOutportMenu(port)
          ..icon = port.icon
          ..title = port.name;
      }
    } else {
      if (port.isInport) {
        return getInportMenu(port)
          ..icon = port.icon
          ..title = port.name;
      } else {
        return getOutportMenu(port)
          ..icon = port.icon
          ..title = port.name;
      }
    }
  }

  MenuItemSet getGraphMenu(GraphState graph) {
    return MenuItemSet([
      MenuItem(
          icon: "edit",
          title: "Edit",
          command: GraphEditorCommand.editGraph(graph)),
      MenuItem(
        icon: "tools",
        title: "File",
        command: GraphEditorCommand.pushMenu(getToolsMenu()),
      ),
      if (graph.isLibrary)
        MenuItem(
            icon: "plus",
            title: "add",
            command: GraphEditorCommand.copyNode(
                GraphNode.action()
                  ..library = "user"
                  ..method = "idle"
                  ..title = "Method ${graph.nodes.length}",
                drag: true)),
      MenuItem(
          icon: "redo",
          title: "Redo",
          command:
              graph.history.canRedo ? GraphEditorCommand.redoHistory() : null),
      MenuItem(
          icon: "undo",
          title: "Undo",
          command:
              graph.history.canUndo ? GraphEditorCommand.undoHistory() : null),
      MenuItem(
        icon: "cog",
        title: "Settings",
        command: GraphEditorCommand.print("Open Settings"),
      ),
    ]);
  }

  // *************************************************************
  //
  //  Menu Implementation for Graph Editor Controller
  //
  // *************************************************************

  void showMenu([Offset pt]) {
    graph.controller.moveMode = MouseMoveMode.none;
    graph.controller.clearSelection();

    menu.beginUpdate();
    menu.clearInteractive(); // clears ui interactive states

    moveMenu(pt);

    menu.controller.allowClose = false;
    menu.visible = true;
    menu.endUpdate(true);
  }

  void moveMenu(Offset pt) {
    tabs.beginUpdate();

    if (pt != null) {
      var sz = Graph.RadialMenuSize * 2;

      var rect = Rect.fromCenter(center: pt, width: sz, height: sz);
      var limits = canvas.controller.menuLimits;

      var dx = rect.left < limits.left ? limits.left - rect.left : 0;
      var dy = rect.top < limits.top ? limits.top - rect.top : 0;
      dx = rect.right > limits.right ? limits.right - rect.right : dx;
      dy = rect.bottom > limits.bottom ? limits.bottom - rect.bottom : dy;

      menu.moveTo(pt.translate(dx, dy));
    }

    tabs.endUpdate(true);
  }

  void hideMenu({bool resetMoveMode = true, bool resetPanning = true}) {
    if (resetMoveMode) {
      graph.controller.moveMode = MouseMoveMode.none;
    }

    menu.beginUpdate();
    menu.visible = false;
    menu.endUpdate(true);

    if (resetPanning) {
      canvas.controller.stopPanning();
    }
  }

  void openMenu(MenuItemSet items, [Offset pt, bool resetStack = true]) {
    menu.beginUpdate();
    if (resetStack) {
      menu.controller.menuStack.clear();
    }

    menu.controller.openMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }

    menu.endUpdate(true);
  }

  void pushMenu(MenuItemSet items, [Offset pt]) {
    pt = pt ?? menu.pos;

    menu.beginUpdate();
    menu.controller.pushMenu(items);
    if (!menu.visible) {
      showMenu(pt);
    } else if (pt != null) {
      moveMenu(pt);
    }
    menu.endUpdate(true);
  }

  void popMenu([bool autoClose = false]) {
    menu.beginUpdate();
    var last = menu.controller.popMenu();
    if (last == null) {
      if (autoClose) {
        hideMenu();
      }
    } else {
      if (!menu.visible) {
        showMenu(menu.pos);
      } else {
        moveMenu(menu.pos);
      }
    }

    menu.endUpdate(true);
  }
}
