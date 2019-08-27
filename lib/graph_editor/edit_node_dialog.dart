import 'dart:async';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'package:tide_ui/widgets/text_panel.dart';

import 'controller/graph_event.dart';
import 'data/graph.dart';
import 'data/graph_node.dart';
import 'data/graph_property_set.dart';
import 'data/node_port.dart';
import 'painter/vector_icon_painter.dart';

class EditNodeDialog extends StatefulWidget {
  static double EditNodeDialogHeight = 200;
  static double PortFormWidth = 435;
  static double NodeFormWidth = 235;
  static double CloseButtonWidth = 25;

  final GraphNode node;
  final GraphEditorController editor;

  final GraphDialogResult close;
  final NodePort port;
  final String focus;
  final TextPanelDocument script = TextPanelDocument();

  EditNodeDialog(this.editor, this.node, this.close, {this.port, this.focus});

  _EditNodeDialogState createState() => _EditNodeDialogState();
}

class _EditNodeDialogState extends State<EditNodeDialog> {
  GraphNode node;
  GraphEditorController editor;
  final titleController = TextEditingController();
  final methodController = TextEditingController();
  final iconController = TextEditingController();
  final delayController = TextEditingController();
  final portNameController = TextEditingController();

  final portValueController = TextEditingController();
  final scriptController = StreamController<GraphEvent>();

  final propNameController = TextEditingController();
  final propValueController = TextEditingController();

  final titleFocus = FocusNode();
  final methodFocus = FocusNode();
  final iconFocus = FocusNode();
  final delayFocus = FocusNode();
  final portNameFocus = FocusNode();
  final portValueFocus = FocusNode();
  final scriptFocus = FocusNode();

  final propNameFocus = FocusNode();
  final propValueFocus = FocusNode();

  TextPanelDocument get scriptDocument => widget.script;

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
  String lastPortFlagType = "Value";

  bool get isInportsTab => selectedTab == "inports";
  bool get isOutportsTab => selectedTab == "outports";
  bool get isPropsTab => selectedTab == "props";
  bool get isScriptTab => selectedTab == "script";
  bool get isNotPortsTab => !isPortsTab;
  bool get isPortsTab => (isInportsTab || isOutportsTab);

  NodePort selectedPort;
  NodePort lastSelectedInport;
  NodePort lastSelectedOutport;
  GraphProperty selectedProp;
  GlobalKey selectedPortKey = GlobalKey();

  bool scriptFocused = false;
  Stream<GraphEvent> scriptKeys;
  double offsetValue = 1;
  double offsetMirror = 0;

  @override
  void dispose() {
    titleFocus?.dispose();
    methodFocus?.dispose();
    iconFocus?.dispose();
    delayFocus?.dispose();
    portNameFocus?.dispose();
    portValueFocus?.dispose();
    scriptFocus?.dispose();
    propNameFocus?.dispose();
    propValueFocus?.dispose();

    titleController?.dispose();
    methodController?.dispose();
    iconController?.dispose();
    delayController?.dispose();
    portNameController?.dispose();
    portValueController?.dispose();

    propNameController?.dispose();
    propValueController?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    node = widget.node;
    editor = widget.editor;
    editor.bottomSheetHeight = EditNodeDialog.EditNodeDialogHeight;

    lastSelectedInport = node.inports.isEmpty ? null : node.inports.first;
    lastSelectedOutport = node.outports.isEmpty ? null : node.outports.first;

    selectedPort = widget.port ?? lastSelectedInport;
    selectedTab = selectedPort.isInport ? "inports" : "outports";
    lastPortFlagType = selectedPort.isInport ? "Value" : "Link";

    scriptDocument
      ..add(node.script ?? "")
      ..home();

    scriptKeys = scriptController.stream.asBroadcastStream();

    titleController
      ..text = node.title
      ..addListener(updateTitle);

    delayController
      ..text = node.delay.toString()
      ..addListener(updateDelay);

    methodController
      ..text = node.method
      ..addListener(updateMethod);

    iconController
      ..text = node.icon
      ..addListener(updateIcon);

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

    portNameController
      ..text = selectedPort?.name
      ..addListener(updatePortName);

    portValueController
      ..text = selectedPort?.flagLabel
      ..addListener(updatePortValue);

    propNameController
      ..text = selectedProp?.name
      ..addListener(updatePropName);

    propValueController
      ..text = selectedProp?.getValue()
      ..addListener(updatePropValue);

    portNameFocus
      ..addListener(onChangeFocus(
          portNameFocus, portNameController, portValueFocus, portValueFocus));
    portValueFocus
      ..addListener(onChangeFocus(
          portValueFocus, portValueController, portNameFocus, portNameFocus));

    propNameFocus
      ..addListener(onChangeFocus(
          propNameFocus, propNameController, propValueFocus, propValueFocus));

    propValueFocus
      ..addListener(onChangeFocus(
          propValueFocus, propValueController, propNameFocus, propNameFocus,
          onLoseFocus: () {
        updatePortFields();
      }));

    scriptFocus.addListener(() {
      setState(() {
        if (scriptFocus.hasFocus) {
          editor.modalKeyHandler = onScriptKey;
        } else {
          editor.modalKeyHandler = null;
        }
      });
    });

    scriptFocus.attach(context);

    FocusNode focused;

    switch (widget.focus) {
      case "value":
        focused = portValueFocus;
        break;
      case "title":
        focused = titleFocus;
        break;
      case "name":
        focused = portNameFocus;
        break;
    }

    if (focused != null && !editor.isTouchMode) {
      editor.dispatch(GraphEditorCommand.requestFocus(focused), afterTicks: 2);
    }

    if (widget.port != null) {
      editor.dispatch(GraphEditorCommand.ensureVisible(selectedPortKey),
          afterTicks: 2);
    }
  }

