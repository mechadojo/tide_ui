import 'package:flutter_web/material.dart';

import 'package:tide_ui/widgets/draggable_card.dart';
import 'package:tide_ui/widgets/event_container.dart';

void main() => runApp(TheApp());

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: Container(color: Colors.green, child: Text("Side Bar")),
        body: EventContainer(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.yellow,
                      height: 75,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.red,
                        child: DraggableCard(
                          child: FlutterLogo(
                            size: 128,
                          ),
                        ),
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
