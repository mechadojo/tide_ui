import 'package:flutter_web/material.dart';
import '../utility/parse_path.dart' show parseSvgPathData;

abstract class VectorFontGlyphProvider {
  VectorFontGlyph getGlyph(int codepoint);
  Map<String, String> getFontFace();
}

class VectorFontStyle {
  final VectorFontGlyphProvider glyphs;
  String fontStyle = "Regular";
  double height = 1000;
  int weight = 400;

  VectorFontStyle(this.glyphs);
}

class VectorFont {
  static String testGlyphs =
      r"ABCČĆDĐEFGHIJKLMNOPQRSŠTUVWXYZŽabcčćdđefghijklmnopqrsštuvwxyzžАБВГҐДЂЕЁЄЖЗЅИІЇЙЈКЛЉМНЊОПРСТЋУЎФХЦЧЏШЩЪЫЬЭЮЯабвгґдђеёєжзѕиіїйјклљмнњопрстћуўфхцчџшщъыьэюяΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψωάΆέΈέΉίϊΐΊόΌύΰϋΎΫὰάὲέὴήὶίὸόὺύὼώΏĂÂÊÔƠƯăâêôơư1234567890‘?’“!”(%)[#]{@}/&\<-+÷×=>®©$€£¥¢:;,.*";

  final Map<String, VectorFontStyle> styles = {};

  double spaceWidth = 0;
  int tabSpaces = 4;
  double kerning = 0;
  double lineSpacing = 250;
  double defaultWidth = 1230;

  VectorFont(
      {this.spaceWidth = 250,
      this.kerning = 0,
      this.lineSpacing = 250,
      this.tabSpaces = 4,
      this.defaultWidth = 1230});

  void add(VectorFontGlyphProvider source) {
    var style = VectorFontStyle(source);

    var ff = source.getFontFace();
    var height = ff["cap-height"];
    if (height != null) {
      style.height = double.tryParse(height) ?? style.height;
    }

    var fontStyle = "Regular";

    var weight = ff["font-weight"];
    if (weight != null) {
      style.weight = int.tryParse(weight) ?? style.weight;
    }
    if (style.weight < 400) fontStyle = "Light";
    if (style.weight > 400) fontStyle = "Bold";

    if (ff["font-style"] == "italic") {
      fontStyle += "Italic";
    }

    style.fontStyle = fontStyle;
    styles[fontStyle] = style;
  }

  VectorFontStyle getFontStyle(String style) {
    var font = styles[style];
    if (font == null && style.contains("Italic")) {
      font = styles[style.replaceFirst("Italic", "")];
    }
    return font;
  }

  Iterable<VectorFontGlyph> getGlyphs(String text, double size,
      {String style = "Regular", bool debug = false}) sync* {
    for (var cp in text.codeUnits) {
      if (cp == 32) {
        yield null;
      }

      VectorFontStyle font = getFontStyle(style);
      VectorFontStyle alternate;
      bool hasAlternate = true;

      var glyph = font.glyphs.getGlyph(cp);

      if (glyph == null || glyph.width == 0) {
        if (hasAlternate) {
          if (alternate == null && style.endsWith("Italic")) {
            alternate = styles[style.replaceFirst("Italic", "")];
            if (alternate == null) hasAlternate = false;
          }
          if (alternate != null) glyph = alternate.glyphs.getGlyph(cp);
        }
      }

      if (glyph.width == 0) glyph.width = defaultWidth;

      if (glyph != null && glyph.width != 0) {
        yield glyph;
      }
    }
  }

  Size measure(
    String text,
    double size, {
    String style = "Regular",
  }) {
    var lines = text.split("\n");
    var font = getFontStyle(style);
    var maxWidth = 0.0;
    var dy = 0.0;

    for (var line in lines) {
      double dx = 0;
      for (var glyph in getGlyphs(line, size, style: style)) {
        dx += glyph?.width ?? spaceWidth;
      }

      if (dx > maxWidth) maxWidth = dx;
      if (lines.length > 1) {
        dy += font.height + lineSpacing;
      } else {
        dy += font.height;
      }
    }

    return Size(maxWidth, dy);
  }

  double drawGlyph(
      Canvas canvas, VectorFontGlyph glyph, Paint fill, Paint stroke,
      {bool debug = false}) {
    double dx = 0;

    if (glyph == null) {
      if (debug) print("Space");
      dx = spaceWidth;
    } else {
      if (fill != null) {
        canvas.drawPath(glyph.getPath(), fill);
      }

      if (stroke != null) {
        canvas.drawPath(glyph.getPath(), stroke);
      }
      dx = glyph.width + kerning;
    }

    canvas.translate(dx, 0);
    return dx;
  }

  Rect limits(String text, Offset pos, double size,
      {String style = "Regular",
      double width = double.infinity,
      Alignment alignment = Alignment.bottomLeft}) {
    var font = getFontStyle(style);
    var sz = measure(text, size, style: style);

    if (sz.width > width) {
      sz = Size(width, sz.height);
    }

    sz = Size(sz.width * size / font.height, sz.height * size / font.height);

    //print("Scaled size: $sz");

    var hw = sz.width / 2;
    var hh = sz.height / 2;

    var dx = -hw - hw * alignment.x;
    var dy = -hh + -hh * alignment.y;

    return Rect.fromLTWH(pos.dx + dx, pos.dy + dy, sz.width, sz.height);
  }

  void paint(
    Canvas canvas,
    String text,
    Offset pos,
    double size, {
    Paint fill,
    Paint stroke,
    String style = "Regular",
    double width = double.infinity,
    String ellipsis = "...",
    Alignment alignment = Alignment.bottomLeft,
    bool debug = false,
  }) {
    var font = getFontStyle(style);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    if (width < double.infinity) {
      width = width * font.height / size;
    }

    canvas.scale(size / font.height, -size / font.height);

    if (alignment != Alignment.bottomLeft) {
      var sz = measure(text, size, style: style);

      if (sz.width > width) {
        var dotsz = measure(ellipsis, size, style: style);
        sz = Size(width, sz.height);
        width -= dotsz.width;
      }

      var hw = sz.width / 2;
      var hh = sz.height / 2;

      var ax = -hw - hw * alignment.x;
      var ay = -hh + hh * alignment.y;

      canvas.translate(ax, ay);
    }

    double dy = 0;
    var lines = text.split("\n");
    bool multiline = lines.length > 1;

    for (var line in lines) {
      if (multiline) {
        canvas.save();
        canvas.translate(0, dy);
      }

      line = line.replaceAll("\t", " " * tabSpaces);
      double dx = 0;
      for (var glyph in getGlyphs(line, size, style: style, debug: debug)) {
        dx += drawGlyph(canvas, glyph, fill, stroke, debug: debug);
        if (dx > width) break;
      }

      if (dx > width) {
        for (var glyph in getGlyphs(ellipsis, size, style: style)) {
          drawGlyph(canvas, glyph, fill, stroke);
        }
      }

      if (multiline) {
        canvas.restore();
        dy -= font.height + lineSpacing;
      }
    }

    canvas.restore();
  }
}

class VectorFontGlyph {
  final String name;
  double width;
  final String svg;
  Path _path;

  VectorFontGlyph(this.name, this.width, this.svg);

  Path getPath() {
    if (_path != null) return _path;

    try {
      _path = parseSvgPathData(svg);
    } catch (ex, stack) {
      print("Could not parse '$svg'");
      print(ex.toString());
      print(stack.toString());
    }
    return _path;
  }
}
