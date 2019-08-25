import 'dart:async';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/controller/graph_event.dart';

import 'package:tide_ui/graph_editor/fonts/RobotoMono.dart';
import 'package:tide_ui/graph_editor/fonts/vector_font.dart';

class TextPanel extends StatefulWidget {
  final Size size;
  final TextPanelDocument doc;
  final VoidCallback focus;
  final Widget child;
  final bool focused;
  final Stream<GraphEvent> keys;

  TextPanel(this.doc, this.size, this.focused,
      {this.focus, this.child, this.keys});

  _TextPanelState createState() => _TextPanelState();
}

class _TextPanelState extends State<TextPanel>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController controller;
  bool showCursor = false;
  TextPanelCursor get cursor => widget.doc.cursor;
  TextDocumentController docController;
  StreamSubscription<GraphEvent> keys;

  @override
  void initState() {
    startCursorBlink(1000);
    docController = TextDocumentController(widget.doc, onDocUpdate);

    if (widget.keys != null) {
      keys = widget.keys.listen(docController.onKeyPress);
    }
    super.initState();
  }

  void startCursorBlink(int period) {
    controller = AnimationController(
        duration: Duration(milliseconds: period), vsync: this);

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    keys.cancel();
    controller?.dispose();
    super.dispose();
  }

  void onDocUpdate() {
    setState(() {});
  }

  void onTapDown(Offset pos) {
    if (widget.focus != null && !widget.focused) {
      widget.focus();
    }

    setState(() {
      widget.doc.moveCursor(pos);
      print("Cursor: ${cursor.row}, ${cursor.column}");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focused) {
      _animation = Tween(begin: 0.0, end: 1.0).animate(controller)
        ..addListener(() {
          var nextCursor = _animation.value < 0.5;
          if (nextCursor != showCursor) {
            setState(() {
              showCursor = nextCursor;
            });
          }
        });
      controller.forward();
    } else {
      controller.stop();
      showCursor = false;
    }

    return GestureDetector(
      onTapDown: (evt) {
        RenderBox rb = context.findRenderObject();
        var pt = rb.globalToLocal(evt.globalPosition);
        onTapDown(pt);
      },
      child: RepaintBoundary(
        child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: CustomPaint(
                painter: TextPanelPainter(
                    widget.doc, widget.focused, showCursor ? cursor : null),
                child: widget.child)),
      ),
    );
  }
}

class TextPanelPainter extends CustomPainter {
  final TextPanelDocument doc;
  final bool focused;
  final TextPanelCursor cursor;

  TextPanelPainter(this.doc, this.focused, this.cursor);

  Paint _backFill = Paint()..color = Colors.white;

  Paint _borderPen = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  Paint _focusPen = Paint()
    ..color = Colors.blue
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  Paint _cursorPen = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  Paint _textFill = Paint()..color = TextContentStyle.none.color;
  VectorFont _font = TextContentStyle.none.font;
  double _margin = 10;
  double _size = TextContentStyle.none.size;
  double _lineSpacing = TextContentStyle.none.lineSpacing;

  void drawCursor(Canvas canvas) {
    canvas.drawLine(cursor.start, cursor.end, _cursorPen);
  }

