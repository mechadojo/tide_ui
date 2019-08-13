import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';

import 'canvas_interactive.dart';

class MenuItemSet extends MenuItem {
  double angle = 0;
  List<MenuItem> items = [];
  MenuItemSet([this.items]) {
    items = items ?? [];
  }
  int get length => items.length;
  MenuItem get(int index) {
    return items[index];
  }
}

class MenuItem with CanvasInteractive {
  String icon;
  String title;
  String name;
  String shortcut;
  String group;
  String iconAlt;
  GraphEditorCommand command;

  bool get hasIcon => icon != null && icon.isNotEmpty;
  bool get hasTitle => title != null && title.isNotEmpty;
  bool get hasName => name != null && name.isNotEmpty;
  bool get hasShortcut => shortcut != null && shortcut.isNotEmpty;
  bool get hasGroup => group != null && group.isNotEmpty;
  bool get hasIconAlt => iconAlt != null && iconAlt.isNotEmpty;
  bool get hasCommand => command != null;

  MenuItem(
      {this.icon,
      this.title,
      this.name,
      this.shortcut,
      this.group,
      this.iconAlt,
      this.command});

  void copy(MenuItem other) {
    if (other == null) return;

    icon = other.icon;
    title = other.title;
    name = other.name;
    shortcut = other.shortcut;
    group = other.group;
    iconAlt = other.iconAlt;
    command = other.command;
  }
}
