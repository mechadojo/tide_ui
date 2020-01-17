import 'package:tide_ui/tide_kraken/src/java_file_part.dart';

import 'java_annotation.dart';
import 'java_field.dart';
import 'java_method.dart';
import 'java_variable.dart';

class JavaClass extends JavaFilePart {
  String name;
  bool isFinal = false;
  bool isPublic = false;
  List<JavaAnnotation> annotations = [];
  List<String> extendsClasses = [];
  List<String> body = [];

  List<JavaMethod> methods = [];
  List<JavaVariable> props = [];

  int _braceCount = 0;
  bool _parseClass = false;
  bool _parseExtends = false;

  /// Extracts method arguments
  List<JavaField> parseArgsLine(String line) {
    List<JavaField> result = [];

    var left = line;
    var end = line.indexOf(')');

    if (end >= 0) {
      left = left.substring(0, end);
    }

    end = line.indexOf(';');
    if (end >= 0) {
      left = left.substring(0, end);
    }

    List<String> typeName = [];
    List<String> fieldName = [];
    bool parseBrackets = false;
    bool parseType = true;

    for (var c in left.split('')) {
      if (parseType) {
        typeName.add(c);

        if (parseBrackets) {
          if (c == '>') {
            parseBrackets = false;
            parseType = false;
            continue;
          }
        } else {
          if (c == '<') {
            parseBrackets = true;
          } else if (c == ' ') {
            parseType = false;
          }
        }
      } else {
        if (c == ',') {
          result.add(JavaField()
            ..type = typeName.join('').trim()
            ..name = fieldName.join('').trim());
          typeName.clear();
          fieldName.clear();
          parseType = true;
        } else {
          fieldName.add(c);
        }
      }
    }

    if (!parseType) {
      result.add(JavaField()
        ..type = typeName.join('').trim()
        ..name = fieldName.join('').trim());
    }

    return result;
  }

  /// Extracts methods and class variables from the class body
  void parseBody() {
    List<String> notes = [];

    bool parseArgs = false;
    bool parseMethod = false;
    bool parseMethodBody = false;

    bool parseClass = false;
    bool parseClassBody = false;

    bool parseEnum = false;
    bool parseEnumBody = false;

    int methodBraces = 0;
    int classBraces = 0;
    int enumBraces = 0;

    JavaMethod method;

    for (var line in body) {
      // Skip over inner classes
      if (parseClass) {
        if (line == '{') {
          classBraces++;
          parseClassBody = true;
        }
        if (line == '}') classBraces--;
        if (parseClassBody && classBraces == 0) {
          parseClassBody = false;
          parseClass = false;
        }
        continue;
      }

      // Skip over enumerations
      if (parseEnum) {
        if (line == '{') {
          enumBraces++;
          parseEnumBody = true;
        }
        if (line == '}') enumBraces--;
        if (parseEnumBody && enumBraces == 0) {
          parseEnum = false;
          parseEnumBody = false;
        }
        continue;
      }

      // Skip over method body
      if (parseMethod) {
        if (line == '{') {
          methodBraces++;
          parseMethodBody = true;
        }

        if (line == '}') methodBraces--;

        if (parseMethodBody && methodBraces == 0) {
          parseMethod = false;
          parseMethodBody = false;
        }
        continue;
      }

      if (line.startsWith('@')) {
        notes.add(line);
        continue;
      }

      if (line.contains("class ")) {
        parseClass = true;
        notes.clear();
        continue;
      }

      if (line.contains("enum ")) {
        parseEnumBody = true;
        notes.clear();
        continue;
      }

      if (line.contains('(')) {
        var start = line.indexOf('(');
        var left = line.substring(0, start);
        method = JavaMethod();
        methods.add(method);
        for (var note in notes) {
          method.annotations.add(JavaAnnotation.parse(note));
        }
        notes.clear();
        if (left.contains('static ')) method.isStatic = true;
        if (left.contains('public ')) method.isPublic = true;

        for (var keyword in [
          'static ',
          'public ',
          'private ',
          'const ',
          'final '
        ]) {
          left = left.replaceAll(keyword, '');
        }

        var args = parseArgsLine(left.trim());
        if (args.isNotEmpty) {
          method.name = args.first.name;
          method.returnType = args.first.type;
        }
        line = line.substring(start);
        parseArgs = true;
      }

      if (parseArgs) {
        method.args.addAll(parseArgsLine(line));
        if (line.contains(')')) {
          parseArgs = false;
          parseMethod = true;
        }
        continue;
      }

      // assume anything left is a variable declaration
      if (line.contains(';')) {
        var end = line.indexOf(';');
        line = line.substring(0, end);

        var binary = line.split('=');
        var left = binary.first.trim();
        var right = binary.last.trim();
        if (binary.length == 1) right = null;

        var field = JavaVariable();
        if (left.contains('static ')) field.isStatic = true;
        if (left.contains('public ')) field.isPublic = true;
        for (var keyword in [
          'static ',
          'public ',
          'private ',
          'const ',
          'final '
        ]) {
          left = left.replaceAll(keyword, '');
        }

        var args = parseArgsLine(left);
        if (args.isNotEmpty) {
          field.type = args.first.type;
          field.name = args.first.name;
          field.initialValue = right;
          props.add(field);
        }
      }
    }
  }

