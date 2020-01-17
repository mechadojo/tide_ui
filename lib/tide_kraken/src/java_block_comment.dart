import 'java_file_part.dart';

class JavaBlockComment extends JavaFilePart {
  String body;

  @override
  bool append(String line, int lineno) {
    if (!parsing) return false;

    if (content.isEmpty) firstline = lineno;
    content.add(line);

    if (line.contains('*/')) parsing = false;

    return true;
  }
}
