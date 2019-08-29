import 'dart:async';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/controller/graph_editor_controller.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'package:tide_ui/widgets/text_panel.dart';

import 'controller/graph_event.dart';
import 'data/graph.dart';
import 'data/graph_property_set.dart';
import 'data/graph_state.dart';
import 'painter/vector_icon_painter.dart';

class EditGraphDialog extends StatefulWidget {
  static double EditNodeDialogHeight = 225;
  static double PropsFormWidth = 435;
  static double GraphFormWidth = 285;
  static double CloseButtonWidth = 25;

  final GraphEditorController editor;
  final GraphState graph;

  final GraphDialogResult close;
  final TextPanelDocument script = TextPanelDocument();
  final String title;

  EditGraphDialog(this.editor, this.graph, this.close, {this.title});

  _EditGraphDialogState createState() => _EditGraphDialogState();
}

class _EditGraphDialogState extends State<EditGraphDialog> {
  GraphState get graph => widget.graph;

  GraphEditorController get editor => widget.editor;

  final titleController = TextEditingController();
  final iconController = TextEditingController();
  final scriptController = StreamController<GraphEvent>();

  final propNameController = TextEditingController();
  final propValueController = TextEditingController();

  final titleFocus = FocusNode();
  final iconFocus = FocusNode();
  final scriptFocus = FocusNode();

  final propNameFocus = FocusNode();
  final propValueFocus = FocusNode();

  TextPanelDocument get scriptDocument => widget.script;

  int autoCompleteIndex = 0;
  String autoCompletePrefix;
  TextStyle _defaultInputStyle = TextStyle(fontFamily: "Source Sans Pro");
  // TextStyle _defaultTextStyle =
  //     TextStyle(fontSize: 15, fontFamily: "Source Sans Pro");
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

  String selectedTab = "props";

  bool get isPropsTab => selectedTab == "props";
  bool get isScriptTab => selectedTab == "script";

  GraphProperty selectedProp;
  GlobalKey selectedPortKey = GlobalKey();

  bool scriptFocused = false;
  Stream<GraphEvent> scriptKeys;
  double offsetValue = 1;
  double offsetMirror = 0;