  @override
  void paint(Canvas canvas, size) {
    var clip = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(clip);

    canvas.drawRect(clip, _backFill);
    canvas.drawRect(clip, focused ? _focusPen : _borderPen);

    clip = clip.deflate(_margin);

    double dx = clip.left;
    double dy = clip.top + _lineSpacing + _size;

    for (var block in doc.blocks) {
      for (var line in block.lines) {
        dx = clip.left;

        int idx = 0;

        for (var item in line.content) {
          var pos = Offset(dx, dy);
          var rect = _font.limits(item.content, pos, _size);
          //var p = Paint()..color = Graph.getGroupColor(idx).withAlpha(150);
          //canvas.drawRect(rect, p);
          _font.paint(canvas, item.content, pos, _size, fill: _textFill);

          dx += rect.width;
          idx++;
        }

        dy += _lineSpacing + _size;
      }
    }

    if (cursor != null) {
      drawCursor(canvas);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TextPanelCursor {
  TextBlock block;
  TextLine line;
  TextContent content;

  int get lineIndex => block?.lines?.indexOf(line) ?? 0;

  int row = 0;
  int column = 0;
  int offset = 0;

  Offset start = Offset.zero;
  Offset end = Offset.zero;
}

class TextPanelDocument {
  List<TextBlock> blocks = [];
  List<TextDocumentDelta> history = [];
  List<TextDocumentDelta> redoHistory = [];

  TextContentStyle style = TextContentStyle.none;
  TextPanelCursor cursor = TextPanelCursor();
  double margin = 10;

  TextPanelCursor updateCursor() {
    double dy = margin;
    double dx = margin;
    int row = 0;
    int column = 0;
    double offsetY = 1;
    double extraY = 3;

    cursor.block = null;
    cursor.line = null;
    cursor.content = null;

    for (var block in blocks) {
      var blockstyle =
          block.style == null ? style : style.copyWith(block.style);

      cursor.line = block.lines.isEmpty ? null : block.lines.first;
      cursor.content = cursor.line?.content?.first;

      for (var line in block.lines) {
        var linestyle =
            line.style == null ? blockstyle : blockstyle.copyWith(line.style);

        var startY = dy;
        var endY = startY + linestyle.size + linestyle.lineSpacing;
        column = 0;
        dx = margin + style.indent * style.indentSize;

        if (row == cursor.row) {
          cursor.block = block;
          cursor.line = line;
          cursor.start = Offset(dx, startY + offsetY);
          cursor.end = Offset(dx, endY + extraY);

          for (var item in line.content) {
            cursor.content = item;
            cursor.offset = 0;

            if (item.content.isEmpty) continue;

            var contentstyle =
                item.style == null ? linestyle : linestyle.copyWith(item.style);

            var rect = contentstyle.font
                .limits(item.content, Offset(dx, dy), contentstyle.size);

            if (cursor.column >= column &&
                cursor.column < column + item.content.length) {
              cursor.offset = cursor.column - column;
              var cx = rect.width / item.content.length;
              dx += cx * cursor.offset;
              cursor.start = Offset(dx, startY + offsetY);
              cursor.end = Offset(dx, endY + extraY);
              return cursor;
            }

            cursor.offset += item.content.length;
            column += item.content.length;
            dx += rect.width;
          }

          cursor.start = Offset(dx, startY + offsetY);
          cursor.end = Offset(dx, endY + extraY);
          cursor.column = column;
          return cursor;
        }

        row++;
        dy = endY;
      }
    }

    cursor.row = row;
    cursor.column = column;
    cursor.block = null;
    cursor.line = null;
    cursor.content = null;
    cursor.start = Offset(margin, dy + offsetY);
    cursor.end = Offset(margin, dy + style.lineSpacing + style.size + extraY);
    return cursor;
  }

  void removeNext() {
    if (cursor.content != null) {
      var item = cursor.content;

      if (cursor.offset >= item.length) {
        var idx = cursor.lineIndex + 1;

        if (idx < cursor.block.lines.length) {
          var next = cursor.block.lines.removeAt(idx);
          cursor.line.content.addAll(next.content);
        } else {
          var bidx = blocks.indexOf(cursor.block) + 1;
          if (bidx < blocks.length && blocks[bidx].lines.isNotEmpty) {
            var next = blocks[bidx].lines.removeAt(0);
            cursor.line.content.addAll(next.content);
          }
        }
      } else {
        var front = item.content.substring(0, cursor.offset);
        var back = item.content.substring(cursor.offset);

        if (back.length > 1) {
          item.content = front + back.substring(1);
        } else {
          item.content = front;
        }
      }
    }

    trimContent();
  }

  void trimContent() {
    for (var block in blocks) {
      for (var line in block.lines) {
        if (line.content.length > 1) {
          line.content = line.content.where((x) => x.isNotEmpty).toList();
        }
      }
    }

    updateCursor();
  }

  void movePrev() {
    cursor.column--;
    if (cursor.column < 0) {
      cursor.column = 9999999;
      cursor.row--;
    }
    if (cursor.row < 0) {
      cursor.row = 0;
      cursor.column = 0;
    }

    updateCursor();
  }

  void removeText(int count) {
    if (count < 0) {
      count = -count;
      for (int i = 0; i < count; i++) {
        movePrev();
        removeNext();
      }
    } else {
      for (int i = 0; i < count; i++) {
        removeNext();
      }
    }
  }

  void insertText(List<String> lines, {TextContentStyle style}) {
    if (cursor.content != null) {
      var item = cursor.content;
      if (cursor.offset >= item.content.length) {
        item.content = item.content + lines.first;
        var idx = cursor.lineIndex + 1;

        for (var line in lines.skip(1)) {
          cursor.block.lines.insert(idx, TextLine.text(line));
          idx++;
        }
      } else {
        var front = item.content.substring(0, cursor.offset);
        var back = item.content.substring(cursor.offset);

        if (lines.length > 1) {
          item.content = front + lines.first;

          List<TextContent> after = [];

          var cidx = cursor.line.content.indexOf(item) + 1;
          if (cidx < cursor.line.content.length) {
            var before = cursor.line.content.take(cidx).toList();
            after = cursor.line.content.skip(cidx).toList();
            cursor.line.content = before;
          }

          var idx = cursor.lineIndex + 1;

          for (int i = 1; i < lines.length - 1; i++) {
            cursor.block.lines.insert(idx, TextLine.text(lines[i]));
            idx++;
          }

          var last = TextLine.text(lines.last + back);
          last.content.addAll(after);
          cursor.block.lines.insert(idx, last);
        } else {
          item.content = front + lines.first + back;
        }
      }
    } else {
      if (blocks.isEmpty) {
        blocks.add(TextBlock.text(lines.first));
      } else {
        blocks.last.lines.add(TextLine.text(lines.first));
      }

      for (var line in lines.skip(1)) {
        blocks.last.lines.add(TextLine.text(line));
      }
    }

    if (lines.length > 1) {
      cursor.row += lines.length - 1;
      cursor.column = lines.last.length;
    } else {
      cursor.column += lines.first.length;
    }

    updateCursor();
  }

  void clear() {
    blocks.clear();
    history.clear();
    redoHistory.clear();
  }

  void undo() {
    if (history.isNotEmpty) {
      var last = history.removeLast();
      redoHistory.add(last);

      blocks.clear();
      for (var delta in history) {
        apply(delta, save: false);
      }
    }
  }

  void redo() {
    if (redoHistory.isNotEmpty) {
      var last = redoHistory.removeLast();
      apply(last, clearRedo: false);
    }
  }

  void apply(TextDocumentDelta delta,
      {bool save = true, bool clearRedo = true}) {
    if (save) {
      history.add(delta);
      if (clearRedo) {
        redoHistory.clear();
      }
    }

    //print("Apply: $delta");

    moveTo(delta);

    switch (delta.type) {
      case TextDeltaType.none:
        break;
      case TextDeltaType.add:
        insertText(delta.lines, style: delta.style);
        break;
      case TextDeltaType.remove:
        removeText(delta.count);
        break;
      case TextDeltaType.update:
        break;
      case TextDeltaType.replace:
        break;
    }
  }

  void moveTo(TextDocumentDelta delta) {
    cursor.row = delta.row;
    cursor.column = delta.column;
    updateCursor();
  }

  void moveCursor(Offset pos) {
    cursor = getCursor(pos);
  }

  TextPanelCursor getCursor(Offset pos) {
    double dy = margin;
    double dx = margin;
    int row = 0;
    int column = 0;
    double offsetY = 1;
    double extraY = 3;

    if (pos.dy < dy) {
      return TextPanelCursor()
        ..block = blocks.first
        ..line = blocks.first?.lines?.first
        ..start = Offset(dx, dy + offsetY)
        ..end = Offset(dx, dy + style.lineSpacing + style.size + extraY);
    }

    for (var block in blocks) {
      var blockstyle =
          block.style == null ? style : style.copyWith(block.style);

      for (var line in block.lines) {
        var linestyle =
            line.style == null ? blockstyle : blockstyle.copyWith(line.style);

        var startY = dy;
        var endY = startY + linestyle.size + linestyle.lineSpacing;

        if (pos.dy >= startY && pos.dy < endY) {
          column = 0;
          dx = margin + style.indent * style.indentSize;

          var result = TextPanelCursor()
            ..block = block
            ..line = line
            ..row = row
            ..column = column
            ..start = Offset(dx, startY + offsetY)
            ..end = Offset(dx, endY + extraY);

          if (pos.dx < dx) {
            return result;
          }

          for (var item in line.content) {
            result.offset = 0;
            result.content = item;
            result.column = column;

            if (item.content.isEmpty) continue;

            var contentstyle =
                item.style == null ? linestyle : linestyle.copyWith(item.style);

            var rect = contentstyle.font
                .limits(item.content, Offset(dx, dy), contentstyle.size);

            if (pos.dx >= rect.left && pos.dx < rect.right) {
              result.content = item;
              var ix = pos.dx - rect.left;
              var cx = rect.width / item.content.length;
              result.offset = (ix * item.content.length / rect.width).floor();

              column += result.offset;

              dx += cx * result.offset;
              result.column = column;
              result.start = Offset(dx, startY + offsetY);
              result.end = Offset(dx, endY + extraY);

              return result;
            }

            result.offset += item.content.length;
            column += item.content.length;
            dx += rect.width;
          }

          result.column = column;
          result.start = Offset(dx, startY + offsetY);
          result.end = Offset(dx, endY + extraY);
          return result;
        }

        row++;
        dy = endY;
      }
    }

    return TextPanelCursor()
      ..row = row
      ..column = 0
      ..start = Offset(margin, dy)
      ..end = Offset(margin, dy + style.lineSpacing + style.size);
  }

  void remove(int count) {
    var delta = TextDocumentDelta.remove(cursor, count);
    apply(delta);
  }

  void add(String text, {TextContentStyle style}) {
    var delta = TextDocumentDelta.add(cursor, text, style: style);
    apply(delta);
  }
}

enum TextDeltaType { none, add, remove, update, replace }

class TextDocumentDelta {
  int row = 0;
  int column = 0;
  int count = 0;
  List<String> lines = [];
  TextDeltaType type = TextDeltaType.none;
  TextContentStyle style;

  set text(String text) {
    var tabs = (this.style ?? TextContentStyle.none).tabs;
    this.lines = text
        .split("\n")
        .map((x) => x.replaceAll("\r", "").replaceAll("\t", tabs))
        .toList();
  }

  TextDocumentDelta.remove(TextPanelCursor cursor, int count) {
    type = TextDeltaType.remove;
    row = cursor.row;
    column = cursor.column;
    this.count = count;
  }

  TextDocumentDelta.add(TextPanelCursor cursor, String text,
      {TextContentStyle style}) {
    type = TextDeltaType.add;
    row = cursor.row;
    column = cursor.column;
    this.style = style?.copy();
    this.text = text ?? "";
  }

  TextDocumentDelta.none(TextPanelCursor cursor) {
    row = cursor.row;
    column = cursor.column;
  }

  TextDocumentDelta.replace(TextPanelCursor cursor, String text, int count,
      {TextContentStyle style}) {
    type = TextDeltaType.replace;
    row = cursor.row;
    column = cursor.column;
    this.count = count;
    this.style = style?.copy();
    this.text = text ?? "";
  }

  TextDocumentDelta.update(TextPanelCursor cursor,
      {TextContentStyle style, int count = 0}) {
    type = TextDeltaType.update;
    row = cursor.row;
    column = cursor.column;
    this.count = count;
    this.style = style?.copy();
  }

  @override
  String toString() {
    var typename = type.toString().split(".").last;
    var value = lines.join(r"\n");

    return "[$typename] ($row,$column) : '$value'";
  }
}

enum TextContentStyleType {
  text,
  keyword,
  syntax,
  variable,
  string,
  literal,
  comment
}

class TextContentStyle {
  VectorFont _font = RobotoMonoFont;
  TextContentStyleType _type = TextContentStyleType.text;
  Color _color = Colors.black;
  double _size = 10;
  double _lineSpacing = 3;
  String _tabs = "  ";

  double get indentSize =>
      _font.defaultWidth * _size / font.getFontStyle(_style).height;

  String _style = "Regular";
  int _outline = 0;
  int _indent = 0;

  String get tabs => _tabs;
  set tabs(String tabs) {
    _tabs = tabs ?? none.tabs;
    hasTabs = tabs != null;
  }

  VectorFont get font => _font;
  set font(VectorFont font) {
    _font = font ?? none.font;
    hasFont = font != null;
  }

  TextContentStyleType get type => _type;
  set type(TextContentStyleType type) {
    _type = type ?? none.type;
    hasType = type != null;
  }

  Color get color => _color;
  set color(Color color) {
    _color = color ?? none.color;
    hasColor = color != null;
  }

  double get size => _size;
  set size(double size) {
    _size = size ?? none.size;
    hasSize = size != null;
  }

  double get lineSpacing => _lineSpacing;
  set lineSpacing(double lineSpacing) {
    _lineSpacing = lineSpacing ?? none.lineSpacing;
    hasLineSpacing = lineSpacing != null;
  }

  String get style => _style;
  set style(String style) {
    _style = style ?? none.style;
    hasStyle = style != null;
  }

  int get outline => _outline;
  set outline(int outline) {
    _outline = outline ?? none.outline;
    hasOutline = outline != null;
  }

  int get indent => _indent;
  set indent(int indent) {
    _indent = indent ?? none.indent;
    hasIndent = indent != null;
  }

  bool hasFont = false;
  bool hasType = false;
  bool hasColor = false;
  bool hasSize = false;
  bool hasLineSpacing = false;
  bool hasStyle = false;
  bool hasOutline = false;
  bool hasIndent = false;
  bool hasTabs = false;

  static TextContentStyle none = TextContentStyle();

  TextContentStyle copy() {
    var result = TextContentStyle()
      .._font = this.font
      .._type = this.type
      .._color = this.color
      .._size = this.size
      .._lineSpacing = this.lineSpacing
      .._style = this.style
      .._outline = this.outline
      .._indent = this.indent
      .._tabs = this.tabs
      ..hasFont = this.hasFont
      ..hasType = this.hasType
      ..hasColor = this.hasColor
      ..hasSize = this.hasSize
      ..hasLineSpacing = this.hasLineSpacing
      ..hasStyle = this.hasStyle
      ..hasOutline = this.hasOutline
      ..hasIndent = this.hasIndent
      ..hasTabs = this.hasTabs;

    return result;
  }

  TextContentStyle copyWith(TextContentStyle other) {
    var result = copy();
    if (other != null) {
      if (other.hasFont) result.font = other.font;
      if (other.hasType) result.type = other.type;
      if (other.hasColor) result.color = other.color;
      if (other.hasSize) result.size = other.size;
      if (other.hasLineSpacing) result.lineSpacing = other.lineSpacing;
      if (other.hasStyle) result.style = other.style;
      if (other.hasOutline) result.outline = other.outline;
      if (other.hasIndent) result.indent = other.indent;
      if (other.hasTabs) result.tabs = other.tabs;
    }
    return result;
  }
}

enum TextBlockType {
  text,
  comment,
}

class TextBlock {
  TextContentStyle style;
  TextBlockType type = TextBlockType.text;

  List<TextLine> marginStart = [];
  List<TextLine> lines = [];
  List<TextLine> marginEnd = [];

  TextBlock.text(String text) {
    for (var line in text.split("\n")) {
      line = line.replaceAll("\r", "");

      lines.add(TextLine.text(line));
    }
  }
}

class TextLine {
  TextContentStyle style;
  List<TextContent> margin = [];
  List<TextContent> content = [];
  List<TextContent> comment = [];

  TextLine.text(String text) {
    content.add(TextContent.text(text));
  }
}

enum TextContentType { text, icon }

class TextContent {
  TextContentStyle style;
  TextContentType type = TextContentType.text;
  String content;

  bool get isNotEmpty => length > 0;
  bool get isEmpty => length == 0;

  int get length {
    if (type == TextContentType.text) {
      return (content ?? "").length;
    }

    return 1;
  }

  TextContent.text(String text) {
    type = TextContentType.text;
    content = text;
  }

  TextContent.icon(String icon) {
    type = TextContentType.icon;
    content = icon;
  }
}

class TextDocumentController {
  final TextPanelDocument doc;
  final VoidCallback update;
  TextPanelCursor get cursor => doc.cursor;

  TextDocumentController(this.doc, this.update);

  void onKeyPress(GraphEvent evt) {
    if (handleKeyPress(evt)) {
      update();
    }
  }

  bool handleNavigation(GraphEvent evt) {
    if (evt.key == "Home") {
      cursor.column = 0;
      if (evt.ctrlKey) {
        cursor.row = 0;
      }

      doc.updateCursor();
      return true;
    }

    if (evt.key == "End") {
      cursor.column = 9999999;
      if (evt.ctrlKey) {
        cursor.row = 9999999;
      }

      doc.updateCursor();
      return true;
    }

    if (evt.key == "ArrowLeft") {
      if (evt.ctrlKey && cursor.content != null) {
        if (cursor.offset == 0) {
          var cidx = cursor.line.content.indexOf(cursor.content);
          if (cidx > 0) {
            cursor.column -= cursor.line.content[cidx - 1].length;
          }
        } else {
          cursor.column -= cursor.offset;
        }
      } else {
        cursor.column--;
      }

      if (cursor.column < 0) {
        cursor.column = 0;
      }

      doc.updateCursor();
      return true;
    }

    if (evt.key == "ArrowUp") {
      cursor.row--;
      if (cursor.row < 0) {
        cursor.row = 0;
      }

      doc.updateCursor();
      return true;
    }

    if (evt.key == "ArrowRight") {
      if (evt.ctrlKey && cursor.content != null) {
        cursor.column += (cursor.content.length - cursor.offset);
      } else {
        cursor.column++;
      }
      doc.updateCursor();
      return true;
    }

    if (evt.key == "ArrowDown") {
      cursor.row++;
      doc.updateCursor();
      return true;
    }

    return false;
  }

  bool handleDelete() {
    doc.remove(1);
    return true;
  }

  bool handleBackspace() {
    doc.remove(-1);
    /*
    if (cursor.content != null) {
      if (cursor.column == 0) {
      } else {
        var item = cursor.content;
        if (cursor.offset >= item.content.length) {
          item.content = item.content.substring(0, item.content.length - 1);
          cursor.column--;
        } else {
          var front = item.content.substring(0, cursor.offset);
          var back = item.content.substring(cursor.offset);

          item.content = front.substring(0, front.length - 1) + back;
          cursor.column--;
        }
      }
    }

    doc.updateCursor();
    */
    return true;
  }

  bool handleHotkeys(GraphEvent evt) {
    if (evt.ctrlKey) {
      var key = evt.key.toLowerCase();

      switch (key) {
        case "v":
          return handleInsertText("This is a test\nThis is only a test.\n");
          break;
        case "z":
          doc.undo();
          return true;
        case "y":
          doc.redo();
          return true;
      }
      print("Ctrl+$key");
    }

    return evt.ctrlKey;
  }

  bool handleInsertText(String text) {
    doc.add(text);
    return true;
  }

  bool handleKeyPress(GraphEvent evt) {
    if (evt.key == "Control" || evt.key == "Shift" || evt.key == "Alt") {
      return true;
    }

    if (handleNavigation(evt)) return true;
    if (evt.key == "Enter") return handleInsertText("\n");
    if (evt.key == "Backspace") return handleBackspace();
    if (evt.key == "Delete") return handleDelete();

    if (handleHotkeys(evt)) return true;

    if (evt.key.length == 1) {
      return handleInsertText(evt.key);
    } else {
      print(evt.key);
    }

    return false;
  }
}