import 'package:flutter_web/material.dart';
import 'package:flutter_web_ui/ui.dart' as ui show Gradient;
import 'package:tide_ui/graph_editor/data/canvas_tab.dart';
import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';

import 'package:tide_ui/graph_editor/data/graph_library_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/fonts/SourceSansPro.dart';
import 'package:tide_ui/graph_editor/icons/icon_painter.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

class CanvasTabsPainter extends CustomPainter {
  CanvasTabsState state;

  String get selected => state.selected;
  List<CanvasTab> get tabs => state.tabs;
  List<MenuItem> get menu => state.menu;

  final width = 175.0;
  final height = 35.0;
  final padding = .75;
  final spacing = 25.0;
  final btnIconSize = 14.0;
  final tabIconSize = 18.0;

  final backFill = Paint()
    ..color = Color(0xffeeeeee)
    ..style = PaintingStyle.fill;

  final selectedTabFill = Paint()
    ..color = Color(0xfffffff0)
    ..style = PaintingStyle.fill;

  final unselectedTabFill = Paint()
    ..color = Color(0xffcbcbcb)
    ..style = PaintingStyle.fill;

  final selectedLibraryTabFill = Paint()
    ..shader = ui.Gradient.linear(
        Offset(0, 15), Offset(0, 50), [Colors.blue[100], Color(0xfffffff0)]);

  final unselectedLibraryTabFill = Paint()
    ..shader = ui.Gradient.linear(
        Offset(0, 15), Offset(0, 50), [Colors.blue[100], Color(0xffcbcbcb)]);

  final paddingFill = Paint()..color = Color(0xfffffff0);

  final selectedOutlineStroke = Paint()
    ..color = Color(0xff888888)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final unselectOutlineStroke = Paint()
    ..color = Color(0xcc888888)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final hoveredTabFill = Paint()..color = Colors.cyan[50];

  final labelTextSyle = TextStyle(
    color: Colors.grey[700],
    fontSize: 15,
    fontFamily: "Source Sans Pro",
  );

  final iconsHoverAccent = IconPainter(color: Colors.red);
  final iconsHover = IconPainter(color: Colors.black);
  final iconsTab = IconPainter(color: Colors.grey[600]);
  final iconsDisabled = IconPainter(color: Colors.grey[400]);
  final iconsAlerted = IconPainter(color: Colors.blueAccent[700]);
  final iconsTabPaint = Paint()..color = Colors.grey[600];

  final font = SourceSansProFont;

  CanvasTabsPainter(this.state);

  Paint getTabBackFill(CanvasTab tab, bool selected) {
    if (selected) {
      return tab.graph is GraphLibraryState
          ? selectedLibraryTabFill
          : selectedTabFill;
    }

    if (tab.hovered) return hoveredTabFill;

    return tab.graph is GraphLibraryState
        ? unselectedLibraryTabFill
        : unselectedTabFill;
  }

