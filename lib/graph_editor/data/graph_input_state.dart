import 'package:flutter_web/cupertino.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/data/update_notifier.dart';

import 'menu_item.dart';

typedef HandleSubmitInput(String value);
typedef HandleValidateInput(String value);
typedef HandleSuggestInput(String value);
typedef HandleChangeInput(String value, GraphInputState input);

class GraphInputState extends UpdateNotifier {
  bool visible = false;

  HandleSubmitInput onSubmit;
  HandleSubmitInput onCancel;
  HandleValidateInput onValidate;
  HandleSuggestInput onSuggest;
  HandleChangeInput onChange;

  String get value => controller.text;
  set value(String text) {
    controller.value = controller.value.copyWith(text: text);
  }

  Rect hitbox = Rect.zero;
  Size size = Size(300, 25);

  String title;
  String hint;
  String prompt;
  String error;

  TextEditingController controller;
  FocusNode focus = FocusNode();

  MenuItem submitButton;
  MenuItem cancelButton;

  GraphInputState() {
    submitButton = MenuItem(
        icon: "check", command: GraphEditorCommand(handleSubmitButton));

    cancelButton =
        MenuItem(icon: "times", command: GraphEditorCommand(handleCloseButton));

    controller = TextEditingController()..addListener(handleTextUpdate);
  }

  void handleTextUpdate() {
    if (onChange != null) {
      onChange(value, this);
    }
  }

  void handleCloseButton(GraphEditorController editor) {
    editor.cancelPrompt();
  }

  void handleSubmitButton(GraphEditorController editor) {
    editor.submitPrompt();
  }
}
