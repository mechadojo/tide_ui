class JavaFilePart {
  bool parsing = true;

  int firstline = 0;
  List<String> content = [];

  bool append(String line, int lineno) {
    if (!parsing) return false;

    if (content.isEmpty) firstline = lineno;
    content.add(line);

    return true;
  }
}
