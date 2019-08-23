import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/icons/font_awesome_icons.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'data/graph_node.dart';

class EditNodeDialog extends StatefulWidget {
  static double EditNodeDialogHeight = 200;
  final GraphNode node;
  final GraphEditorController editor;

  final GraphDialogResult close;

  EditNodeDialog(this.editor, this.node, this.close);

  _EditNodeDialogState createState() => _EditNodeDialogState();
}

class _EditNodeDialogState extends State<EditNodeDialog> {
  GraphNode node;
  GraphEditorController editor;
  final titleController = TextEditingController();
  final methodController = TextEditingController();
  final iconController = TextEditingController();
  final delayController = TextEditingController();
  final titleFocus = FocusNode();
  final methodFocus = FocusNode();
  final iconFocus = FocusNode();
  final delayFocus = FocusNode();

  int autoCompleteIndex = 0;
  String autoCompletePrefix;
  TextStyle _defaultInputStyle = TextStyle(fontFamily: "Source Sans Pro");
  TextStyle _defaultLabelStyle = TextStyle(
      fontSize: 15, fontFamily: "Source Sans Pro", fontWeight: FontWeight.bold);
  TextStyle _defaultHeaderStyle = TextStyle(
      fontSize: 20, fontFamily: "Source Sans Pro", fontWeight: FontWeight.bold);
  @override
  void initState() {
    super.initState();
    node = widget.node;
    editor = widget.editor;
    editor.bottomSheetHeight = EditNodeDialog.EditNodeDialogHeight;

    titleController
      ..text = node.title
      ..addListener(updateTitle);

    delayController
      ..text = node.delay.toString()
      ..addListener(updateDelay);

    iconFocus
      ..addListener(
          onChangeFocus(iconFocus, iconController, delayFocus, titleFocus));

    titleFocus
      ..addListener(
          onChangeFocus(titleFocus, titleController, iconFocus, methodFocus));

    methodFocus
      ..addListener(
          onChangeFocus(methodFocus, methodController, titleFocus, delayFocus));

    delayFocus
      ..addListener(
          onChangeFocus(delayFocus, delayController, methodFocus, iconFocus));

    methodController
      ..text = node.method
      ..addListener(updateMethod);
    iconController
      ..text = node.icon
      ..addListener(updateIcon);
  }

  VoidCallback onChangeFocus(FocusNode focus, TextEditingController controller,
      FocusNode prev, FocusNode next) {
    return () {
      if (focus.hasFocus) {
        controller.value = controller.value.copyWith(
            selection: TextSelection(
                baseOffset: 0, extentOffset: controller.text.length),
            composing: TextRange.empty);

        editor.autoComplete = null;
        autoCompleteIndex = 0;
        editor.tabFocus = (reversed) {
          if (reversed) {
            prev.requestFocus();
          } else {
            next.requestFocus();
          }
        };
      }
    };
  }

  void update() {
    editor.graph.beginUpdate();
    editor.graph.endUpdate(true);
  }

  void updateDelay() {
    var delay = double.tryParse(delayController.text);
    if (delay != null) {
      setState(() {
        node.delay = delay;
        update();
      });
    }
  }

  void updateTitle() {
    node.title = titleController.text;
    update();
  }

  void autoCompleteIcon(bool reversed) {
    var names = [
      ...VectorIcons.names.where((x) => x.startsWith(autoCompletePrefix))
    ];

    if (names.isEmpty) return;

    autoCompleteIndex = autoCompleteIndex + (reversed ? -1 : 1);
    if (autoCompleteIndex < 0) {
      autoCompleteIndex = names.length + autoCompleteIndex;
    }

    if (autoCompleteIndex >= names.length) {
      autoCompleteIndex = autoCompleteIndex % names.length;
    }

    //print("Auto $autoCompleteIndex of ${names.length} [$names]");

    var icon = names[autoCompleteIndex];

    iconController.value = iconController.value.copyWith(
        text: icon,
        selection: TextSelection(
            baseOffset: autoCompletePrefix.length, extentOffset: icon.length),
        composing: TextRange.empty);
    node.icon = icon;
    update();
  }

