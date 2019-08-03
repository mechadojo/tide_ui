import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'data/canvas_state.dart';
import 'canvas_events.dart';
import 'canvas_grid.dart';

class GraphCanvas extends StatelessWidget {
  final Widget child;

  GraphCanvas({this.child});

  @override
  Widget build(BuildContext context) {
    return CanvasEventContainer(
      child: Consumer<CanvasState>(builder: (context, state, _) {
        return CustomPaint(
          painter: CanvasGrid(
            pos: state.pos,
            scale: state.scale,
          ),
          child: child,
        );
      }),
    );
  }

  static List<SingleChildCloneableWidget> get providers {
    return [
      ChangeNotifierProvider(builder: (_) => CanvasState()),
    ];
  }
}
