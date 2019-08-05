import 'canvas_interactive.dart';

class MenuItem with CanvasInteractive {
  String icon;
  String title;
  String name;
  String shortcut;
  String group;

  MenuItem({this.icon, this.title, this.name, this.shortcut, this.group});
}
