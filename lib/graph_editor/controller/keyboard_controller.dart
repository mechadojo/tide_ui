import 'graph_event.dart';

mixin KeyboardController {
  bool onKeyDown(GraphEvent evt) {
    return false;
  }

  bool onKeyUp(GraphEvent evt) {
    return false;
  }

  bool onKeyPress(GraphEvent evt) {
    return false;
  }
}
