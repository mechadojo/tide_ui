import 'java_annotation.dart';
import 'java_field.dart';

class JavaVariable extends JavaField {
  List<JavaAnnotation> annotations = [];
  bool isPublic = false;
  bool isStatic = false;
  String initialValue;
}
