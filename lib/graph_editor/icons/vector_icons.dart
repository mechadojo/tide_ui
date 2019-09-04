import 'dart:math';

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
  double scale = 1;

  VectorIcon(this.width, this.height, this.svg) {
    path = parseSvgPathData(svg);
  }

  VectorIcon.named(this.name, this.width, this.height, this.svg) {
    path = parseSvgPathData(svg);
  }

  VectorIcon.scaled(this.name, this.scale, this.width, this.height, this.svg) {
    path = parseSvgPathData(svg);
  }

  void paint(Canvas canvas, Offset pos, double size,
      {Paint fill, Paint stroke, double scale = 1.0}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    scaleTo(canvas, size * scale);

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

  static String getRandomName() {
    return nameOf(Random().nextInt(names.length));
  }

  static VectorIcon getRandom() {
    return getIcon(getRandomName());
  }

  static VectorIcon getIcon(String name) {
    return iconDefinitions[name];
  }

  static void paint(Canvas canvas, String name, Offset pos, double size,
      {Paint fill, Paint stroke}) {
    if (name == null || name.isEmpty) return;
    var icon = iconDefinitions[name];
    if (icon == null) return;

    icon.paint(canvas, pos, size,
        fill: fill, stroke: stroke, scale: icon.scale);
  }
}
