import 'package:flutter_web/material.dart';

import 'package:tide_ui/graph_editor/controller/keyboard_handler.dart';
import 'package:tide_ui/graph_editor/controller/mouse_handler.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';

import 'package:tide_ui/main.dart' show routeObserver; // this seems hacky

import 'package:provider/provider.dart';

import 'package:tide_ui/graph_editor/data/canvas_state.dart';

import 'dart:html';
import 'dart:js' as js;
import 'package:uuid/uuid.dart';

import 'controller/graph_event.dart';

class CanvasEventContainer extends StatefulWidget {
  final Widget child;

  CanvasEventContainer({this.child});

  @override
  _CanvasEventContainerState createState() => _CanvasEventContainerState();
}

class _CanvasEventContainerState extends State<CanvasEventContainer>
    with RouteAware {
  String _eventkey = Uuid().v1().toString();

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
    final canvas = Provider.of<CanvasState>(context, listen: false);
    final editor = Provider.of<GraphEditorState>(context, listen: false);

    final media = MediaQuery.of(context);
    print("Resize to ${media.size}");

    if (!IsCurrentHandler) {
      attachBrowserEvents(
          editor.mouseHandler, editor.keyboardHandler, canvas, editor);
    }

    return Container(
      child: widget.child,
    );
  }

  void attachBrowserEvents(
      MouseHandler mouseHandler,
      KeyboardHandler keyboardHandler,
      CanvasState canvas,
      GraphEditorState editor) {
    js.context["Window"]["eventmaster"] = _eventkey;
    print("Adding new window event listener with key: $_eventkey");

    window.onKeyDown.listen((evt) {
      if (IsCurrentHandler) {
        keyboardHandler.onKeyDown(GraphEvent.key(evt), context, _isPageActive);
      }
    });

    window.onKeyPress.listen((evt) {
      if (IsCurrentHandler) {
        keyboardHandler.onKeyPress(GraphEvent.key(evt), context, _isPageActive);
      }
    });

    window.onKeyUp.listen((evt) {
      if (IsCurrentHandler) {
        keyboardHandler.onKeyUp(GraphEvent.key(evt), context, _isPageActive);
      }
    });

    window.onTouchStart.listen((evt) {
      if (IsCurrentHandler) {
        editor.controller.setTouchMode(true);
        mouseHandler.onTouchStart(
            GraphEvent.touch(evt), context, _isPageActive);
        evt.preventDefault();
      }
    });

    window.onTouchMove.listen((evt) {
      if (IsCurrentHandler) {
        editor.controller.setTouchMode(true);
        mouseHandler.onTouchMove(GraphEvent.touch(evt), context, _isPageActive);
        evt.preventDefault();
      }
    });

    window.onTouchEnd.listen((evt) {
      if (IsCurrentHandler) {
        canvas.controller.setTouchMode(true);
        mouseHandler.onTouchEnd(GraphEvent.touch(evt), context, _isPageActive);
        evt.preventDefault();
      }
    });

    window.onTouchCancel.listen((evt) {
      if (IsCurrentHandler) {
        canvas.controller.setTouchMode(true);

        mouseHandler.onTouchCancel(
            GraphEvent.touch(evt), context, _isPageActive);
        evt.preventDefault();
      }
    });

    window.onMouseWheel.listen((evt) {
      if (IsCurrentHandler) {
        mouseHandler.onMouseWheel(
            GraphEvent.wheel(evt), context, _isPageActive);
      }
    });

    window.onMouseOut.listen((evt) {
      if (IsCurrentHandler) {
        mouseHandler.onMouseOut(GraphEvent.mouse(evt), context, _isPageActive);
      }
    });

    window.onMouseMove.listen((evt) {
      if (IsCurrentHandler) {
        mouseHandler.onMouseMove(GraphEvent.mouse(evt), context, _isPageActive);
      }
    });

    // some events we treat differently in touch mode

    window.onContextMenu.listen((evt) {
      if (IsCurrentHandler) {
        evt.preventDefault();
        return;
      }
    });

    window.onMouseDown.listen((evt) {
      if (IsCurrentHandler) {
        editor.controller.setTouchMode(false);

        mouseHandler.onMouseDown(GraphEvent.mouse(evt), context, _isPageActive);
      }
    });

    window.onMouseUp.listen((evt) {
      if (IsCurrentHandler) {
        mouseHandler.onMouseUp(GraphEvent.mouse(evt), context, _isPageActive);
      }
    });
  }
}
