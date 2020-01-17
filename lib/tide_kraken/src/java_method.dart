import 'package:tide_ui/tide_kraken/src/java_annotation.dart';
import 'java_field.dart';

class JavaMethod {
  String name;
  List<JavaField> args = [];
  List<JavaAnnotation> annotations = [];
  String returnType = 'void';
  bool isPublic = false;
  bool isStatic = false;

  List<String> body = [];
}
