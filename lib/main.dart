import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import 'graph_editor/graph_canvas.dart';

void main() => runApp(TheApp());

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: Container(color: Colors.green, child: Text("Side Bar")),
        body: MultiProvider(
          providers: [...GraphCanvas.providers],
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Color(0xfffffff0),
                      height: 50,
                    ),
                    Expanded(
                      child: GraphCanvas(
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 300, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
