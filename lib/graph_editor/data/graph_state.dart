import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';
import '../icons/font_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class GraphState with ChangeNotifier {
  GraphController controller;
  String id = Uuid().v1().toString();
  int version = 0;

  bool copy(GraphState other) {
    id = other.id;
    version = other.version;

    return false;
  }

  Iterable<Widget> getNodes(double scale) sync* {
    yield Text("Hello!");
    for (int i = 0; i < 10; i++) {
      yield Icon(FontAwesomeIcons.getIconByIndex(i * 25), size: 50);

      // yield Transform(
      //     transform: Matrix4.identity()..scale(1.0 / scale, 1.0 / scale),
      //     child:
      //         Icon(FontAwesomeIcons.getIconByIndex(i * 25), size: 50 * scale));
    }
  }

  void clear() {}
}