  String labelOffsetValue() {
    if (selectedProp == null) return "0";
    if (selectedProp.getValueType() == "Double") {
      if (offsetValue == 1.0) {
        return "1.000";
      } else if (offsetValue == 0.1) {
        return "0.100";
      } else if (offsetValue == 0.01) {
        return "0.010";
      } else if (offsetValue == 0.001) {
        return "0.001";
      }
    } else {
      if (offsetValue == 1) {
        return "1";
      } else if (offsetValue == 10) {
        return "10";
      } else if (offsetValue == 100) {
        return "100";
      } else if (offsetValue == 1000) {
        return "1000";
      }
    }
    return "0.000";
  }

  void toggleOffsetValue() {
    if (selectedProp == null) return;

    setState(() {
      if (selectedProp.getValueType() == "Double") {
        if (offsetValue == 1.0) {
          offsetValue = 0.1;
        } else if (offsetValue == 0.1) {
          offsetValue = 0.01;
        } else if (offsetValue == 0.01) {
          offsetValue = 0.001;
        } else if (offsetValue == 0.001) {
          offsetValue = 1.0;
        }
      } else {
        if (offsetValue == 1.0) {
          offsetValue = 10;
        } else if (offsetValue == 10) {
          offsetValue = 100;
        } else if (offsetValue == 100) {
          offsetValue = 1000;
        } else if (offsetValue == 1000) {
          offsetValue = 1;
        }
      }
    });
  }

  void onScriptKey(GraphEvent evt) {
    scriptController.add(evt);
  }

  void ensureSelectedPortVisible() {
    editor.dispatch(GraphEditorCommand.ensureVisible(selectedPortKey),
        afterTicks: 2);
  }

  void updatePropsFields() {
    if (propNameController.text != selectedProp?.name) {
      propNameController.value = propNameController.value.copyWith(
          composing: TextRange.empty,
          selection: TextSelection.collapsed(offset: 0),
          text: selectedProp?.name);
    }

    var value = selectedProp?.getValue() ?? "";
    if (propValueController.text != value) {
      propValueController.value = propValueController.value.copyWith(
          composing: TextRange.empty,
          selection: TextSelection.collapsed(offset: 0),
          text: value);
    }
  }

  void updateScriptFields() {}

  void updatePortFields() {
    if (isPropsTab) {
      updatePropsFields();
      return;
    }

    if (isScriptTab) {
      return;
    }

    if (selectedPort == null) return;

    portNameController.value =
        portNameController.value.copyWith(text: selectedPort.name);

    portValueController.value =
        portValueController.value.copyWith(text: selectedPort.flagLabel ?? "");
  }

