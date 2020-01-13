import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/canvas_tabs_state.dart';
import 'painter/canvas_tabs_painter.dart';

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

    //print("Rebuild Tabs");
    return RepaintBoundary(
      child: CustomPaint(
        painter: CanvasTabsPainter(state),
        child: Container(),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final state = Provider.of<CanvasTabsState>(context, listen: true);
  //   final editor = Provider.of<GraphEditorState>(context, listen: false);

  //   //print("Rebuild Tabs");
  //   return GestureDetector(
  //     onTapDown: (evt) {
  //       var pt = globalToLocal(context, evt.globalPosition);
  //       editor.mouseHandler.onMouseMoveTabs(null, pt);
  //       editor.mouseHandler.onMouseDownTabs(null, pt);
  //     },
  //     onTapUp: (evt) {
  //       var pt = globalToLocal(context, evt.globalPosition);
  //       editor.mouseHandler.onMouseUpTabs(null, pt);
  //       editor.mouseHandler.onMouseOutTabs();
  //     },
  //     onHorizontalDragStart: (evt) {
  //       state.controller.startSwipe(evt.globalPosition);
  //     },
  //     onHorizontalDragUpdate: (evt) {
  //       state.controller.updateSwipe(evt.globalPosition);
  //     },
  //     onHorizontalDragEnd: (evt) {
  //       state.controller.endSwipe(evt.primaryVelocity);
  //     },
  //     child: RepaintBoundary(
  //       child: CustomPaint(
  //         painter: CanvasTabsPainter(state),
  //         child: Container(),
  //       ),
  //     ),
  //   );
  // }
}
