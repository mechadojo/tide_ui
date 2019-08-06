import 'package:flutter_web/material.dart';

import 'vector_icon_definitions.dart';
import '../utility/parse_path.dart' show parseSvgPathData;
import 'vector_icon_definitions.dart' show iconDefinitions;

class VectorIcon {
  int width;
  int height;
  String svg;
  Path path;
  String name;

  VectorIcon(this.width, this.height, this.svg) {
    path = parseSvgPathData(svg);
  }

  void paint(Canvas canvas, Offset pos, double size,
      {Paint fill, Paint stroke}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    scaleTo(canvas, size);

    if (fill != null) {
      canvas.drawPath(path, fill);
    }

    if (stroke != null) {
      canvas.drawPath(path, stroke);
    }

    canvas.restore();
  }

  void scaleTo(Canvas canvas, double size) {
    var xs = size / width;
    var ys = size / height;
    var scale = xs < ys ? xs : ys;
    var cx = -width / 2.0;
    var cy = -height / 2.0;

    canvas.scale(scale, scale);
    canvas.translate(cx, cy);
  }
}

class VectorIcons {
  static List<String> names = iconDefinitions.keys.toList()..sort();

  static String nameOf(int index) {
    var name = names[index % names.length];
    return name;
  }

  static VectorIcon getIconByIndex(int index) {
    return getIcon(nameOf(index));
  }

  static VectorIcon getIcon(String name) {
    return iconDefinitions[name];
  }

  static void paintIcon(Canvas canvas, String name, Offset pos, double size,
      {Paint fill, Paint stroke}) {
    var icon = iconDefinitions[name];
    if (icon == null) return;

    icon.paint(canvas, pos, size, fill: fill, stroke: stroke);
  }
}