  void selectInportsTab() {
    setState(() {
      if (selectedTab == "outports") {
        lastSelectedOutport = selectedPort;
      }

      selectedPort = lastSelectedInport;
      selectedTab = "inports";
      lastPortFlagType = "Value";

      updatePortFields();

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
      lastPortFlagType = "Link";

      updatePortFields();

      if (node.outports.isNotEmpty && selectedPort != null) {
        ensureSelectedPortVisible();
      }
    });
  }

  void selectPort(NodePort port) {
    setState(() {
      selectedPort = port;
      lastPortFlagType = selectedPort.isInport ? "Value" : "Link";
      updatePortFields();
      ensureSelectedPortVisible();
    });
  }

  void selectProp(GraphProperty prop) {
    setState(() {
      selectedProp = prop;
      offsetMirror = 0;
      offsetValue = 1;

      updatePropsFields();
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
      if (selectedProp != null) {
        if (!node.props.values.any((x) => x == selectedProp)) {
          selectedProp = null;
        }
      }

      if (selectedProp == null) {
        selectedProp =
            node.props.values.isEmpty ? null : node.props.values.first;
      }

      updatePropsFields();
      if (selectedProp != null) {
        ensureSelectedPortVisible();
      }
    });
  }

  void selectScriptTab() {
    setState(() {
      if (selectedTab == "inports") {
        lastSelectedInport = selectedPort;
      }

      if (selectedTab == "outports") {
        lastSelectedOutport = selectedPort;
      }

      selectedPort = null;
      selectedTab = "script";
      editor.tabFocus = (reversed) {
        print("Script Tab: $reversed");
      };

      updateScriptFields();
    });
  }

  List<Widget> getPortList() {
    switch (selectedTab) {
      case "inports":
        return node.inports.map(getPortListItem).toList();
      case "outports":
        return node.outports.map(getPortListItem).toList();
      case "props":
        return node.props.values.map(getPropListItem).toList();
    }
    return [];
  }

