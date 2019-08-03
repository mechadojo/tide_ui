import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import 'data/canvas_tab.dart';
import 'data/canvas_tabs_state.dart';

class GraphTabs extends StatelessWidget {
  const GraphTabs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasTabsState>(builder: (context, state, _) {
      return CustomPaint(
        painter: CanvasTabsPainter(
          selected: state.selected,
          tabs: state.tabs,
        ),
        child: Container(),
      );
    });
  }
}

class CanvasTabsPainter extends CustomPainter {
  String selected;
  List<CanvasTab> tabs;

  final int width = 200;
  final int height = 35;
  final int padding = 10;
  final int spacing = 30;

  final backFill = Paint()..color = Colors.grey[300];
  final selectedTabFill = Paint()..color = Color(0xfffffff0);
  final unselectedTabFill = Paint()..color = Colors.grey[500];
  final hoverTabFill = Paint()..color = Colors.blueAccent;

  CanvasTabsPainter({this.selected, this.tabs}) {
    if (tabs == null) {
      tabs = [];
    }
  }

  void drawTab(CanvasTab tab, Canvas canvas) {
    print("Tab: ${tab.title} [${tab.pos}]");
  }

  void drawTabs(int offset, Canvas canvas) {
    // Recalculate tab starting position of each tab
    for (var tab in tabs) {
      tab.pos = offset;
      offset += width - spacing;
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
      drawTab(tab, canvas);
    }

    if (top != null) drawTab(top, canvas);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPaint(backFill);

    drawTabs(40, canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
