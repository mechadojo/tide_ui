import 'package:flutter_web/widgets.dart';

class UpdateNotifier with ChangeNotifier {
  int updating = 0;
  bool hasChanged = false;

  void beginUpdate() {
    updating++;
  }

  void endUpdate(bool changed) {
    updating--;
    hasChanged |= changed;

    if (updating <= 0 && hasChanged) {
      notifyListeners();
      hasChanged = false;
      updating = 0;
    }
  }
}
