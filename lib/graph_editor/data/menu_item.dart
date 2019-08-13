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

  void copy(MenuItem other) {
    icon = other.icon;
    title = other.title;
    name = other.name;
    shortcut = other.shortcut;
    group = other.group;
    iconAlt = other.iconAlt;
    command = other.command;
  }
}
