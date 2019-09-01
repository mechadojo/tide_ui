import 'package:flutter_web/material.dart';
import 'package:flutter_web_ui/ui.dart' as ui show Gradient;
import 'package:tide_ui/graph_editor/controller/library_controller.dart';

import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/library_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

class LibraryPainter {
  Path createTabPath(Offset pos, Rect rect) {
    var result = Path();

    var top = rect.bottom - Graph.LibraryTabTop;
    var bottom = rect.bottom - Graph.LibraryTabBottom;
    var cy = (top + bottom) / 2;

    var width = Graph.LibraryFirstTabWidth;
    var slope = width / 4;

    var p1x = pos.dx - (width / 2);
    var p2x = p1x + slope / 2;
    var p3x = p2x + slope / 2;
    var p4x = p1x + width - slope;
    var p5x = p4x + slope / 2;
    var p6x = p5x + slope / 2;
    var curve = slope / 4;

    result.moveTo(rect.left, top);
    result.lineTo(p1x, top);

    result.quadraticBezierTo(p1x + curve, top, p2x, cy);
    result.quadraticBezierTo(p3x - curve, bottom, p3x, bottom);

    result.lineTo(p4x, bottom);

    result.quadraticBezierTo(p4x + curve, bottom, p5x, cy);
    result.quadraticBezierTo(p6x - curve, top, p6x, top);

    result.lineTo(rect.right, top);

    return result;
  }

