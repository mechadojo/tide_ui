import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/painter/vector_icon_painter.dart';

import 'data/graph_editor_state.dart';
import 'data/graph_input_state.dart';
import 'data/library_state.dart';

class GraphInput extends StatelessWidget {
  final TextStyle _defaultInputStyle =
      TextStyle(fontFamily: "Source Sans Pro", fontSize: 15);
  final TextStyle _defaultLabelStyle = TextStyle(
      background: Graph.CanvasColor,
      fontSize: 13,
      fontFamily: "Source Sans Pro",
      fontWeight: FontWeight.bold);

  final Paint _defaultButtonIcon = Graph.blackPaint;
  final Paint _disabledButtonIcon = Paint()
    ..color = Colors.black.withAlpha(127);
  InputDecoration getBaseTextField({String hintText}) {
    return InputDecoration(
      border: OutlineInputBorder(),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      hintText: hintText,
    );
  }

  Widget createIconButton(
    BuildContext context,
    String icon, {
    VoidCallback onPressed,
    double width = 15,
    double height = 15,
    double size = 12,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
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

  @override
  Widget build(BuildContext context) {
    var editor = Provider.of<GraphEditorState>(context, listen: false);
    var library = Provider.of<LibraryState>(context);
    var input = Provider.of<GraphInputState>(context);

    var media = MediaQuery.of(context);
    var width = media.size.width - library.controller.width;
    var inputWidth = input.size.width;
    if (inputWidth > width) inputWidth = width;
    var left = (width - inputWidth) / 2;

    if (!input.visible) {
      input.hitbox = Rect.zero;
      return Container();
    }

    input.hitbox = Rect.fromLTWH(left, 0, input.size.width, input.size.height);

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: left),
          Container(
            padding: EdgeInsets.all(3),
            width: inputWidth,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: inputWidth - 55,
                      height: input.size.height,
                      child: TextField(
                        controller: input.controller,
                        focusNode: input.focus,
                        style: _defaultInputStyle,
                        enableInteractiveSelection: false,
                        decoration: getBaseTextField(hintText: input.hint),
                      ),
                    ),
                    createIconButton(context, input.cancelButton.icon,
                        onPressed: () {
                      editor.controller.dispatch(input.cancelButton.command);
                    }),
                    createIconButton(context, input.submitButton.icon,
                        onPressed: () {
                      editor.controller.dispatch(input.submitButton.command);
                    }),
                  ],
                ),
                if (input.title != null && input.title.isNotEmpty)
                  Container(
                      child: Row(
                    children: <Widget>[
                      Text(input.title, style: _defaultLabelStyle)
                    ],
                  ))
              ],
            ),
          )
        ]);
  }
}
