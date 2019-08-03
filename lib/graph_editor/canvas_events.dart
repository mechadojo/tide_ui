import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'data/canvas_state.dart';
import 'dart:html';
import 'dart:js' as js;
import 'package:uuid/uuid.dart';

class CanvasEventContainer extends StatelessWidget {
  final Widget child;
  final _eventkey = Uuid().v1().toString();

  CanvasEventContainer({this.child});

  bool get IsCurrentHandler {
    return js.context["Window"]["eventmaster"] == _eventkey;
  }

  void onKeyDown(KeyboardEvent evt, BuildContext context) {
    if (evt.key != "Control" && evt.key != "Alt" && evt.key != "Shift") {
      print("Key Down: ${evt.key}");
    }

    // Stop the default chrome hotkeys
    if (evt.ctrlKey) evt.preventDefault();
  }

  void onContextMenu(MouseEvent evt, BuildContext context) {
    print("Show Context Menu");
    // Stop the default context menu
    evt.preventDefault();
  }

  void onMouseWheel(WheelEvent evt, BuildContext context) {
    RenderBox rb = context.findRenderObject();
    var pt = rb.globalToLocal(Offset(evt.client.x, evt.client.y));
    if (pt.dx < 0 || pt.dy < 0) return;
    if (pt.dx > rb.size.width || pt.dy > rb.size.height) return;

    var canvas = Provider.of<CanvasState>(context);

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

  @override
  Widget build(BuildContext context) {
    if (!IsCurrentHandler) {
      js.context["Window"]["eventmaster"] = _eventkey;
      print("Adding new window event listener with key: $_eventkey");

      window.onKeyDown.listen((evt) {
        if (IsCurrentHandler) onKeyDown(evt, context);
      });
      window.onContextMenu.listen((evt) {
        if (IsCurrentHandler) onContextMenu(evt, context);
      });
      window.onMouseWheel.listen((evt) {
        if (IsCurrentHandler) onMouseWheel(evt, context);
      });
    }

    return Container(
      child: child,
    );
  }
}
