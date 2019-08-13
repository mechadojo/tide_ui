import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/painter/canvas_painter.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';
import 'data/canvas_state.dart';
import 'data/graph_editor_state.dart';
import 'data/radial_menu_state.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

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
    final canvas = Provider.of<CanvasState>(context, listen: true);
    final graph = Provider.of<GraphState>(context, listen: true);
    final menu = Provider.of<RadialMenuState>(context, listen: true);

    final editor = Provider.of<GraphEditorState>(context, listen: false);

    //print("Rebuild Canvas");
    return GestureDetector(
      onTapDown: (evt) {
        var pt = globalToLocal(context, evt.globalPosition);

        editor.mouseHandler.onMouseMoveCanvas(null, pt);
        editor.mouseHandler.onMouseDownCanvas(null, pt);
      },
      onTapUp: (evt) {
        editor.mouseHandler.onMouseUpCanvas(null);
        editor.mouseHandler.onMouseOutCanvas();
      },
      onDoubleTap: () {
        editor.mouseHandler.onMouseDoubleTap();
      },
      onLongPressStart: (evt) {
        var pt = globalToLocal(context, evt.globalPosition);
        editor.mouseHandler.onMouseMoveCanvas(null, pt);
        editor.mouseHandler.onContextMenuCanvas(null, pt);
      },
      onLongPressEnd: (evt) {
        editor.mouseHandler.onMouseUpCanvas(null);
        editor.mouseHandler.onMouseOutCanvas();
      },
      onScaleStart: (evt) {},
      onScaleUpdate: (evt) {
        var pt = globalToLocal(context, evt.focalPoint);
        //print("Scale Update: $pt");

        if (evt.scale == 1) {
          editor.mouseHandler.onMouseMoveCanvas(null, pt);
        } else {
          canvas.beginUpdate();
          canvas.zoomAt(evt.scale, pt);
          canvas.endUpdate(true);
        }
      },
      onScaleEnd: (evt) {
        editor.mouseHandler.onMouseUpCanvas(null);
        editor.mouseHandler.onMouseOutCanvas();
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: CanvasPainter(
            canvas,
            graph,
            menu,
          ),
          child: Container(
            alignment: Alignment.topLeft,
            child: Container(),
          ),
        ),
      ),
    );
  }
}
