import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'data/canvas_state.dart';
import 'canvas_events.dart';
import 'canvas_grid.dart';

class GraphCanvas extends StatelessWidget {
  GraphCanvas();

  @override
  Widget build(BuildContext context) {
    return CanvasEventContainer(
      child: Consumer<CanvasState>(builder: (context, state, _) {
        return Column(
          children: <Widget>[
            Container(
              color: Color(0xfffffff0),
              height: 50,
            ),
            Expanded(
              child: CustomPaint(
                painter: CanvasGrid(
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
    ];
  }
}