  @override
  void dispose() {
    titleFocus?.dispose();

    iconFocus?.dispose();
    scriptFocus?.dispose();
    propNameFocus?.dispose();
    propValueFocus?.dispose();

    titleController?.dispose();
    iconController?.dispose();

    propNameController?.dispose();
    propValueController?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    editor.bottomSheetHeight = EditGraphDialog.EditNodeDialogHeight;

    scriptDocument
      ..add(graph.script ?? "")
      ..home();

    scriptKeys = scriptController.stream.asBroadcastStream();

    titleController
      ..text = graph.title
      ..addListener(updateTitle);

    iconController
      ..text = graph.icon
      ..addListener(updateIcon);

    iconFocus
      ..addListener(
          onChangeFocus(iconFocus, iconController, titleFocus, titleFocus));

    titleFocus
      ..addListener(
          onChangeFocus(titleFocus, titleController, iconFocus, iconFocus));

    propNameController
      ..text = selectedProp?.name
      ..addListener(updatePropName);

    propValueController
      ..text = selectedProp?.getValue()
      ..addListener(updatePropValue);

    propNameFocus
      ..addListener(onChangeFocus(
          propNameFocus, propNameController, propValueFocus, propValueFocus,
          onLoseFocus: updatePropsFields));

    propValueFocus
      ..addListener(onChangeFocus(
          propValueFocus, propValueController, propNameFocus, propNameFocus,
          onLoseFocus: updatePropsFields));

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

    if (!editor.isTouchMode) {
      editor.dispatch(GraphEditorCommand.requestFocus(titleFocus),
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
    if (isPropsTab && graph.props.values.isEmpty) return;
    if (isScriptTab) return;

    editor.dispatch(GraphEditorCommand.ensureVisible(selectedPortKey),
        afterTicks: 2);
  }

  void updatePropsFields() {
    if (graph.props.values.isEmpty) selectedProp = null;

    var value = selectedProp?.name ?? "";

    if (selectedProp == null || propNameController.text != selectedProp?.name) {
      propNameController.value = propNameController.value.copyWith(
          composing: TextRange.empty,
          selection: TextSelection.collapsed(offset: 0),
          text: value);
    }

    value = selectedProp?.getValue() ?? "";
    if (selectedProp == null || propValueController.text != value) {
      propValueController.value = propValueController.value.copyWith(
          composing: TextRange.empty,
          selection: TextSelection.collapsed(offset: 0),
          text: value);
    }
  }

  void updateScriptFields() {}

  void selectProp(GraphProperty prop) {
    setState(() {
      selectedProp = prop;
      offsetMirror = 0;
      offsetValue = 1;

      updatePropsFields();
      update();
      ensureSelectedPortVisible();
    });
  }

  void selectPropsTab() {
    setState(() {
      selectedTab = "props";
      if (selectedProp != null) {
        if (!graph.props.values.any((x) => x == selectedProp)) {
          selectedProp = null;
        }
      }

      if (selectedProp == null) {
        selectedProp =
            graph.props.values.isEmpty ? null : graph.props.values.first;
      }

      updatePropsFields();
      if (selectedProp != null) {
        ensureSelectedPortVisible();
      }
    });
  }

  void selectScriptTab() {
    setState(() {
      selectedTab = "script";
      editor.tabFocus = (reversed) {
        print("Script Tab: $reversed");
      };

      updateScriptFields();
    });
  }

  List<Widget> getPortList() {
    switch (selectedTab) {
      case "props":
        return graph.props.values.map(getPropListItem).toList();
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

  String getNextPropertyName(String type) {
    var index = 1;
    var prefix = getPropTypePrefix(type);

    for (var val in graph.props.values) {
      if (val.name.startsWith(prefix)) {
        var idx = int.tryParse(val.name.substring(prefix.length));
        if (idx != null && idx >= index) index = idx + 1;
      }
    }
    return "$prefix$index";
  }

  void onCopyProps() {
    setState(() {
      editor.graphPropsClipboard = graph.props.packList();
    });
  }

  void onPasteProps() {
    setState(() {
      var props = GraphPropertySet.unpack(editor.graphPropsClipboard);
      for (var prop in props.values) {
        graph.props.replace(prop);
      }
    });
  }

  void onAddProperty() {
    var prop = GraphProperty.asString(getNextPropertyName("String"), "value");

    graph.props.add(prop);

    selectProp(prop);

    requestFocus(propNameFocus);
  }

  void onDeleteProperty() {
    if (selectedProp == null) return;

    var values = graph.props.values.toList();
    var idx = values.indexWhere((x) => x.name == selectedProp.name);
    if (idx < 0) return;

    graph.props.remove(selectedProp.name);
    values.removeAt(idx);
    if (idx >= values.length - 1) idx = values.length - 1;

    selectProp(idx < 0 ? null : values[idx]);
  }

  VoidCallback onChangeFocus(FocusNode focus, TextEditingController controller,
      FocusNode prev, FocusNode next,
      {VoidCallback onLoseFocus}) {
    return () {
      if (focus.hasFocus) {
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
    editor.updateGraph(graph);
    editor.graph.endUpdate(true);
  }

  void updateTitle() {
    graph.title = titleController.text;
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
    graph.icon = icon;
    update();
  }

  void updateScript() {}

  void updateIcon() {
    var text = iconController.text.toLowerCase();
    if (VectorIcons.names.contains(text)) {
      graph.icon = text;
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

  void updatePropName() {
    if (selectedProp == null) return;

    setState(() {
      var next = propNameController.text.trim().replaceAll(" ", "_");
      var values = graph.props.values.toList();

      var replace = values.any((x) => x != selectedProp && x.name == next);
      if (replace) next = "${next}_";

      graph.props.rename(selectedProp.name, next);

      update();
    });
  }

  String getPropTypePrefix(String type) {
    var prefix = "text";
    if (type == "Integer" || type == "Double") prefix = "num";
    if (type == "Boolean") prefix = "flag";
    return prefix;
  }

  void updateGraphType(String value) {
    setState(() {
      if (value == "Behavior") graph.type = GraphType.behavior;
      if (value == "OpMode") graph.type = GraphType.opmode;
      update();
    });
  }

  void updateOpmodeType(String value) {
    setState(() {
      graph.settings.replace(GraphProperty.asString("opmode_type", value));
      update();
    });
  }

  void updatePropType(String value) {
    if (selectedProp == null) return;

    offsetMirror = 0;
    offsetValue = 1;

    var lastPrefix = getPropTypePrefix(selectedProp.getValueType());

    var next =
        GraphProperty.parse(selectedProp.name, selectedProp.getValue(), value);

    if (next == null) return;

    graph.props.replace(next);

    var nextPrefix = getPropTypePrefix(next.getValueType());
    if (next.name.startsWith(lastPrefix)) {
      var nn = next.name.replaceFirst(lastPrefix, nextPrefix);
      if (graph.props.values.any((x) => x != next && x.name == nn)) {
        nn = getNextPropertyName(next.getValueType());
      }

      graph.props.rename(next.name, nn);
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
    //graph.requestFocus();
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
        enabled: graph.props.values.isNotEmpty,
        focusNode: propValueFocus,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(propNameFocus);
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

  Widget createGraphTypeRow(BuildContext context, {double width = 150}) {
    return createLabeledRow("Type", width: width, children: [
      Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: graph.typeName,
                value: "Behavior",
                onChanged: updateGraphType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Behavior", style: _defaultLabelStyle),
          ],
        ),
      ),
      Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: graph.typeName,
                value: "OpMode",
                onChanged: updateGraphType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("OpMode", style: _defaultLabelStyle),
          ],
        ),
      ),
    ]);
  }

  Widget createOpmodeTypeRow(BuildContext context, {double width = 150}) {
    return createLabeledRow("", width: width, children: [
      Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: graph.settings.getString("opmode_type", "Auto"),
                value: "Auto",
                onChanged: updateOpmodeType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Auto", style: _defaultLabelStyle),
          ],
        ),
      ),
      Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
                groupValue: graph.settings.getString("opmode_type", "Auto"),
                value: "Teleop",
                onChanged: updateOpmodeType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text("Teleop", style: _defaultLabelStyle),
          ],
        ),
      ),
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

  Widget createPropsButtons(BuildContext context) {
    return Column(
      children: <Widget>[
        createIconButton(context, "plus-square-solid",
            onPressed: onAddProperty),
        createIconButton(context, "trash-alt-solid",
            onPressed: onDeleteProperty),
        createIconButton(context, "copy-solid",
            onPressed: graph.props.values.isEmpty ? null : onCopyProps),
        createIconButton(context, "paste",
            onPressed:
                editor.graphPropsClipboard.isEmpty ? null : onPasteProps),
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

  Iterable<Widget> getPropsFormFields(BuildContext context) sync* {
    yield createTextField(context, "Name", propNameController,
        enabled: graph.props.values.isNotEmpty,
        width: 185,
        focus: propNameFocus);

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

      if (isPropsTab) {
        yield createPropsButtons(context);
        yield Column(
          children: <Widget>[...getPropsFormFields(context)],
        );
      }
    }
  }

  Widget createPropsForm(BuildContext context, {double width, double height}) {
    return Form(
      child: Container(
          height: height - 1,
          width: width,
          padding: EdgeInsets.only(right: 10, bottom: 5),
          child: Column(
            children: <Widget>[
              createTabs(width - 10),
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
      bool enabled = true,
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
              enabled: enabled,
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

  Widget createDebugRow({double width = 150}) {
    return createLabeledRow("Debug", width: width, children: [
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: graph.isDebugging,
        onChanged: (value) {
          setState(() {
            graph.isDebugging = value;
            update();
          });
        },
      ),
      Text("Log:", style: _defaultLabelStyle),
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: graph.isLogging,
        onChanged: (value) {
          setState(() {
            graph.isLogging = value;
            update();
          });
        },
      ),
    ]);
  }

  Widget createGraphForm(BuildContext context, {double height}) {
    var title = widget.title ?? "Edit ${graph.typeName}";

    return Form(
      child: Container(
        height: height - 1,
        width: EditGraphDialog.GraphFormWidth,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: EditGraphDialog.GraphFormWidth - 20,
                padding: EdgeInsets.only(bottom: 2),
                child: Text(title, style: _defaultHeaderStyle)),
            createTextField(context, "Icon", iconController,
                width: 200, focus: iconFocus, next: titleFocus),
            createTextField(context, "Title", titleController,
                width: 200, focus: titleFocus, next: iconFocus, padding: 5),
            if (graph.type == GraphType.behavior ||
                graph.type == GraphType.opmode)
              createGraphTypeRow(context, width: 200),
            if (graph.type == GraphType.opmode)
              createOpmodeTypeRow(context, width: 200),
            createDebugRow(width: 200),
          ],
        ),
      ),
    );
  }

  double tabsCloseButtonSpacing(double width) {
    var result = width;
    if (result < 0) result = 0;
    return result;
  }

  Widget createTabs(double width) {
    return Container(
      width: width,
      child: Row(
        children: <Widget>[
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
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (graph.type == GraphType.behavior ||
                      graph.type == GraphType.opmode)
                    createIconButton(context, "share-square-solid",
                        onPressed: () {
                      widget.close(true);
                      print("Add to templates");
                    }),
                  if (graph.type == GraphType.behavior)
                    createIconButton(context, "calendar-plus", onPressed: () {
                      widget.close(true);
                      print("Convert to library");
                    }),
                  createIconButton(context, "trash-alt", onPressed: () {
                    widget.close(false);
                    editor.dispatch(GraphEditorCommand.deleteGraph(graph));
                  }),
                  createIconButton(context, "window-close-solid",
                      onPressed: () {
                    widget.close(false);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    var height = EditGraphDialog.EditNodeDialogHeight;
    var width = media.size.width;

    var graphWidth = EditGraphDialog.GraphFormWidth;
    var propsWidth = width - graphWidth;

    if (propsWidth < EditGraphDialog.PropsFormWidth) {
      propsWidth = EditGraphDialog.PropsFormWidth;
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
              width: graphWidth + propsWidth,
              child: Row(
                children: <Widget>[
                  createGraphForm(context, height: height),
                  createPropsForm(context, width: propsWidth, height: height),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
