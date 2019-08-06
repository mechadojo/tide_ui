import 'dart:math';

import 'package:flutter_web/material.dart';
import 'font_awesome_icons.dart';

class IconPainter {
  Map<String, Map<double, TextPainter>> iconCache =
      Map<String, Map<double, TextPainter>>();

  Map<IconData, Map<double, TextPainter>> iconDataCache =
      Map<IconData, Map<double, TextPainter>>();

  Color color = Colors.black;

  IconPainter({this.color});

  TextPainter getPainterByIndex(int index, double size) {
    var name = FontAwesomeIcons.nameOf(index);
    return getPainter(name, size);
  }

  TextPainter getIconPainter(IconData icon, double size) {
    var textStyle = TextStyle(
      color: color,
      fontSize: size,
      fontFamily: icon.fontFamily,
    );

    var textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: textStyle,
    );

    var result = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    result.layout(
      minWidth: size / 4,
      maxWidth: size * 2,
    );
    return result;
  }

  TextPainter getPainter(String name, double size) {
    var sizes = iconCache[name];
    TextPainter result;
    if (sizes != null) {
      result = sizes[size];
      if (result != null) {
        return result;
      }
    } else {
      sizes = Map<double, TextPainter>();
      iconCache[name] = sizes;
    }

    var icon = FontAwesomeIcons.getIcon(name);
    result = getIconPainter(icon, size);
    sizes[size] = result;
    return result;
  }

  TextPainter getPainterByData(IconData iconData, double size) {
    var sizes = iconDataCache[iconData];
    TextPainter result;
    if (sizes != null) {
      result = sizes[size];
      if (result != null) {
        return result;
      }
    } else {
      sizes = Map<double, TextPainter>();
      iconDataCache[iconData] = sizes;
    }

    result = getIconPainter(iconData, size);
    sizes[size] = result;
    return result;
  }

  void paintIcon(Canvas canvas, IconData icon, Offset center, double size) {
    var painter = getPainterByData(icon, size);
    var sz = painter.size;
    var topleft = center.translate(-sz.width / 2, -sz.height / 2);
    painter.paint(canvas, topleft);
  }

  void paint(Canvas canvas, String name, Offset center, double size) {
    var painter = getPainter(name, size);

    var sz = painter.size;
    var topleft = center.translate(-sz.width / 2, -sz.height / 2);
    painter.paint(canvas, topleft);
  }

  static String nameOf(int index) {
    return FontAwesomeIcons.nameOf(index);
  }

  static String get random {
    return FontAwesomeIcons.nameOf(
        Random().nextInt(FontAwesomeIcons.names.length));
  }

  Size sizeOfIcon(IconData icon, double size) {
    var painter = getPainterByData(icon, size);
    return painter.size;
  }

  Size sizeOf(String name, double size) {
    var painter = getPainter(name, size);
    return painter.size;
  }
}
