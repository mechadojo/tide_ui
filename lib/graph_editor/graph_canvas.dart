import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/graph_tabs.dart';
import 'data/canvas_state.dart';
import 'data/canvas_tab.dart';
import 'data/canvas_tabs_state.dart';

import 'canvas_events.dart';
import 'canvas_grid_painter.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    return CanvasEventContainer(
      child: Consumer<CanvasState>(builder: (context, state, _) {
        return Column(
          children: <Widget>[
            Container(
              height: 50,
              child: GraphTabs(),
            ),
            Expanded(
              child: CustomPaint(
                painter: CanvasGridPainter(
                  pos: state.pos,
                  scale: state.scale,
                ),
                child: Container(),
              ),
            ),
          ],
        );
      }),
    );
  }

  static List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => CanvasState()),
      ChangeNotifierProvider(
        builder: (_) => CanvasTabsState(selected: "tab3", tabs: [
          CanvasTab(title: "Tab 1", name: "tab1"),
          CanvasTab(title: "Tab 2", name: "tab2"),
          CanvasTab(title: "Tab 3", name: "tab3"),
          CanvasTab(title: "Tab 4", name: "tab4"),
        ]),
      ),
    ];
  }
}
