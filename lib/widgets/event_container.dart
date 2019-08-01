import 'package:flutter_web/material.dart';
import 'dart:html';
import 'dart:js' as js;
import 'package:uuid/uuid.dart';

class EventContainer extends StatefulWidget {
  final Widget child;
  EventContainer({this.child});

  _EventContainerState createState() => _EventContainerState();
}

class _EventContainerState extends State<EventContainer> {
  var _eventkey = Uuid().v1().toString();
  var _counter = 0;

  bool get IsCurrentHandler {
    return js.context["Window"]["eventmaster"] == _eventkey;
  }

  void _handleKeyDown(KeyboardEvent evt) {
    if (!IsCurrentHandler) return;
    if (evt.key != "Control") {
      _counter++;
      print(
          "Key Down: Counter ${_counter} Ctrl:${evt.ctrlKey} Shift: ${evt.shiftKey} Key: ${evt.key} KeyCode: ${evt.keyCode}");
      if (evt.ctrlKey) evt.preventDefault();
    }
  }

  void _handleContextMenu(MouseEvent evt) {
    if (!IsCurrentHandler) return;
    print("Context Menu Clicked");
    evt.preventDefault();
  }

  void _handleMouseWheel(WheelEvent evt) {
    if (!IsCurrentHandler) return;
    print("Mouse Wheel: Ctrl: ${evt.ctrlKey} ${evt.deltaY}");
  }

  @override
  void initState() {
    var obj = js.context["Window"];
    obj["eventmaster"] = _eventkey;

    print("Adding new event listener with key: $_eventkey");
    window.onKeyDown.listen(_handleKeyDown);
    window.onContextMenu.listen(_handleContextMenu);
    window.onMouseWheel.listen(_handleMouseWheel);

    super.initState();
  }

  @override
  void dispose() {
    print("Disposing Event Container State");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}
