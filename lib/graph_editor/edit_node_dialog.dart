import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/icons/font_awesome_icons.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'data/graph.dart';
import 'data/graph_node.dart';
import 'data/node_port.dart';
import 'painter/vector_icon_painter.dart';

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

  TextStyle _defaultPortListStyle =
      TextStyle(fontSize: 15, fontFamily: "Source Sans Pro");

  TextStyle _defaultHeaderStyle = TextStyle(
      fontSize: 20, fontFamily: "Source Sans Pro", fontWeight: FontWeight.bold);

  TextStyle _selectedTabStyle = TextStyle(
      fontSize: 18, fontFamily: "Source Sans Pro", fontWeight: FontWeight.bold);

  TextStyle _defaultTabStyle = TextStyle(
      color: Colors.grey,
      fontSize: 18,
      fontFamily: "Source Sans Pro",
      fontWeight: FontWeight.bold);
  Paint _defaultButtonIcon = Graph.blackPaint;
  Paint _disabledButtonIcon = Paint()..color = Colors.black.withAlpha(127);
  Paint _defaultStarFill = Graph.blackPaint;

  String selectedTab = "inports";
  bool get isInportsTab => selectedTab == "inports";
  bool get isOutportsTab => selectedTab == "outports";
  bool get isPropsTab => selectedTab == "props";
  NodePort selectedPort;
  NodePort lastSelectedInport;
  NodePort lastSelectedOutport;
  GlobalKey selectedPortKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    node = widget.node;
    editor = widget.editor;
    editor.bottomSheetHeight = EditNodeDialog.EditNodeDialogHeight;

    lastSelectedInport = node.inports.isEmpty ? null : node.inports.first;
    lastSelectedOutport = node.outports.isEmpty ? null : node.outports.first;
    selectedPort = lastSelectedInport;
    selectedTab = "inports";

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

  void ensureSelectedPortVisible() {
    editor.dispatch(GraphEditorCommand.ensureVisible(selectedPortKey),
        afterTicks: 5);
  }

  void selectInportsTab() {
    setState(() {
      if (selectedTab == "outports") {
        lastSelectedOutport = selectedPort;
      }

      selectedPort = lastSelectedInport;
      selectedTab = "inports";

      if (node.inports.isNotEmpty && selectedPort != null) {
        ensureSelectedPortVisible();
      }
    });
  }

  void selectOutportsTab() {
    setState(() {
      if (selectedTab == "inports") {
        lastSelectedInport = selectedPort;
      }

      selectedPort = lastSelectedOutport;
      selectedTab = "outports";
      if (node.outports.isNotEmpty && selectedPort != null) {
        ensureSelectedPortVisible();
      }
    });
  }

  void selectPort(NodePort port) {
    setState(() {
      selectedPort = port;
      ensureSelectedPortVisible();
    });
  }

  void selectPropsTab() {
    setState(() {
      if (selectedTab == "inports") {
        lastSelectedInport = selectedPort;
      }

      if (selectedTab == "outports") {
        lastSelectedOutport = selectedPort;
      }

      selectedPort = null;
      selectedTab = "props";
    });
  }

  List<Widget> getPortList() {
    switch (selectedTab) {
      case "inports":
        return node.inports.map(getPortListItem).toList();
      case "outports":
        return node.outports.map(getPortListItem).toList();
      case "props":
        return [];
    }
    return [];
  }

  Widget getPortListItem(NodePort port) {
    bool selected = port.equalTo(selectedPort);

    return Card(
      key: selected ? selectedPortKey : null,
      color: selected ? Colors.blue[100] : null,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          selectPort(port);
        },
        child: Text(
          port.name,
          style: _defaultPortListStyle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  void setDefaultPort() {
    if (isPropsTab || selectedPort == null) return;

    setState(() {
      node.setDefaultPort(selectedPort, toggle: true);
      update();
    });
  }

  void onMovePortUp() {
    setState(() {
      if (isPropsTab) {
      } else {
        node.movePortUp(selectedPort);
      }
      update();
      ensureSelectedPortVisible();
    });
  }

  void onMovePortDown() {
    setState(() {
      if (isPropsTab) {
      } else {
        node.movePortDown(selectedPort);
      }

      update();
      ensureSelectedPortVisible();
    });
  }

  void onAddPort() {
    print("Add new port");
  }

  void onAddProperty() {
    print("Add new port");
  }

  void onDeletePort() {
    print("Delete $selectedPort");
  }

  void onDeleteProperty() {
    print("Delete $selectedPort");
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
    var delay = double.tryParse(delayController.text) ?? 0;
    if (delay != null) {
      delay = (delay * 100.0).round() / 100.0;

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
    var text = iconController.text.toLowerCase();
    if (VectorIcons.names.contains(text)) {
      node.icon = text;
      update();
    } else {
      text = text.trim();

      if (iconController.text == autoCompletePrefix && text.isNotEmpty) {
        text = text.substring(0, text.length - 1);
      }

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

  Widget createIconButton(
    BuildContext context,
    String icon, {
    VoidCallback onPressed,
    double width = 20,
    double height = 20,
    double size = 18,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    EdgeInsets padding = const EdgeInsets.all(2),
    Paint fill,
    Paint stroke,
  }) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: padding,
          child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                  painter: VectorIconPainter(icon, size,
                      fill: onPressed == null
                          ? fill ?? _disabledButtonIcon
                          : fill ?? _defaultButtonIcon,
                      stroke: stroke),
                  child: Container())),
        ),
      ),
    );
  }

  bool get isLastPort {
    if (isPropsTab) return true;
    if (selectedPort == null) return true;

    if (selectedTab == "inports") {
      if (node.inports.isEmpty) return true;
      return node.inports.last.equalTo(selectedPort);
    }

    if (selectedTab == "outports") {
      if (node.outports.isEmpty) return true;
      return node.outports.last.equalTo(selectedPort);
    }

    return true;
  }

  bool get isFirstPort {
    if (isPropsTab) return true;

    if (selectedPort == null) return true;

    if (selectedTab == "inports") {
      if (node.inports.isEmpty) return true;
      return node.inports.first.equalTo(selectedPort);
    }

    if (selectedTab == "outports") {
      if (node.outports.isEmpty) return true;
      return node.outports.first.equalTo(selectedPort);
    }

    return true;
  }

  Widget createPortsButtons(BuildContext context) {
    var isDefault = !isPropsTab && selectedPort.isDefault;

    return Column(
      children: <Widget>[
        createIconButton(
          context,
          isDefault ? "star-solid" : "star",
          onPressed: isPropsTab ? null : setDefaultPort,
          fill: isDefault ? _defaultStarFill : null,
        ),
        createIconButton(context, "arrow-up",
            onPressed: isFirstPort ? null : onMovePortUp),
        createIconButton(context, "arrow-down",
            onPressed: isLastPort ? null : onMovePortDown),
        createIconButton(context, "plus-square-solid",
            onPressed: this.isPropsTab
                ? onAddProperty
                : ((this.isInportsTab
                        ? node.allowAddInport
                        : node.allowAddOutport)
                    ? onAddPort
                    : null)),
        createIconButton(context, "trash-alt-solid",
            onPressed: this.isPropsTab
                ? onDeleteProperty
                : (editor.graph.allowDeletePort(selectedPort)
                    ? onDeletePort
                    : null)),
      ],
    );
  }

  Widget createPortsForm(BuildContext context, double height) {
    return Form(
      child: Container(
          height: height - 1,
          padding: EdgeInsets.only(right: 10, bottom: 5),
          width: 350,
          child: Column(
            children: <Widget>[
              createPortTabs(),
              Expanded(
                  child: Row(
                children: <Widget>[
                  Container(
                    width: 75,
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: getPortList(),
                        )),
                  ),
                  createPortsButtons(context),
                  Expanded(child: Container(color: Colors.green)),
                ],
              ))
            ],
          )),
    );
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
              textCapitalization: TextCapitalization.none,
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
          keyboardType:
              TextInputType.numberWithOptions(signed: false, decimal: true),
          enableInteractiveSelection: false,
          decoration: getBaseTextField(),
        ),
      ),
    ]);
  }

  Widget createNodeForm(BuildContext context, double height) {
    return Form(
      child: Container(
        height: height - 1,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: 225,
                padding: EdgeInsets.only(bottom: 2),
                child: Text("Edit Node", style: _defaultHeaderStyle)),
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
    );
  }

  Widget createPortTabs() {
    return Row(
      children: <Widget>[
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text("Inports",
              style: isInportsTab ? _selectedTabStyle : _defaultTabStyle),
          onPressed: selectInportsTab,
        ),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text("Outports",
              style: isOutportsTab ? _selectedTabStyle : _defaultTabStyle),
          onPressed: selectOutportsTab,
        ),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text("Properties",
              style: isPropsTab ? _selectedTabStyle : _defaultTabStyle),
          onPressed: selectPropsTab,
        ),
      ],
    );
  }

  Widget createCloseButton(double height) {
    return Expanded(
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
    );
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
                createNodeForm(context, height),
                createPortsForm(context, height),
                createCloseButton(height),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
