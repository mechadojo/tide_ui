class JavaImport {
  List<String> package = [];
  String name;
  bool isStatic = false;

  JavaImport.parse(String line) {
    var lower = line.toLowerCase();
    var start = lower.indexOf('import ') + 7;

    var right = lower.substring(start).trim();
    if (right.startsWith('static ')) {
      start = lower.indexOf('static ', start) + 7;
      isStatic = true;
    }

    var end = lower.indexOf(';', start);
    var inner = line.substring(start, end);
    for (var part in inner.split('.')) {
      package.add(part.trim());
    }

    name = package.last;
    if (package.length == 1) {
      package = [];
    } else {
      package = package.sublist(0, package.length - 1);
    }
  }
}
