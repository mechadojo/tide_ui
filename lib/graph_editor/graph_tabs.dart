import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/menu_item.dart';
import 'package:tide_ui/graph_editor/icons/icon_painter.dart';

import 'data/canvas_tab.dart';
import 'data/canvas_tabs_state.dart';

class GraphTabs extends StatelessWidget {
  static double DefaultTabHeight = 50;

  GraphTabs({Key key}) : super(key: key);

  Offset globalToLocal(BuildContext context, Offset pt) {
    try {
      RenderBox rb = context.findRenderObject();

      return rb.globalToLocal(pt);
    } catch (ex) {
      print(ex.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CanvasTabsState>(context, listen: true);
    final editor = Provider.of<GraphEditorState>(context, listen: false);

    //print("Rebuild Tabs");
    return GestureDetector(
      onTapDown: (evt) {
        var pt = globalToLocal(context, evt.globalPosition);
        editor.mouseHandler.onMouseMoveTabs(null, pt);
        editor.mouseHandler.onMouseDownTabs(null, pt);
      },
      onTapUp: (evt) {
        var pt = globalToLocal(context, evt.globalPosition);
        editor.mouseHandler.onMouseUpTabs(null, pt);
        editor.mouseHandler.onMouseOutTabs();
      },
      onHorizontalDragEnd: (evt) {
        state.controller.scroll(evt.primaryVelocity);
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: CanvasTabsPainter(state),
          child: Container(),
        ),
      ),
    );
  }
}

class CanvasTabsPainter extends CustomPainter {
  CanvasTabsState state;

  String get selected => state.selected;
  List<CanvasTab> get tabs => state.tabs;
  List<MenuItem> get menu => state.menu;

  final width = 193.0;
  final height = 35.0;
  final padding = 2.0;
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

  CanvasTabsPainter(this.state);

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

    canvas.drawPath(
        path,
        selected
            ? selectedTabFill
            : tab.hovered ? hoveredTabFill : unselectedTabFill);
    canvas.drawPath(
        path, selected ? selectedOutlineStroke : unselectOutlineStroke);

    if (tab.icon != null) {
      iconsTab.paint(
          canvas, tab.icon, Offset(cx - (width / 2) + 20, cy), tabIconSize);
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

  void drawTabs(double offset, Canvas canvas, Size size) {
    // Recalculate tab starting position of each tab
    for (var tab in tabs) {
      tab.pos = Offset(offset, 0);
      tab.icon = tab.icon ?? IconPainter.random;
      offset += width;
    }

    // Render tabs right to left with the selected tab drawn last
    CanvasTab top;
    var overlapped = <CanvasTab>[];

    for (var tab in tabs.reversed) {
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
    //canvas.drawRect(item.hitbox, selectedOutlineStroke);

    return item.pos.translate(sz.width + spacing, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPaint(backFill);

    canvas.drawRect(
        Rect.fromLTRB(0, size.height - padding, size.width, size.height),
        paddingFill);

    var btnPos = Offset(spacing / 2, size.height - padding - height / 2);

    for (var item in menu) {
      if (item.name == "tab-new") continue;

      item.pos = btnPos;
      drawButton(canvas, item, btnIconSize);
      btnPos = btnPos.translate(spacing, 0);
    }

    drawTabs(btnPos.dx, canvas, size);

    if (tabs.isNotEmpty) {
      btnPos = Offset(tabs.last.pos.dx + width + spacing, btnPos.dy);
    } else {
      var lineY = size.height - padding;
      canvas.drawLine(
          Offset(0, lineY), Offset(size.width, lineY), selectedOutlineStroke);
    }

    var item = menu.firstWhere((x) => x.name == "tab-new");
    if (item != null) {
      item.pos = btnPos;
      drawButton(canvas, item, btnIconSize);
    }
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