  void paint(Canvas canvas, Size size, LibraryState library) {
    var width = library.controller.width;
    var rect = Rect.fromLTWH(size.width - width, 0, width, size.height);

    var shadow = Paint()
      ..shader = ui.Gradient.linear(
          Offset(rect.left - Graph.LibraryShadowWidth, 0),
          Offset(rect.left, 0),
          [Graph.LibraryShadowStart, Graph.LibraryShadowEnd]);

    canvas.drawRect(
        Rect.fromLTWH(rect.left - Graph.LibraryShadowWidth, rect.top,
            Graph.LibraryShadowWidth, rect.height),
        shadow);

    canvas.drawRect(rect, Graph.LibraryColor);

    canvas.drawLine(rect.topLeft, rect.bottomLeft, Graph.LibraryEdgeColor);
    drawExpandIcon(canvas, library, rect);
    drawTopIcons(canvas, library, rect);
    switch (library.mode) {
      case LibraryDisplayMode.toolbox:
        drawCollapsed(canvas, library, rect, library.toolbox);
        break;
      case LibraryDisplayMode.collapsed:
        drawCollapsed(canvas, library, rect, library.behaviors);
        break;
      case LibraryDisplayMode.expanded:
        drawExpanded(canvas, library, rect);
        break;
      case LibraryDisplayMode.detailed:
        drawDetailed(canvas, library, rect);
        break;
      case LibraryDisplayMode.tabs:
        drawTabs(canvas, library, rect);
        switch (library.currentTab) {
          case LibraryTab.imports:
            drawImportsTab(canvas, library, rect);
            break;
          case LibraryTab.files:
            drawFilesTab(canvas, library, rect);
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }

    if (library.controller.isDragging) {
      var item = library.controller.dragging;
      if (item.pos.dx > rect.left) {
        VectorIcons.paint(
            canvas, item.icon, item.pos, Graph.LibraryDragIconSize,
            fill: Graph.LibraryDragIconColor);

        if (library.controller.editor.isTouchMode) {
          Graph.font.paint(canvas, item.name,
              item.pos.translate(0, -(Graph.LibraryDragIconSize / 2 + 5)), 10,
              style: "Bold",
              fill: Graph.LibraryDragIconColor,
              alignment: Alignment.bottomCenter);
        } else {
          Graph.font.paint(canvas, item.name,
              item.pos.translate(0, Graph.LibraryDragIconSize / 2 + 5), 10,
              style: "Bold",
              fill: Graph.LibraryDragIconColor,
              alignment: Alignment.topCenter);
        }
      }
    }
  }

  double drawTabsButton(Canvas canvas, MenuItem btn, double cx, double cy) {
    var size = Graph.LibraryFileIconSize;
    if (btn.hovered) size *= 1.25;

    var fill = btn.hovered
        ? Graph.LibraryItemIconHoverColor
        : Graph.LibraryItemIconColor;

    btn.size = Size(size, size);
    btn.moveTo(cx, cy, update: true);

    VectorIcons.paint(canvas, btn.icon, btn.pos, size, fill: fill);
    cx += Graph.LibraryFileIconSize + Graph.LibraryFileIconSpacing;
    return cx;
  }

  double drawImportsTabItem(
      Canvas canvas, MenuItemSet item, Offset pos, Rect rect) {
    var count = item.items.length;

    var left = rect.right -
        (Graph.LibraryFileIconSize + Graph.LibraryFileIconSpacing) * count;

    Graph.font.paint(canvas, item.name, pos, Graph.LibraryFileNameSize,
        width: left - pos.dx,
        fill: Graph.LibraryFileColor,
        alignment: Alignment.centerLeft);

    var cx = left + Graph.LibraryFileIconSize / 2;

    for (var btn in item.items) {
      cx = drawTabsButton(canvas, btn, cx, pos.dy);
    }
    return pos.dy + Graph.LibraryFileNameSize + Graph.LibraryFileNameSpacing;
  }

  void drawImportsTab(Canvas canvas, LibraryState library, Rect rect) {
    var cy = rect.top + Graph.LibraryGroupTopPadding + 5;
    var cx = rect.left + 10;

    Graph.font.paint(canvas, "Imports", Offset(cx, cy), Graph.LibraryTitleSize,
        style: "Bold", fill: Graph.LibraryTitleColor);

    var left = rect.right -
        (Graph.LibraryFileIconSize + Graph.LibraryFileIconSpacing) *
            library.importButtons.length;

    var dx = left;
    var dy = cy - Graph.LibraryFileIconSize / 2;
    for (var btn in library.importButtons) {
      dx = drawTabsButton(canvas, btn, dx, dy);
    }

    cy += Graph.LibraryTitleSize + Graph.LibraryFileNameSize;

    for (var item in library.imports) {
      cy = drawImportsTabItem(canvas, item, Offset(cx, cy), rect);
    }
  }

  double drawFilesTabItem(
      Canvas canvas, MenuItemSet item, Offset pos, Rect rect) {
    var count = item.items.length;

    var left = rect.right -
        (Graph.LibraryFileIconSize + Graph.LibraryFileIconSpacing) * count;

    Graph.font.paint(canvas, item.name, pos, Graph.LibraryFileNameSize,
        width: left - pos.dx,
        fill: Graph.LibraryFileColor,
        alignment: Alignment.centerLeft);

    var cx = left + Graph.LibraryFileIconSize / 2;

    for (var btn in item.items) {
      var size = Graph.LibraryFileIconSize;
      if (btn.hovered) size *= 1.25;

      var fill = btn.hovered
          ? Graph.LibraryItemIconHoverColor
          : Graph.LibraryItemIconColor;

      btn.size = Size(size, size);
      btn.moveTo(cx, pos.dy, update: true);

      VectorIcons.paint(canvas, btn.icon, btn.pos, size, fill: fill);
      cx += Graph.LibraryFileIconSize + Graph.LibraryFileIconSpacing;
    }
    return pos.dy + Graph.LibraryFileNameSize + Graph.LibraryFileNameSpacing;
  }

  void drawFilesTab(Canvas canvas, LibraryState library, Rect rect) {
    var cy = rect.top + Graph.LibraryGroupTopPadding + 5;
    var cx = rect.left + 10;

    Graph.font.paint(canvas, library.controller.filesTitle, Offset(cx, cy),
        Graph.LibraryTitleSize,
        style: "Bold", fill: Graph.LibraryTitleColor);

    cy += Graph.LibraryTitleSize + Graph.LibraryFileNameSize;

    for (var item in library.files) {
      cy = drawFilesTabItem(canvas, item, Offset(cx, cy), rect);
    }
  }

  double drawSelectedTab(Canvas canvas, MenuItem item, Offset pos, Rect rect) {
    var fill = Graph.LibraryItemIconActiveColor;

    var back = Rect.fromLTRB(
        rect.left, rect.bottom - Graph.LibraryTabTop, rect.right, rect.bottom);
    canvas.drawRect(back, Graph.LibraryTabsBackFill);

    var path = createTabPath(pos, rect);
    canvas.drawPath(path, Graph.CanvasColor);
    canvas.drawPath(path, Graph.LibraryTabsOutline);

    var size = Graph.LibraryTabIconSize;

    item.size = Size(Graph.LibraryFirstTabWidth,
        Graph.LibraryTabBottom - Graph.LibraryTabTop);
    item.moveTo(pos.dx, pos.dy - 2, update: true);

    VectorIcons.paint(canvas, item.icon, item.pos, size, fill: fill);

    return pos.dx +
        Graph.LibraryFirstTabWidth / 2 +
        Graph.LibraryTabPadding +
        Graph.LibraryFirstTabPadding;
  }

  void drawTabs(Canvas canvas, LibraryState library, Rect rect) {
    var cx = rect.left + Graph.LibraryFirstTabPos;
    var cy = rect.bottom - 10 - Graph.LibraryTabIconSize / 2;

    var first = library.tabs.firstWhere((x) => x.selected, orElse: () => null);
    if (first == null) first = library.tabs.isEmpty ? null : library.tabs.first;

    if (first != null) {
      cx += Graph.LibraryFirstTabWidth / 2;
      cx = drawSelectedTab(canvas, first, Offset(cx, cy), rect);
      cy = rect.bottom - Graph.LibraryTabTop / 2;
    }

    for (var tab in library.tabs) {
      if (tab.selected) continue;
      var fill = tab.hovered
          ? Graph.LibraryItemIconHoverColor
          : Graph.LibraryItemIconColor;

      var size = Graph.LibraryTabIconSize;
      if (tab.hovered) size *= 1.25;

      tab.size = Size(Graph.LibraryTabIconSize, Graph.LibraryTabIconSize);
      tab.moveTo(cx, cy, update: true);

      VectorIcons.paint(canvas, tab.icon, Offset(cx, cy), size, fill: fill);
      cx += Graph.LibraryTabIconSize + Graph.LibraryTabPadding;
    }
  }

  void drawCollapsed(
      Canvas canvas, LibraryState library, Rect rect, List<LibraryItem> items) {
    var cx = rect.center.dx;
    var cy =
        rect.top + Graph.LibraryTopIconPadding * 2 + Graph.LibraryTopIconSize;

    var spacing = Graph.LibraryCollapsedItemSpacing;

    spacing = (rect.height - cy) / (items.length);

    if (spacing < Graph.LibraryCollapsedItemSpacing) {
      spacing = Graph.LibraryCollapsedItemSpacing;
    }

    if (spacing > Graph.LibraryCollapsedItemMaxSpacing) {
      spacing = Graph.LibraryCollapsedItemMaxSpacing;
    }

    cy += spacing / 2;
    int hotkey = 0;
    for (var item in items) {
      hotkey = (hotkey + 1) % 10;
      var icon = item.hoveredIcon;
      var fill = item.hovered
          ? Graph.LibraryItemIconHoverColor
          : Graph.LibraryItemIconColor;

      bool defaultShowLabel = library.controller.editor.isTouchMode ||
          library.mode == LibraryDisplayMode.collapsed;

      bool showLabel = item.hovered || defaultShowLabel;
      bool showHotkey = !library.controller.editor.isTouchMode &&
          !item.hovered &&
          library.mode == LibraryDisplayMode.toolbox;

      var factor = item.hovered ? .875 : .5;
      if (library.controller.mouseMode != LibraryMouseMode.none) {
        icon = item.icon;
        fill = Graph.LibraryItemIconColor;
        factor = .5;
        showLabel = defaultShowLabel;
        showHotkey = false;
      }

      if (item.alerted) {
        fill = Graph.LibraryItemIconAlertColor;
      }

      var size = spacing * factor;

      if (size < Graph.LibraryCollapsedItemSize) {
        size = Graph.LibraryCollapsedItemSize;
      }

      if (size > rect.width * .9) {
        size = rect.width * .9;
      }

      item.resizeTo(size, size);
      item.moveTo(cx, cy, update: true);
      var iconSize = size * .75;
      VectorIcons.paint(canvas, icon, item.pos, iconSize, fill: fill);

      if (showLabel) {
        var labelPos = item.pos.translate(0, iconSize / 2 + 4);
        var labelWidth = rect.width - 8;

        Graph.font.paint(canvas, item.name, labelPos, 8,
            fill: fill, width: labelWidth, alignment: Alignment.topCenter);
      }

      if (showHotkey) {
        var labelPos = Offset(rect.left + 10, item.pos.dy - iconSize / 2 - 4);
        var labelRect = Graph.font.limits(hotkey.toString(), labelPos, 8,
            style: "Bold", alignment: Alignment.centerLeft);

        var rrect = RRect.fromRectXY(labelRect.inflate(2), 2, 2);

        if (item.isDefault) {
          VectorIcons.paint(canvas, "star-solid", rrect.center, 12, fill: fill);
        } else {
          canvas.drawRRect(rrect, fill);
          Graph.font.paint(canvas, hotkey.toString(), labelPos, 8,
              fill: Graph.whitePaint,
              style: "Bold",
              alignment: Alignment.centerLeft);
        }
      }

      cy += spacing;
    }
  }

  void drawTopIcons(Canvas canvas, LibraryState library, Rect rect) {
    var cy =
        rect.top + Graph.LibraryTopIconSize / 2 + Graph.LibraryTopIconPadding;
    var cx = rect.center.dx;

    cx -= ((library.menu.length - 1) * Graph.LibraryTopIconSpacing) / 2;

    for (var item in library.menu) {
      var pt = Offset(cx, cy);
      cx += Graph.LibraryTopIconSpacing;

      var sz = Graph.LibraryTopIconSize * ((item.hovered) ? 1.25 : 1.0);

      var paint = item.selected
          ? Graph.LibraryTopIconSelectedColor
          : item.hovered
              ? Graph.LibraryTopIconHoverColor
              : Graph.LibraryTopIconColor;

      var icon = ((item.hovered || item.selected) && item.hasIconAlt)
          ? item.iconAlt
          : item.icon;

      var spacing = Graph.LibraryTopIconSpacing - 2;

      item.hitbox =
          Rect.fromCenter(center: pt, width: spacing, height: spacing);

      VectorIcons.paint(canvas, icon, pt, sz, fill: paint);
    }
  }

  void drawExpanded(Canvas canvas, LibraryState library, Rect rect) {
    drawDetailed(canvas, library, rect);
  }

  void drawExpandoBtn(Canvas canvas, LibraryItem item, Offset pos, Rect rect) {
    var btn = item.isCollapsed ? item.expandButton : item.collapseButton;

    btn.size = Size(16, 16);
    btn.moveTo(pos.dx + 5, pos.dy - 5, update: true);
    var hb = btn.hitbox;
    btn.hitbox =
        Rect.fromLTRB(hb.left, hb.top - 2, rect.right - 30, hb.bottom + 2);

    var fill = btn.hovered
        ? Graph.LibraryItemIconHoverColor
        : Graph.LibraryItemIconColor;

    VectorIcons.paint(canvas, btn.icon, btn.pos, 16, fill: fill);
  }

  double layoutDetailed(Canvas canvas, double dy, LibraryState library,
      List<LibraryItem> items, Rect rect) {
    for (var item in items) {
      dy = drawDetailedItem(canvas, dy, library, item, rect);
    }
    return dy;
  }

  double layoutGrid(Canvas canvas, double dy, LibraryState library,
      List<LibraryItem> items, Rect rect) {
    int idx = 0;
    var spacing =
        (rect.width - Graph.LibraryGridPadding * 2) / Graph.LibraryGridColumns;

    double left = rect.left + Graph.LibraryGridPadding + spacing / 2;
    double dx = left;
    dy += 10;

    for (var item in items) {
      item.editButton.size = Size.zero;

      var fill = item.hovered
          ? Graph.LibraryItemIconHoverColor
          : Graph.LibraryItemIconColor;

      item.size = Size(Graph.LibraryGridIconSize, Graph.LibraryGridIconSize);
      item.moveTo(dx, dy, update: true);

      var sz = item.size.width;
      if (item.hovered) {
        sz *= 1.25;
      }

      VectorIcons.paint(canvas, item.icon, item.pos, sz, fill: fill);

      idx++;
      if ((idx % Graph.LibraryGridColumns) == 0) {
        dx = left;
        dy += Graph.LibraryGridIconSize + Graph.LibraryGridPadding;
      } else {
        dx += spacing;
      }
    }

    if ((idx % Graph.LibraryGridColumns) != 0) {
      dy += Graph.LibraryGridIconSize / 2 + Graph.LibraryGridPadding;
    }

    return dy;
  }

  void drawDetailed(Canvas canvas, LibraryState library, Rect rect) {
    var cy = rect.top + Graph.LibraryGroupTopPadding;

    var opmodes = library.opmodes;
    var behaviors = library.behaviors;

    var cx = rect.left + 10;
    var left = cx + 15;

    if (opmodes.isNotEmpty) {
      drawExpandoBtn(canvas, library.opmodeGroup, Offset(cx, cy), rect);
      var fill = library.opmodeGroup.expandoButton.hovered
          ? Graph.blackPaint
          : Graph.LibraryGroupLabelColor;

      Graph.font.paint(
          canvas, "OpModes", Offset(left, cy), Graph.LibraryGroupLabelSize,
          style: "Bold", fill: fill);

      var auto = opmodes.where((x) => x.graph.opModeType == "Auto").toList();
      var teleop =
          opmodes.where((x) => x.graph.opModeType == "Teleop").toList();

      cy += Graph.LibraryGroupLabelSize + Graph.LibraryGroupItemPadding;
      if (library.opmodeGroup.isExpanded) {
        if (auto.isNotEmpty) {
          Graph.font.paint(canvas, "Autonomous", Offset(cx, cy),
              Graph.LibrarySubGroupLabelSize,
              fill: Graph.LibraryGroupLabelColor);

          cy += Graph.LibrarySubGroupLabelSize + 2;

          cy = library.mode == LibraryDisplayMode.detailed
              ? layoutDetailed(canvas, cy, library, auto, rect)
              : layoutGrid(canvas, cy, library, auto, rect);

          cy += Graph.LibraryGroupPadding;
        }

        if (teleop.isNotEmpty) {
          Graph.font.paint(
              canvas, "Teleop", Offset(cx, cy), Graph.LibrarySubGroupLabelSize,
              fill: Graph.LibraryGroupLabelColor);

          cy += Graph.LibrarySubGroupLabelSize + 2;

          cy = library.mode == LibraryDisplayMode.detailed
              ? layoutDetailed(canvas, cy, library, teleop, rect)
              : layoutGrid(canvas, cy, library, teleop, rect);

          cy += Graph.LibraryGroupPadding;
        }
      } else {
        cy += Graph.LibraryGroupCollapsedPadding;
      }
    }

    if (behaviors.isNotEmpty) {
      drawExpandoBtn(canvas, library.behaviorGroup, Offset(cx, cy), rect);

      var fill = library.behaviorGroup.expandoButton.hovered
          ? Graph.blackPaint
          : Graph.LibraryGroupLabelColor;

      Graph.font.paint(
          canvas, "Behaviors", Offset(left, cy), Graph.LibraryGroupLabelSize,
          style: "Bold", fill: fill);

      cy += Graph.LibraryGroupLabelSize + Graph.LibraryGroupItemPadding;

      if (library.behaviorGroup.isExpanded) {
        cy = library.mode == LibraryDisplayMode.detailed
            ? layoutDetailed(canvas, cy, library, behaviors, rect)
            : layoutGrid(canvas, cy, library, behaviors, rect);

        cy += Graph.LibraryGroupPadding;
      } else {
        cy += Graph.LibraryGroupCollapsedPadding;
      }
    }

    for (var group in library.groups) {
      drawExpandoBtn(canvas, group, Offset(cx, cy), rect);
      var fill = group.expandoButton.hovered
          ? Graph.blackPaint
          : Graph.LibraryGroupLabelColor;

      Graph.font.paint(
          canvas, group.name, Offset(left, cy), Graph.LibraryGroupLabelSize,
          style: "Bold", fill: fill);

      if (library.controller.allowEditGroup(group)) {
        group.openButton.size =
            Size(Graph.LibraryDetailedIconSize, Graph.LibraryDetailedIconSize);
        group.openButton.moveTo(
            rect.right - 10 - Graph.LibraryDetailedIconSize / 2 - 1, cy - 5,
            update: true);
        drawDetailedItemButton(canvas, group.openButton);
      } else {
        var lib = group.graph as GraphLibraryState;
        if (lib != null && lib.source != null) {
          var name = lib.source.replaceAll(".chart", "");
          Graph.font.paint(canvas, name, Offset(rect.right - 10, cy), 8,
              style: "RegularItalic",
              fill: Graph.LibraryGroupLabelColor,
              alignment: Alignment.bottomRight);
        }

        group.openButton.resizeTo(0, 0);
      }

      cy += Graph.LibraryGroupLabelSize + Graph.LibraryGroupItemPadding;
      if (group.isExpanded) {
        bool first = true;
        for (var item in group.items) {
          if (!first) {
            cy += Graph.LibrarySubGroupLabelSize;
          }

          first = false;

          if (item.name.isNotEmpty && group.items.length > 1) {
            Graph.font.paint(canvas, item.name, Offset(cx, cy),
                Graph.LibrarySubGroupLabelSize,
                fill: Graph.LibraryGroupLabelColor);
            cy += Graph.LibrarySubGroupLabelSize + 2;
          }

          cy = library.mode == LibraryDisplayMode.detailed
              ? layoutDetailed(canvas, cy, library, item.items, rect)
              : layoutGrid(canvas, cy, library, item.items, rect);
        }

        cy += Graph.LibraryGroupPadding;
      } else {
        cy += Graph.LibraryGroupCollapsedPadding;
      }

      // cy += Graph.LibraryGroupPadding;
    }
  }

  void drawDetailedItemButton(Canvas canvas, MenuItem button) {
    var fill = button.hovered
        ? Graph.LibraryItemIconHoverColor
        : Graph.LibraryItemIconColor;
    var size = Graph.LibraryDetailedIconSize;

    var icon = button.hovered
        ? (button.hasIconAlt ? button.iconAlt : button.icon)
        : button.icon;

    if (button.hovered) size *= 1.25;

    VectorIcons.paint(canvas, icon, button.pos, size, fill: fill);
  }

  double drawDetailedItem(Canvas canvas, double dy, LibraryState library,
      LibraryItem item, Rect rect) {
    var cy = dy + Graph.LibraryGroupIconSize / 2;
    var cx = rect.left + 10 + Graph.LibraryGroupIconSize / 2;

    var fill = item.hovered
        ? Graph.LibraryItemIconHoverColor
        : Graph.LibraryItemIconColor;

    var size = Graph.LibraryGroupIconSize;
    if (item.hovered) size *= 1.25;

    VectorIcons.paint(canvas, item.icon, Offset(cx, cy), size, fill: fill);

    cx += Graph.LibraryGroupIconSize / 2 + 10;
    var left = rect.left + 10;
    var right = rect.right -
        (Graph.LibraryDetailedIconSize + Graph.LibraryDetailedIconSpacing * 2);

    var hh = Graph.LibraryDetailedIconSize / 2;
    item.hitbox = Rect.fromLTRB(left, cy - hh, rect.right - 10, cy + hh);

    Graph.font.paint(
        canvas, item.name, Offset(cx, cy), Graph.LibraryGroupLabelSize,
        fill: fill,
        width: item.hitbox.right - cx,
        alignment: Alignment.centerLeft);

    cx = right +
        Graph.LibraryDetailedIconSize / 2 +
        Graph.LibraryDetailedIconSpacing;

    if (item.graph != null) {
      item.editButton.size =
          Size(Graph.LibraryDetailedIconSize, Graph.LibraryDetailedIconSize);
      item.editButton.moveTo(cx, cy, update: true);
      drawDetailedItemButton(canvas, item.editButton);
      cx += Graph.LibraryDetailedIconSize + Graph.LibraryDetailedIconSpacing;
    }

    return dy + Graph.LibraryGroupIconSize + Graph.LibraryGroupItemPadding * 2;
  }

  void drawExpandIcon(Canvas canvas, LibraryState library, Rect rect) {
    var sz = Graph.LibraryExpandSize;

    var cx = rect.left - sz - Graph.LibraryExpandIconPadding;
    var cy = rect.top + sz + Graph.LibraryExpandIconPadding;
    var pt = Offset(cx, cy);

    var radial = Paint()..color = Color(0xff333333).withAlpha(20);
    canvas.drawCircle(pt, sz + 3, radial);
    canvas.drawCircle(pt, sz, Graph.LibraryColor);
    canvas.drawCircle(pt, sz, Graph.LibraryExpandIconEdgeColor);
    VectorIcons.paint(canvas, library.isHidden ? "angle-left" : "angle-right",
        pt, Graph.LibraryExpandIconSize,
        fill: Graph.LibraryExpandIconColor);

    library.hitbox = Rect.fromCenter(center: pt, width: sz * 2, height: sz * 2);
  }
}
