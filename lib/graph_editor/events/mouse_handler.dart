import 'dart:html';

import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import 'package:tide_ui/graph_editor/data/canvas_state.dart';

class MouseHandler {
  void onContextMenu(MouseEvent evt, BuildContext context, bool isActive) {
    // Stop the default context menu
    evt.preventDefault();
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    print("Local: ${pt.dx}, ${pt.dy}");
  }

  void onMouseWheel(WheelEvent evt, BuildContext context, bool isActive) {
    if (!isActive) return;

    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));

    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    var canvas = Provider.of<CanvasState>(context, listen: false);

    // Control Scroll = Zoom at Cursor
    if (evt.ctrlKey) {
      if (evt.deltaY > 0) {
        canvas.zoomOut(focus: canvas.toGraphCoord(pt));
      } else {
        canvas.zoomIn(focus: canvas.toGraphCoord(pt));
      }
    } else if (evt.shiftKey) {
      // Pan Left/Right
      canvas.scrollBy(evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize, 0);
    } else {
      // Pan Up/Down
      canvas.scrollBy(0, evt.deltaY > 0 ? -canvas.stepSize : canvas.stepSize);
    }
  }
}
