import 'dart:ui';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/controller/graph_event.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';

import 'update_notifier.dart';

class FocusState extends UpdateNotifier {
  GraphEditorController editor;

  GraphEvent startEvent = GraphEvent(); // event that started the focus

  Duration started = Duration.zero; // time the focus started
  Duration timeout = Duration.zero; // time the focus completes
  Duration update = Duration.zero; // next time to redraw
  Duration period = Graph.LongPressUpdatePeriod;
  double cancelAt = Graph.LongPressDistance;

  bool active = false;

  double radius = 0; // current radius of focus
  double rate = 0; // rate to expand radius in unit / microsecond
  double startRadius = 0;
  double minRadius = 0;
  double maxRadius = double.infinity;

  Offset pos = Offset.zero;

  Rect hitbox = Rect.zero;

  GraphEditorCommand command;
  GraphEditorCommand cancelCommand;

  void start(GraphEvent evt, Duration duration) {
    this.startEvent = evt;
    pos = evt.pos;
    started = evt.timer;
    timeout = started + duration;
    radius = startRadius;

    if (radius < minRadius) radius = 0;
    if (radius > maxRadius) radius = maxRadius;

    update = started + period;
    active = true;
  }

  void cancel() {
    if (!active) return;
    active = false;
    editor.dispatch(cancelCommand);
  }

  /// check if a recent event should cause the focus to cancel
  bool checkEvent(GraphEvent evt) {
    if (!active) return false;

    var dist = (startEvent.pos - evt.pos).distance;
    if (dist > cancelAt) {
      cancel();
      return true;
    }

    return false;
  }

  /// check if the current time should cause the focus to change
  bool checkUpdate(Duration timer) {
    if (!active) return false;

    if (timer > timeout) {
      active = false;
      editor.dispatch(command);
      return true;
    }

    if (timer > update) {
      var delta = timer - started;
      radius = delta.inMicroseconds * rate + startRadius;

      if (radius < minRadius) radius = 0;
      if (radius > maxRadius) radius = maxRadius;

      hitbox = Rect.fromCircle(center: pos, radius: radius);
      update += period;
      return true;
    }

    return false;
  }
}

class LongPressFocusState extends FocusState {
  LongPressFocusState() {
    rate = Graph.LongPressRadius / Graph.LongPressDuration.inMicroseconds;
    minRadius = Graph.LongPressStartRadius;
    maxRadius = Graph.LongPressRadius;
    cancelCommand = GraphEditorCommand.hideMenu();
  }

  @override
  void start(GraphEvent evt, Duration duration) {
    command = GraphEditorCommand.onContextMenu(evt);
    super.start(evt, duration);
  }
}
