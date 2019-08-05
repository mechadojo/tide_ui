import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/canvas_controller.dart';
import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_controller.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/mouse_handler.dart';

import 'package:tide_ui/main.dart' show routeObserver; // this seems hacky

import 'package:provider/provider.dart';

import 'package:tide_ui/graph_editor/data/canvas_state.dart';
import 'package:tide_ui/graph_editor/data/canvas_tabs_state.dart';

import 'dart:html';
import 'dart:js' as js;
import 'package:uuid/uuid.dart';

import 'data/graph_state.dart';

class CanvasEventContainer extends StatefulWidget {
  final Widget child;

  CanvasEventContainer({this.child});

  @override
  _CanvasEventContainerState createState() => _CanvasEventContainerState();
}

class _CanvasEventContainerState extends State<CanvasEventContainer>
    with RouteAware {
  final _eventkey = Uuid().v1().toString();

  bool _isPageActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    print("Re-activating window event handlers");
    _isPageActive = true;
  }

  void didPush() {
    print("Activating window event handlers");
    _isPageActive = true;
  }

  void didPop() {
    print("pop");
  }

  void didPushNext() {
    print("De-activating window event handlers");
    _isPageActive = false;
  }

  bool get IsCurrentHandler {
    return js.context["Window"]["eventmaster"] == _eventkey;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = Provider.of<CanvasTabsState>(context, listen: false);
    final canvas = Provider.of<CanvasState>(context, listen: false);
    final graph = Provider.of<GraphState>(context, listen: false);

    final MouseHandler mouseHandler =
        MouseHandler(canvas.controller, tabs.controller, graph.controller);
    final KeyboardHandler keyboardHandler =
        KeyboardHandler(canvas.controller, tabs.controller, graph.controller);

    if (!IsCurrentHandler) {
      js.context["Window"]["eventmaster"] = _eventkey;
      print("Adding new window event listener with key: $_eventkey");

      window.onKeyDown.listen((evt) {
        if (IsCurrentHandler) {
          keyboardHandler.onKeyDown(evt, context, _isPageActive);
        }
      });

      window.onKeyPress.listen((evt) {
        if (IsCurrentHandler) {
          keyboardHandler.onKeyPress(evt, context, _isPageActive);
        }
      });

      window.onKeyUp.listen((evt) {
        if (IsCurrentHandler) {
          keyboardHandler.onKeyUp(evt, context, _isPageActive);
        }
      });

      window.onContextMenu.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onContextMenu(evt, context, _isPageActive);
        }
      });
      window.onMouseWheel.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onMouseWheel(evt, context, _isPageActive);
        }
      });

      window.onMouseOut.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onMouseOut(evt, context, _isPageActive);
        }
      });

      window.onMouseMove.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onMouseMove(evt, context, _isPageActive);
        }
      });

      window.onMouseDown.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onMouseDown(evt, context, _isPageActive);
        }
      });

      window.onMouseUp.listen((evt) {
        if (IsCurrentHandler) {
          mouseHandler.onMouseUp(evt, context, _isPageActive);
        }
      });
    }

    return Container(
      child: widget.child,
    );
  }
}