  void drawTab(CanvasTab tab, Canvas canvas, Size size) {
    //print("Tab: ${tab.title} [${tab.pos}]");

    var y0 = size.height - height - padding;
    var y1 = size.height - padding;

    var slope = 5;
    var curve = 12;

    var cx = tab.pos.dx + width / 2;
    var cy = (y0 + y1) / 2;

    var x0 = cx - width / 2;
    var x0_a = x0 - (slope + curve);
    var x0_b = x0 - slope;
    var x0_c = x0 + slope;
    var x0_d = x0 + (slope + curve);

    var x1 = cx + width / 2;

    var x1_a = x1 - (slope + curve);
    var x1_b = x1 - slope;
    var x1_c = x1 + slope;
    var x1_d = x1 + (slope + curve);

    var x2 = x0_a;
    var x3 = x1_d;

    var y2 = y1 + 1.0;

    var selected = tab.name == this.selected;
    if (selected) {
      x2 = 0;
      x3 = size.width;
    }

    var path = Path()
      ..moveTo(x2, y2)
      ..lineTo(x2, y1)
      ..lineTo(x0_a, y1)
      ..quadraticBezierTo(x0_b, y1, x0, cy)
      ..quadraticBezierTo(x0_c, y0, x0_d, y0)
      ..lineTo(x1_a, y0)
      ..quadraticBezierTo(x1_b, y0, x1, cy)
      ..quadraticBezierTo(x1_c, y1, x1_d, y1)
      ..lineTo(x3, y1)
      ..lineTo(x3, y2);

    canvas.drawPath(path, getTabBackFill(tab, selected));

    canvas.drawPath(
        path, selected ? selectedOutlineStroke : unselectOutlineStroke);

    if (tab.icon != null) {
      var iconPos = Offset(cx - (width / 2) + 20, cy);

      VectorIcons.paint(canvas, tab.icon, iconPos, tabIconSize,
          fill: iconsTabPaint);
    }

    tab.closeBtn.pos = Offset(cx + (width / 2) - 20, cy);
    tab.closeBtn.icon = tab.closeBtn.hovered ? "solidTimesCircle" : "times";
    tab.closeBtn.name = "tab-close";
    tab.closeBtn.group = "tab:${tab.name}";

    drawButton(canvas, tab.closeBtn, tab.closeBtn.hovered ? 16 : 12);

    tab.hitbox = Rect.fromCenter(
        center: Offset(cx, cy), width: width + 0.0, height: height + 0.0);

    var labelRect = Rect.fromCenter(
        center: Offset(cx + 3, cy), width: width - 70.0, height: height - 10.0);

    if (tab != null) {
      var textSpan = TextSpan(
        text: tab.title == null ? "Untitled [${tab.name}]" : tab.title,
        style: labelTextSyle,
      );

      var labelPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        ellipsis: "...",
      );

      labelPainter.layout(
        minWidth: 0,
        maxWidth: labelRect.width,
      );

      var labelPos = Offset(
          labelRect.left, labelRect.center.dy - labelPainter.size.height / 2);
      labelPainter.paint(canvas, labelPos);

      //canvas.drawRect(labelRect, unselectOutlineStroke);
      //canvas.drawRect(tab.hitbox, unselectOutlineStroke);
    }
  }

  int drawTabs(double offset, Canvas canvas, Size size) {
    var tls = [...tabs];
    if (tls.isEmpty) return 0;

    var max_width = size.width - (offset + btnIconSize * 3 + spacing * 2);

    var max_tabs = (max_width / width).floor();
    if (max_tabs == 0) max_tabs = 1; // always show at least one tab

    if (tls.length >= max_tabs) {
      // trim displayed tabs
      var idx = tls.indexWhere((x) => x.name == selected);
      if (idx >= max_tabs) {
        tls = [...tls.skip((idx + 1) - max_tabs)];
      }
      tls = [...tls.take(max_tabs)];
    }

    // Recalculate tab starting position of each tab
    for (var tab in tls) {
      tab.pos = Offset(offset, 0);
      //tab.icon = tab.icon ?? IconPainter.random;
      offset += width;
    }

    // Render tabs right to left with the selected tab drawn last
    CanvasTab top;
    var overlapped = <CanvasTab>[];

    for (var tab in tls.reversed) {
      if (tab.name == selected) {
        top = tab;
        continue;
      }
      overlapped.add(tab);
    }

    for (var tab in overlapped) {
      drawTab(tab, canvas, size);
    }

    if (top != null) drawTab(top, canvas, size);

    return tls.length;
  }

  Offset drawButton(Canvas canvas, MenuItem item, double size) {
    var painter = getIconPainter(item);
    if (!item.disabled && item.hovered && item.name != "tab-close") {
      size = size * 1.25;
    }

    var icon = (item.hovered ? item.iconAlt : item.icon) ?? item.icon;

    var sz = painter.sizeOf(icon, size);
    painter.paint(canvas, icon, item.pos, size);
    item.hitbox = Rect.fromCenter(
        center: item.pos, width: sz.width + 10, height: sz.height + 5);
    item.hitbox.inflate(10);

    return item.pos.translate(sz.width + spacing, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    //print("Painting Tabs");
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPaint(backFill);

    canvas.drawRect(
        Rect.fromLTRB(0, size.height - padding, size.width, size.height),
        paddingFill);

    var btnPos = Offset(5, size.height - padding - height / 2);

    if (state.version != null && state.version.isNotEmpty) {
      var sz = font.limits("V${state.version}", btnPos, 8,
          style: "Bold", alignment: Alignment.centerLeft);

      font.paint(canvas, "V${state.version}", btnPos, 8,
          fill: Paint()..color = Colors.black.withAlpha(100),
          style: "Bold",
          alignment: Alignment.centerLeft);
      btnPos = btnPos.translate(sz.width + 12, 0);
    }

    for (var item in menu) {
      if (item.name == "tab-new" ||
          item.name == "tab-next" ||
          item.name == "tab-prev") continue;

      item.pos = btnPos;
      drawButton(canvas, item, btnIconSize);
      btnPos = btnPos.translate(spacing, 0);
    }

    var tabs_drawn = drawTabs(btnPos.dx, canvas, size);

    if (tabs.isNotEmpty) {
      btnPos = Offset(btnPos.dx + tabs_drawn * width + spacing, btnPos.dy);
    } else {
      var lineY = size.height - padding;
      canvas.drawLine(
          Offset(0, lineY), Offset(size.width, lineY), selectedOutlineStroke);
    }

    if (tabs_drawn < tabs.length) {
      var btns = menu
          .where((x) => x.name == "tab-next" || x.name == "tab-prev")
          .toList();
      for (var btn in btns) {
        btn.pos = btnPos;
        drawButton(canvas, btn, btnIconSize);
        btnPos = btnPos.translate(spacing, 0);
      }
    }

    var item = menu.firstWhere((x) => x.name == "tab-new");
    if (item != null) {
      item.pos = btnPos;
      drawButton(canvas, item, btnIconSize);
    }

    state.requirePaint = false;
  }

  IconPainter getIconPainter(MenuItem item) {
    if (item.disabled) return iconsDisabled;
    if (item.alerted) return iconsAlerted;

    if (item.hovered) {
      return item.name == "tab-close" ? iconsHoverAccent : iconsHover;
    }

    return iconsTab;
  }

  @override
  bool shouldRepaint(CanvasTabsPainter oldDelegate) {
    return this != oldDelegate;
  }
}
