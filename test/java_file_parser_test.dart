import 'package:flutter_test/flutter_test.dart';
import 'package:tide_ui/tide_kraken/src/java_block_comment.dart';
import 'package:tide_ui/tide_kraken/src/java_class.dart';
import 'package:tide_ui/tide_kraken/src/java_file.dart';
import 'package:tide_ui/tide_kraken/src/java_file_part.dart';

void main() {
  test('parse comment block', () {
    var file = JavaFile();
    file.parse(commentJava);

    expect(file.content.length, 1);
    expect(file.content.first, isA<JavaBlockComment>());
    var comment = file.content.first as JavaBlockComment;
    expect(comment.content.length, 3);
  });

  test('parse package', () {
    var file = JavaFile()..parse(packageJava);

    expect(file.content.length, 1);
    expect(file.content.last, isA<JavaFilePart>());
    expect(file.package.length, 4);
  });

  test('parse import', () {
    var file = JavaFile()..parse(importJava);

    expect(file.content.length, 3);
    expect(file.imports.length, 3);
    var import = file.imports.first;
    expect(import.name, "Disabled");
    expect(import.package,
        ["com", "qualcomm", "robotcore", "eventloop", "opmode"]);
  });

  test('parse empty class', () {
    var file = JavaFile()..parse(emptyClassJava);
    expect(file.content.length, 1);
    expect(file.content.first, isA<JavaClass>());
    expect(file.top, isNotNull);
    expect(file.top.name, "SimpleClassName");
  });

  test('parse annotated class', () {
    var file = JavaFile()..parse(annotatedClassJava);
    expect(file.top, isNotNull);
    expect(file.top.name, "AnnotatedClass");
    expect(file.top.annotations.length, 2);
    var note = file.top.annotations.first;
    expect(note.name, "Override");
    expect(note.fields.values.length, 0);

    note = file.top.annotations.last;
    expect(note.name, "Values");
    expect(note.fields.length, 2);
    expect(note.fields.keys, ["key1", "key2"]);
    expect(note.fields["key2"], '"two"');
  });

  test('parse class with variable', () {
    var file = JavaFile()..parse(classWithVariableJava);
    expect(file.top, isNotNull);
    expect(file.top.props.length, 1);

    var prop = file.top.props.first;
    expect(prop.isPublic, isTrue);
    expect(prop.isStatic, isFalse);
    expect(prop.name, "foo");
    expect(prop.initialValue, '"two"');
  });

  test('parse class with method', () {
    var file = JavaFile()..parse(classWithMethodJava);
    expect(file.top, isNotNull);
    expect(file.top.methods.length, 1);

    var method = file.top.methods.first;
    expect(method.isPublic, isTrue);
    expect(method.isStatic, isFalse);
    expect(method.name, "foo");
    expect(method.returnType, "void");
    expect(method.args.length, 0);
    expect(method.annotations.length, 1);
    var note = method.annotations.first;
    expect(note.name, "Override");
  });
}

String commentJava = r"""
/**
 *  This is a block comment
 */

""";

String packageJava = r"""

package app.tidecharts.test.package;

""";

String importJava = r"""

import com.qualcomm.robotcore.eventloop.opmode.Disabled;
import com.qualcomm.robotcore.eventloop.opmode.OpMode;
import com.qualcomm.robotcore.eventloop.opmode.TeleOp;

""";

String emptyClassJava = r"""

public class SimpleClassName {

}
""";

String annotatedClassJava = r"""

@Override
@Values(key1="one",key2="two")
public class AnnotatedClass {

}
""";

String classWithVariableJava = r"""

public class WithVariablesClass {
  public String foo = "two"; // with end comment
  // public int bar;
}
""";

String classWithMethodJava = r"""
public class WithMethodClass {
  @Override
  public void foo() {
    int i=0;
    // inline comment
  }
}
""";
