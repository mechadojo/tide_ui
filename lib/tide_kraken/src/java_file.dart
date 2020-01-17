import 'dart:convert';

import 'package:tide_ui/tide_kraken/src/java_block_comment.dart';
import 'package:tide_ui/tide_kraken/src/java_class.dart';
import 'package:tide_ui/tide_kraken/src/java_file_part.dart';
import 'package:tide_ui/tide_kraken/src/java_import.dart';

class JavaFile {
  String name;

  List<String> package = [];
  List<JavaImport> imports = [];
  List<JavaFilePart> content = [];

  JavaClass top;

  void parse(String source) {
    var lines = LineSplitter.split(source);
    int lineno = 0;
    JavaFilePart part; // current part lines are parsing into

    for (var line in lines) {
      lineno++;

      if (part != null) {
        if (part.append(line, lineno)) {
          if (!part.parsing) part = null;
          continue;
        }

        part = null;
      }

      part = append(line, lineno);
      if (part != null) content.add(part);
    }

    for (var part in content) {
      if (part is JavaClass) {
        if (part.isPublic) top = part;
        part.parseBody();
      }
    }
  }

  void parsePackage(String line) {
    package.clear();

    var lower = line.toLowerCase();
    var start = lower.indexOf('package') + 8;
    var end = lower.indexOf(';', start);
    var inner = line.substring(start, end);
    for (var part in inner.split('.')) {
      package.add(part.trim());
    }
  }

  void parseImport(String line) {
    imports.add(JavaImport.parse(line));
  }

  JavaFilePart append(String line, int lineno) {
    var next = line.trim().toLowerCase();
    if (next.isEmpty) return null;

    if (next.startsWith('/*')) {
      return JavaBlockComment()..append(line, lineno);
    } else if (next.startsWith("package ")) {
      parsePackage(line);
    } else if (next.startsWith("import ")) {
      parseImport(line);
    } else if (next.startsWith("@") || next.contains("class ")) {
      return JavaClass()..append(line, lineno);
    }

    // create a single line part
    return JavaFilePart()
      ..append(line, lineno)
      ..parsing = false;
  }
}
