class JavaAnnotation {
  String name;
  Map<String, String> fields = {};
  List<String> order = [];

  JavaAnnotation.parse(String line) {
    var start = line.indexOf('@') + 1;
    if (start > 0) {
      var startFields = line.indexOf('(', start);
      var endFields = line.indexOf(')', start);

      if (startFields < 0) {
        name = line.substring(start).trim();
      } else {
        name = line.substring(start, startFields).trim();

        if (endFields >= 0) {
          var inner = line.substring(startFields + 1, endFields);
          for (var part in inner.split(',')) {
            var binop = part.split('=').toList();
            String key = binop.first.trim();
            String value = binop.last.trim();

            if (binop.length == 1) {
              key = "";
            }
            fields[key] = value;
            order.add(key);
          }
        }
      }
    }
  }
}
