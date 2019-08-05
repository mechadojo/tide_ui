import 'dart:html';

mixin KeyboardController {
  bool onKeyDown(KeyboardEvent evt) {
    return false;
  }

  bool onKeyUp(KeyboardEvent evt) {
    return false;
  }

  bool onKeyPress(KeyboardEvent evt) {
    return false;
  }
}
