import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'data/canvas_state.dart';

import 'canvas_events.dart';
import 'canvas_grid_painter.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CanvasState>(context, listen: true);
    //print("Rebuild Canvas");
    return CanvasEventContainer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: CanvasGridPainter(
            pos: state.pos,
            scale: state.scale,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