  void updateIcon() {
    var text = iconController.text.trim();
    if (VectorIcons.names.contains(text)) {
      node.icon = text;
      update();
    } else {
      if (text != autoCompletePrefix) {
        autoCompletePrefix = text;
        autoCompleteIndex = -1;
        autoCompleteIcon(false);
      } else {
        autoCompleteIcon(false);
      }
    }
  }

  void updateMethod() {
    node.method = methodController.text;

    var method = methodController.text;
    if (method.contains(".")) {
      var idx = method.lastIndexOf(".");
      node.library = method.substring(0, idx);
      node.method = method.substring(idx + 1);
    } else {
      node.library = null;
      node.method = method;
    }

    update();
  }

  InputDecoration getBaseTextField({String hintText}) {
    return InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      hintText: hintText,
    );
  }

  Widget createLabeledRow(String label,
      {List<Widget> children, double padding = 0, double width = 150}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 60,
              child: Text(
                "$label:",
                textAlign: TextAlign.right,
                style: _defaultLabelStyle,
              )),
          SizedBox(width: 5),
          SizedBox(
            width: width,
            child: Container(
              child: Row(
                children: children,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createTextField(
      BuildContext context, String label, TextEditingController controller,
      {String hintText,
      double width = 150,
      FocusNode focus,
      FocusNode next,
      bool autofocus = false,
      double padding = 0}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 60,
              child: Text(
                "$label:",
                textAlign: TextAlign.right,
                style: _defaultLabelStyle,
              )),
          SizedBox(width: 5),
          SizedBox(
            width: width,
            height: 25,
            child: TextFormField(
              textInputAction: TextInputAction.next,
              style: _defaultInputStyle,
              controller: controller,
              autofocus: autofocus,
              focusNode: focus,
              onFieldSubmitted: (v) {
                if (next != null) {
                  FocusScope.of(context).requestFocus(next);
                }
              },
              enableInteractiveSelection: false,
              decoration: getBaseTextField(hintText: hintText),
            ),
          ),
        ],
      ),
    );
  }

  Widget createDebugRow() {
    return createLabeledRow("Debug", children: [
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: node.isDebugging,
        onChanged: (value) {
          setState(() {
            node.isDebugging = value;
            update();
          });
        },
      ),
      Text("Log:", style: _defaultLabelStyle),
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: node.isLogging,
        onChanged: (value) {
          setState(() {
            node.isLogging = value;
            update();
          });
        },
      )
    ]);
  }

  Widget createDelayRow() {
    return createLabeledRow("Delay", children: [
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: node.delay > 0,
        onChanged: (value) {
          setState(() {
            if (value) {
              node.delay = 1.0;
              delayFocus.requestFocus();
            } else {
              node.delay = 0;
            }
            delayController.text = node.delay.toString();
            update();
          });
        },
      ),
      SizedBox(
        width: 91,
        height: 25,
        child: TextFormField(
          controller: delayController,
          focusNode: delayFocus,
          style: _defaultInputStyle,
          enableInteractiveSelection: false,
          decoration: getBaseTextField(),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var height = EditNodeDialog.EditNodeDialogHeight;

    return Container(
      color: Color(0xffeeeeee),
      height: height,
      child: Column(
        children: <Widget>[
          SizedBox(height: 1, child: Container(color: Colors.black)),
          Container(
            child: Row(
              children: <Widget>[
                Form(
                  child: Container(
                    height: height - 1,
                    padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: 225,
                            padding: EdgeInsets.only(bottom: 2),
                            child:
                                Text("Edit Node", style: _defaultHeaderStyle)),
                        createTextField(context, "Icon", iconController,
                            focus: iconFocus, next: titleFocus),
                        createTextField(context, "Title", titleController,
                            focus: titleFocus, next: methodFocus, padding: 5),
                        createTextField(context, "Action", methodController,
                            focus: methodFocus, next: iconFocus),
                        createDelayRow(),
                        createDebugRow(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: height - 1,
                    alignment: Alignment.topRight,
//                    color: Colors.red,
                    child: SizedBox(
                      child: IconButton(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.topRight,
                        icon: Icon(FontAwesomeIcons.solidWindowClose, size: 15),
                        onPressed: () {
                          widget.close(false);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
