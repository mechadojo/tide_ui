// Parses an SVG font file and creates a Dart class to render the glyphs
// Note: remove the DOCTYPE from the svg file because xml parser errors out

import "dart:io";

var fontFamily = "MaterialIcons";
var libraryName = "";
var className = "GraphIcons";
var outputFile = "output.dart";

Map<String, String> codePoints = {};
Set<String> matchDirections = {};
List<String> varNames = [];

void main(List<String> arguments) {
  var file = File(arguments.first);

  if (!file.existsSync()) {
    print('Cannot find the file "${arguments.first}".');
  }

  var lines = file.readAsLinesSync();

  var reName = RegExp(r'/// <p><i');
  var reVariable = RegExp(r'IconData (.*) =');
  var reVariableCoded = RegExp(r'IconData (.*) = const IconData[(](.*),');
  var reCodePoint = RegExp(r'IconData[(](.*),');

  // Read icons.dart
  for (int i = 0; i < lines.length; i++) {
    if (!reName.hasMatch(lines[i])) continue;

    i += 2;

    String varName;
    String codePoint;
    bool matchDirection = false;

    //print(lines[i]);

    if (reVariableCoded.hasMatch(lines[i])) {
      var mls = reVariableCoded.firstMatch(lines[i]);
      varName = mls.group(1);
      codePoint = mls.group(2);
      i++;
      matchDirection = lines[i].contains("matchTextDirection: true");
    } else {
      varName = reVariable.firstMatch(lines[i]).group(1);
      i++;
      codePoint = reCodePoint.firstMatch(lines[i]).group(1);
    }

    varNames.add(varName);
    codePoints[varName] = codePoint;
    if (matchDirection) matchDirections.add(varName);
  }

  List<String> generatedOutput = [
    if (libraryName != null && libraryName.isNotEmpty) 'library $libraryName;',
    '',
    "import 'package:flutter_web/widgets.dart';",
    '',
    '// THIS FILE IS AUTOMATICALLY GENERATED!',
    '',
    '// File generated using generate_icons.dart from the Flutter icons.dart.',
    '',
    'class $className {',
    '  $className._();'
        '',
    'static String nameOf(int index) {',
    'var name = names[index % names.length];',
    'return name;',
    '}',
    '',
    'static IconData getIconByIndex(int index) {',
    'return getIcon(nameOf(index));',
    '}',
  ];

  generatedOutput.addAll(generateIconData());
  generatedOutput.addAll(generateStringAccess());
  generatedOutput.addAll(generateIntegerAccess());
  generatedOutput.addAll(['', '}']);

  File output = File(outputFile);
  output.writeAsStringSync(generatedOutput.join('\n'));
}

Iterable<String> generateIconData() sync* {
  yield '';

  for (var name in varNames) {
    var codePoint = codePoints[name];

    if (matchDirections.contains(name)) {
      yield "  static const IconData $name = IconData($codePoint, fontFamily: '$fontFamily', matchTextDirection: true);";
    } else {
      yield "  static const IconData $name = IconData($codePoint, fontFamily: '$fontFamily');";
    }
  }
  yield '';
}

Iterable<String> generateStringAccess() sync* {
  yield '';
  yield 'static IconData getIcon(String name) {';
  yield 'switch (name) {';

  for (var name in varNames) {
    yield 'case "$name":';
    yield 'return $name;';
  }

  yield 'default:';
  yield 'return question_answer;';

  yield '}';
  yield '}';
  yield '';
}

Iterable<String> generateIntegerAccess() sync* {
  yield '';
  yield 'static List<String> names = [';
  for (var name in varNames) {
    yield '"$name",';
  }
  yield '];';
  yield '';
}
