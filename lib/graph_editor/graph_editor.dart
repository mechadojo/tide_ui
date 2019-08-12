import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/canvas_events.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'graph_canvas.dart';
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
    return Scaffold(
      body: MultiProvider(
        providers: [...editor.providers],
        child: Row(
          children: <Widget>[
            Expanded(
                child: CanvasEventContainer(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: GraphTabs(),
                  ),
                  Expanded(
                    child: GraphCanvas(),
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
