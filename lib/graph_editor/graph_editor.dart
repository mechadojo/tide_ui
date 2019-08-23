import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/focus_state.dart';
import 'package:tide_ui/graph_editor/graph_events.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/icons/font_awesome_icons.dart';
import 'graph_canvas.dart';
import 'graph_library.dart';
import 'graph_menu.dart';
import 'graph_tabs.dart';

class GraphEditorPage extends StatefulWidget {
  @override
  _GraphEditorPageState createState() => _GraphEditorPageState();
}

class _GraphEditorPageState extends State<GraphEditorPage>
    with SingleTickerProviderStateMixin {
  final GraphEditorController editor = GraphEditorController();

  @override
  void initState() {
    super.initState();
    this.createTicker(editor.onTick).start();
  }

  @override
  Widget build(BuildContext context) {
    editor.platform = Theme.of(context).platform.toString();

    return Scaffold(
      key: editor.scaffold,
      body: MultiProvider(
        providers: [...editor.providers],
        child: Row(
          children: <Widget>[
            Expanded(
                child: GraphEventContainer(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: GraphTabs(),
                  ),
                  Expanded(
                    child: Flow(
                      delegate: OverlayFlowDelegate(),
                      children: [
                        GraphCanvas(),
                        GraphLibrary(),
                        LongPressFocus(),
                        GraphMenu(),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DragModeButton(),
                              ZoomActionButton(),
                            ]),
                      ],
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class LongPressFocus extends StatelessWidget {
  const LongPressFocus({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LongPressFocusState>(
      builder: (context, LongPressFocusState focus, widget) {
        return CustomPaint(
          painter: LongPressFocusPainter(focus),
          child: Container(),
        );
      },
    );
  }
}

class LongPressFocusPainter extends CustomPainter {
  final LongPressFocusState focus;
  LongPressFocusPainter(this.focus);

  @override
  void paint(Canvas canvas, Size size) {
    if (!focus.active || focus.radius == 0) return;

    var fill = Graph.LongPressHighlight;
    if (focus.maxRadius < double.infinity) {
      var alpha = fill.color.alpha * (focus.radius / focus.maxRadius);
      fill = Paint()..color = fill.color.withAlpha(alpha.toInt());
    }

    canvas.drawCircle(focus.pos, focus.radius, fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ZoomActionButton extends StatelessWidget {
  const ZoomActionButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Consumer<GraphEditorState>(
        builder: (context, GraphEditorState editor, widget) {
          return FloatingActionButton(
            heroTag: "zoomToFitBtn",
            backgroundColor: Graph.getGroupColor(1),
            child: Icon(FontAwesomeIcons.search),
            onPressed: () {
              editor.dispatch(GraphEditorCommand.zoomToFit(true));
            },
          );
        },
      ),
    );
  }
}

class DragModeButton extends StatelessWidget {
  const DragModeButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Consumer<GraphEditorState>(
        builder: (context, GraphEditorState editor, widget) {
          return FloatingActionButton(
            heroTag: "dragModeBtn",
            backgroundColor: Graph.getGroupColor(
                editor.multiMode ? 1 : editor.touchMode ? 4 : 10),
            child: Icon(editor.dragMode == GraphDragMode.panning
                ? FontAwesomeIcons.arrowsAlt
                : editor.dragMode == GraphDragMode.viewing
                    ? FontAwesomeIcons.lock
                    : FontAwesomeIcons.expand),
            onPressed: () {
              editor.controller.toggleDragMode();
            },
          );
        },
      ),
    );
  }
}

class OverlayFlowDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    context.paintChild(0);

    for (int i = 1; i < context.childCount; i++) {
      context.paintChild(i);
    }
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return true;
  }
}
