import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';

import 'canvas_interactive.dart';

class MenuItem with CanvasInteractive {
  String icon;
  String title;
  String name;
  String shortcut;
  String group;
  String iconAlt;
  GraphEditorCommand command;

  MenuItem(
      {this.icon,
      this.title,
      this.name,
      this.shortcut,
      this.group,
      this.iconAlt,
      this.command});
}