  Widget getPropListItem(GraphProperty prop) {
    bool selected =
        selectedProp == null ? false : prop.name == selectedProp.name;

    return Card(
      key: selected ? selectedPortKey : null,
      color: selected ? Colors.blue[100] : null,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          selectProp(prop);
        },
        child: Text(
          prop.name,
          style: _defaultPortListStyle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  Widget getPortListItem(NodePort port) {
    bool selected = port.equalTo(selectedPort);

    return Card(
      key: selected ? selectedPortKey : null,
      color: selected ? Colors.blue[100] : null,
      child: FlatButton(
        padding: EdgeInsets.all(0),
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
    if (isNotPortsTab || selectedPort == null) return;

    setState(() {
      node.setDefaultPort(selectedPort, toggle: true);
      update();
    });
  }

  void onMovePortUp() {
    setState(() {
      if (isNotPortsTab) {
      } else {
        node.movePortUp(selectedPort);
        update();
        ensureSelectedPortVisible();
      }
    });
  }

  void onMovePortDown() {
    setState(() {
      if (isNotPortsTab) {
      } else {
        node.movePortDown(selectedPort);
        update();
        ensureSelectedPortVisible();
      }
    });
  }

  void onAddPort() {
    print("Add new port");
  }

  String getNextPropertyName(String type) {
    var index = 1;
    var prefix = getPropTypePrefix(type);

    for (var val in node.props.values) {
      if (val.name.startsWith(prefix)) {
        var idx = int.tryParse(val.name.substring(prefix.length));
        if (idx != null && idx >= index) index = idx + 1;
      }
    }
    return "$prefix$index";
  }

  void onCopyProps() {
    setState(() {
      editor.propsClipboard = node.props.packList();
    });
  }

  void onPasteProps() {
    setState(() {
      var props = GraphPropertySet.unpack(editor.propsClipboard);
      for (var prop in props.values) {
        node.props.replace(prop);
      }
    });
  }

  void onAddProperty() {
    var prop = GraphProperty.asString(getNextPropertyName("String"), "value");

    node.props.add(prop);

    selectProp(prop);

    requestFocus(propNameFocus);
  }

  void onDeletePort() {
    print("Delete $selectedPort");
  }

  void onDeleteProperty() {
    if (selectedProp == null) return;

    var values = node.props.values.toList();
    var idx = values.indexWhere((x) => x.name == selectedProp.name);
    if (idx < 0) return;

    node.props.remove(selectedProp.name);
    values.removeAt(idx);
    if (idx >= values.length - 1) idx = values.length - 1;

    selectProp(idx < 0 ? null : values[idx]);
  }

  VoidCallback onChangeFocus(FocusNode focus, TextEditingController controller,
      FocusNode prev, FocusNode next,
      {VoidCallback onLoseFocus}) {
    return () {
      if (focus.hasFocus) {
        if (focus != portValueFocus ||
            selectedProp?.getValueType() != "Boolean") {
          selectAll(controller);
        }

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

      if (!focus.hasFocus) {
        selectNone(controller);
        if (onLoseFocus != null) {
          onLoseFocus();
        }
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

  void updateScript() {}

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

  void updatePortName() {
    if (selectedPort == null) return;

    setState(() {
      var next = portNameController.text.trim().replaceAll(" ", "_");
      var ports = selectedPort.isInport ? node.inports : node.outports;

      if (ports.any((x) => x != selectedPort && x.name == next)) {
        next = "${next}_";
      }
      selectedPort.name = next;

      update();
    });
  }

  void updatePropName() {
    if (selectedProp == null) return;

    setState(() {
      var next = propNameController.text.trim().replaceAll(" ", "_");
      var values = node.props.values.toList();

      if (values.any((x) => x != selectedProp && x.name == next)) {
        next = "${next}_";
      }

      node.props.rename(selectedProp.name, next);

      update();
    });
  }

  void setPortAsValue() {
    if (selectedPort == null) return;

    setState(() {
      var value = selectedPort.flagLabel;
      if (value == null || value.isEmpty) value = GraphNode.randomName();

      selectedPort.setValue(value);
      lastPortFlagType = "Value";
      updatePortFields();
      update();
    });
  }

  void setPortAsTrigger() {
    if (selectedPort == null) return;

    if (selectedPort.isOutport) {
      setPortAsEvent();
      return;
    }

    setState(() {
      var value = selectedPort.flagLabel;
      if (value == null || value.isEmpty) value = GraphNode.randomName();

      selectedPort.setTrigger(value);
      lastPortFlagType = "Trigger";
      updatePortFields();
      update();
    });
  }

  void setPortAsEvent() {
    if (selectedPort == null) return;

    if (selectedPort.isInport) {
      setPortAsTrigger();
      return;
    }

    setState(() {
      var value = selectedPort.flagLabel;
      if (value == null || value.isEmpty) value = GraphNode.randomName();

      selectedPort.setEvent(value);
      lastPortFlagType = "Event";
      updatePortFields();
      update();
    });
  }

  void clearPortValue() {
    if (selectedPort == null) return;

    setState(() {
      selectedPort.value = null;
      selectedPort.link = null;
      selectedPort.event = null;
      selectedPort.trigger = null;

      lastPortFlagType = selectedPort.isInport ? "Value" : "Link";
      updatePortFields();
      update();
    });
  }

  void setPortAsLink() {
    if (selectedPort == null) return;

    setState(() {
      var value = selectedPort.flagLabel;
      if (value == null || value.isEmpty) value = GraphNode.randomName();

      selectedPort.setLink(value);
      updatePortFields();
      update();
    });
  }

  String getPropTypePrefix(String type) {
    var prefix = "text";
    if (type == "Integer" || type == "Double") prefix = "num";
    if (type == "Boolean") prefix = "flag";
    return prefix;
  }

  void updatePropType(String value) {
    if (selectedProp == null) return;

    offsetMirror = 0;
    offsetValue = 1;

    var lastPrefix = getPropTypePrefix(selectedProp.getValueType());

    var next =
        GraphProperty.parse(selectedProp.name, selectedProp.getValue(), value);

    if (next == null) return;

    node.props.replace(next);

    var nextPrefix = getPropTypePrefix(next.getValueType());
    if (next.name.startsWith(lastPrefix)) {
      var nn = next.name.replaceFirst(lastPrefix, nextPrefix);
      if (node.props.values.any((x) => x != next && x.name == nn)) {
        nn = getNextPropertyName(next.getValueType());
      }

      node.props.rename(next.name, nn);
    }

    selectProp(next);
    if (selectedProp.getValueType() != "Boolean") {
      requestFocus(propValueFocus);

      selectAll(propValueController);
    } else {
      selectNone(propValueController);
    }
  }

  // Focus and selection is a little glitchy in Flutter Web right now

  void requestFocus(FocusNode node) {
    //node.requestFocus();
  }

  void selectAll(TextEditingController controller) {
    // controller.value = controller.value.copyWith(
    //     selection:
    //         TextSelection(baseOffset: 0, extentOffset: controller.text.length),
    //     composing: TextRange.empty);
  }

  void selectNone(TextEditingController controller) {
    // controller.value = controller.value.copyWith(
    //     selection: TextSelection.collapsed(offset: 0),
    //     composing: TextRange.empty);
  }

  void offsetPropValue(double delta, {int round = 0, bool mirror = false}) {
    if (selectedProp == null) return;
    setState(() {
      var value = double.tryParse(propValueController.text) ?? 0;
      var last = value;
      value += delta;

      if (mirror) {
        if (last == 0) {
          if (offsetMirror != 0 && offsetMirror.sign != value.sign) {
            value = offsetMirror * -1;
          }
        } else {
          if (last.sign != value.sign) {
            offsetMirror = last;
            value = 0;
          }
        }
      }

      if (round > 0) {
        value = (value * round).roundToDouble() / round;
      }
      selectedProp.setValue(value.toString());

      requestFocus(propValueFocus);
      updatePropsFields();
      selectAll(propValueController);
    });
  }

  void updatePropValue() {
    if (selectedProp == null) return;

    setState(() {
      var value = propValueController.text;

      selectedProp.setValue(value);
    });
  }

  void updatePortValue() {
    if (selectedPort == null) return;

    setState(() {
      var value = portValueController.text;
      if (!editor.graph.allowAddFlag(selectedPort)) {
        value = null;
      }
      var type = selectedPort.flagType ?? lastPortFlagType;

      switch (type) {
        case "Value":
          selectedPort.setValue(value);
          break;
        case "Link":
          selectedPort.setLink(value);
          break;
        case "Trigger":
          selectedPort.setTrigger(value);
          break;
        case "Event":
          selectedPort.setEvent(value);
          break;
      }

      lastPortFlagType = type;
      updatePortFields();
      update();
    });
  }

  Iterable<Widget> createPropValueStringItems(BuildContext context,
      {width = 150}) sync* {
    yield createPropValueField(context, width: width);
  }

  Iterable<Widget> createPropValueBoolItems(BuildContext context,
      {width = 150}) sync* {
    yield Switch(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      value: selectedProp.getValue() == "true",
      onChanged: (value) {
        setState(() {
          selectedProp.setValue(value ? "true" : "false");
          updatePropsFields();
        });
      },
    );
    yield createPropValueField(context,
        width: 50,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5)));
  }

  Iterable<Widget> createPropValueIntItems(BuildContext context,
      {width = 150}) sync* {
    yield createPropValueField(context, width: 75);
    yield createIconButton(context, "plus", onPressed: () {
      offsetPropValue(offsetValue, mirror: true);
    });
    yield createIconButton(context, "minus", padding: EdgeInsets.all(0),
        onPressed: () {
      offsetPropValue(-offsetValue, mirror: true);
    });
    yield createTextButton(context, labelOffsetValue(),
        padding: EdgeInsets.all(0), width: 35, onPressed: () {
      toggleOffsetValue();
    });
  }

  Iterable<Widget> createPropValueDoubleItems(BuildContext context,
      {width = 150}) sync* {
    yield createPropValueField(context, width: 75);
    yield createIconButton(context, "plus", onPressed: () {
      offsetPropValue(offsetValue, round: 1000, mirror: true);
    });
    yield createIconButton(context, "minus", padding: EdgeInsets.all(0),
        onPressed: () {
      offsetPropValue(-offsetValue, round: 1000, mirror: true);
    });
    yield createTextButton(context, labelOffsetValue(),
        padding: EdgeInsets.all(0), width: 35, onPressed: () {
      toggleOffsetValue();
    });
  }

  Widget createPropValueField(BuildContext context,
      {width = 150, InputDecoration decoration}) {
    return SizedBox(
      width: width,
      height: 25,
      child: TextFormField(
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.none,
        style: _defaultInputStyle,
        controller: propValueController,
        focusNode: propValueFocus,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(portNameFocus);
        },
        decoration: decoration ?? getBaseTextField(),
        enableInteractiveSelection: false,
      ),
    );
  }

  Widget createPropValueRow(BuildContext context,
      {double width = 150, double padding = 0}) {
    String type = selectedProp?.getValueType() ?? "String";

    return createLabeledRow("Value", padding: padding, width: width, children: [
      if (type == "String")
        ...createPropValueStringItems(context, width: width),
      if (type == "Boolean") ...createPropValueBoolItems(context, width: width),
      if (type == "Integer") ...createPropValueIntItems(context, width: width),
      if (type == "Double")
        ...createPropValueDoubleItems(context, width: width),
    ]);
  }

  Iterable<Widget> createPropTypeRow(BuildContext context) sync* {
    yield createLabeledRow("Type", width: 185, children: [
      Container(
        width: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: selectedProp?.getValueType(),
                value: "String",
                onChanged: updatePropType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("String", style: _defaultLabelStyle),
          ],
        ),
      ),
      Container(
        width: 95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: selectedProp?.getValueType(),
                value: "Boolean",
                onChanged: updatePropType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Boolean", style: _defaultLabelStyle),
          ],
        ),
      ),
    ]);

    yield createLabeledRow("", width: 185, children: [
      Container(
        width: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: selectedProp?.getValueType(),
                value: "Integer",
                onChanged: updatePropType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Integer", style: _defaultLabelStyle),
          ],
        ),
      ),
      Container(
        width: 95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: selectedProp?.getValueType(),
                value: "Double",
                onChanged: updatePropType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Double", style: _defaultLabelStyle),
          ],
        ),
      ),
    ]);
  }

  Widget createPortValueRow(BuildContext context) {
    var label = selectedPort?.flagType ?? lastPortFlagType;

    return createLabeledRow(label, padding: 5, children: [
      SizedBox(
        width: 70,
        height: 25,
        child: TextFormField(
          controller: portValueController,
          focusNode: portValueFocus,
          style: _defaultInputStyle,
          enabled: editor.graph.allowAddFlag(selectedPort),
          enableInteractiveSelection: false,
          decoration: getBaseTextField(),
        ),
      ),
      createIconButton(context, "hashtag",
          width: 10,
          size: 12,
          padding: EdgeInsets.all(0),
          onPressed: !editor.graph.allowAddFlag(selectedPort)
              ? null
              : (selectedPort.isInport ? setPortAsValue : null)),
      createIconButton(context, "bolt",
          width: 10,
          size: 12,
          padding: EdgeInsets.all(0),
          onPressed: !editor.graph.allowAddFlag(selectedPort)
              ? null
              : (selectedPort.isInport ? setPortAsTrigger : setPortAsEvent)),
      createIconButton(context, "link",
          width: 10,
          size: 12,
          padding: EdgeInsets.all(0),
          onPressed:
              !editor.graph.allowAddFlag(selectedPort) ? null : setPortAsLink),
      createIconButton(context, "trash-alt-solid",
          width: 10,
          size: 12,
          padding: EdgeInsets.all(0),
          onPressed: selectedPort == null || !selectedPort.showFlag
              ? null
              : clearPortValue),
    ]);
  }

  Widget createTextButton(
    BuildContext context,
    String text, {
    VoidCallback onPressed,
    double width = 20,
    double height = 20,
    double size = 18,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    EdgeInsets padding = const EdgeInsets.all(2),
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
              child: Text(text, style: _defaultLabelStyle)),
        ),
      ),
    );
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
    if (isNotPortsTab) return true;
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
    if (isNotPortsTab) return true;

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

  Widget createPropsButtons(BuildContext context) {
    return Column(
      children: <Widget>[
        createIconButton(context, "plus-square-solid",
            onPressed: onAddProperty),
        createIconButton(context, "trash-alt-solid",
            onPressed: onDeleteProperty),
        createIconButton(context, "copy-solid",
            onPressed: node.props.values.isEmpty ? null : onCopyProps),
        createIconButton(context, "paste",
            onPressed: editor.propsClipboard.isEmpty ? null : onPasteProps),
      ],
    );
  }

  Widget createPortsButtons(BuildContext context) {
    var isDefault = isPortsTab && selectedPort.isDefault;

    return Column(
      children: <Widget>[
        createIconButton(
          context,
          isDefault ? "star-solid" : "star",
          onPressed: isNotPortsTab ? null : setDefaultPort,
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

  Widget createScriptButtons(BuildContext context) {
    return Column(
      children: <Widget>[
        createIconButton(context, "folder-open-solid"),
        createIconButton(context, "save-solid"),
        createIconButton(context, "copy-solid"),
        createIconButton(context, "cut"),
        createIconButton(context, "paste"),
      ],
    );
  }

  Iterable<Widget> getPortsFormFields(BuildContext context) sync* {
    yield createTextField(context, "Name", portNameController,
        focus: portNameFocus);
    yield createPortValueRow(context);
  }

  Iterable<Widget> getPropsFormFields(BuildContext context) sync* {
    yield createTextField(context, "Name", propNameController,
        width: 185, focus: propNameFocus);

    yield createPropValueRow(context, width: 185, padding: 5);
    yield* createPropTypeRow(context);
  }

  Iterable<Widget> createPortsFormItems(BuildContext context,
      {double height, double width}) sync* {
    if (isScriptTab) {
      yield createScriptButtons(context);
      yield TextPanel(
        scriptDocument,
        Size(width - 34, height - 42),
        scriptFocus.hasFocus,
        keys: scriptKeys,
        focus: () {
          if (!scriptFocus.hasFocus) {
            FocusScope.of(context).requestFocus(scriptFocus);
          }
        },
      );
    } else {
      var ports = getPortList();

      if (ports.isNotEmpty) {
        yield Container(
          width: 75,
          height: height - 1,
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: getPortList(),
              )),
        );
      }

      if (isInportsTab || isOutportsTab) {
        yield createPortsButtons(context);
        yield Column(
          children: <Widget>[...getPortsFormFields(context)],
        );
      } else if (isPropsTab) {
        yield createPropsButtons(context);
        yield Column(
          children: <Widget>[...getPropsFormFields(context)],
        );
      }
    }
  }

  Widget createPortsForm(BuildContext context, {double width, double height}) {
    return Form(
      child: Container(
          height: height - 1,
          width: width,
          padding: EdgeInsets.only(right: 10, bottom: 5),
          child: Column(
            children: <Widget>[
              createPortTabs(width - 10),
              Container(
                  height: height - 42,
                  child: Row(
                    children: <Widget>[
                      ...createPortsFormItems(context,
                          width: width - 10, height: height)
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 60,
              child: label.isEmpty
                  ? null
                  : Text(
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
              requestFocus(delayFocus);
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

  Widget createNodeForm(BuildContext context, {double height}) {
    return Form(
      child: Container(
        height: height - 1,
        width: EditNodeDialog.NodeFormWidth,
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

  double tabsCloseButtonSpacing(double width) {
    var result = width - EditNodeDialog.PortFormWidth + 14;
    if (result < 0) result = 0;
    return result;
  }

  Widget createPortTabs(double width) {
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
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text("Script",
              style: isScriptTab ? _selectedTabStyle : _defaultTabStyle),
          onPressed: selectScriptTab,
        ),
        SizedBox(width: tabsCloseButtonSpacing(width)),
        createIconButton(context, "window-close-solid", onPressed: () {
          widget.close(false);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    var height = EditNodeDialog.EditNodeDialogHeight;
    var width = media.size.width;

    var nodeWidth = EditNodeDialog.NodeFormWidth;
    var portsWidth = width - nodeWidth;

    if (portsWidth < EditNodeDialog.PortFormWidth) {
      portsWidth = EditNodeDialog.PortFormWidth;
    }

    return Container(
      color: Color(0xffeeeeee),
      height: height,
      width: width,
      child: Column(
        children: <Widget>[
          SizedBox(height: 1, child: Container(color: Colors.black)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: nodeWidth + portsWidth,
              child: Row(
                children: <Widget>[
                  createNodeForm(context, height: height),
                  createPortsForm(context, width: portsWidth, height: height),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