  /// Parses a [line] or fragment that contains extension classes.
  void parseExtendsLine(String line) {
    var end = line.indexOf('{');
    if (end >= 0) {
      parseBodyLine(line.substring(end));
      var inner = line.substring(0, end);
      for (var part in inner.split(',')) {
        extendsClasses.add(part.trim());
      }
    }
  }

  /// Parses a [line] that contains a class declaration.
  void parseClassLine(String line) {
    var lower = line.toLowerCase();
    if (!_parseClass) {
      var start = lower.indexOf('class ');
      var prefix = lower.substring(0, start);
      if (prefix.contains('public ')) isPublic = true;
      if (prefix.contains('final ')) isFinal = true;
      start += 6;

      var left = line.substring(start);
      var posExtends = lower.indexOf(' extends ', start);
      var end = left.indexOf('{');
      if (posExtends >= 0) {
        _parseExtends = true;

        left = line.substring(start, posExtends);
        var right = line.substring(posExtends + 9);
        parseExtendsLine(right);
      } else if (end >= 0) {
        var right = left.substring(end);
        parseBodyLine(right);
        left = left.substring(0, end);
      }

      name = left.trim();
    } else if (_parseExtends) {
      parseExtendsLine(line);
    } else {
      parseBodyLine(line);
    }

    _parseClass = true;
  }

  /// Parses a single [line] of class body and track brace open/close counts.
  ///
  /// [body] is appended with code text before line comments and braces
  /// are extracted into individual lines for easier class body analysis

  void parseBodyLine(String line) {
    String lastChar;
    List<String> content = [];
    bool parseString = false;
    bool parseEscaped = false;

    for (var c in line.split('')) {
      if (parseEscaped) {
        lastChar = c;
        parseEscaped = false;
        content.add(c);
        continue;
      }

      if (parseString) {
        if (c == r'\') {
          parseEscaped = true;
        } else {
          if (c == '"') {
            parseString = false;
          }
        }
      } else {
        if (c == '/' && lastChar == '/') {
          content = content.sublist(0, content.length - 1);
          body.add(content.join('').trim());
          return;
        }

        if (c == '{') {
          _braceCount++;
          if (content.isNotEmpty) {
            body.add(content.join(''));
            body.add('{');
            content.clear();
            lastChar = '{';
            continue;
          }
        }

        if (c == '}') {
          _braceCount--;
          if (content.isNotEmpty) {
            body.add(content.join(''));
            body.add('}');
            content.clear();
            lastChar = '}';
            continue;
          }
        }
      }

      lastChar = c;
      content.add(c);
    }

    body.add(content.join('').trim());
  }

  @override
  bool append(String line, int lineno) {
    if (!parsing) return false;

    if (content.isEmpty) firstline = lineno;
    content.add(line);

    if (_braceCount == 0) {
      var next = line.trim().toLowerCase();
      if (next.startsWith('@')) {
        annotations.add(JavaAnnotation.parse(line));
      } else if (next.contains('class') || _parseClass) {
        parseClassLine(line);
      }
    } else {
      parseBodyLine(line);
    }

    if (_braceCount == 0 && _parseClass) {
      parsing = false;
    }

    return true;
  }
}
