import 'package:tide_chart/tide_chart.dart';
import 'package:fixnum/fixnum.dart';

class GraphProperty {
  String name;
  static RegExp integer = RegExp(r'^[-]?[0-9]+$');

  String getValueType() {
    return "None";
  }

  String getValue() {
    return "";
  }

  String getQuotedValue() {
    return getValue();
  }

  void setValue(String val) {}

  TideChartProperty pack() {
    var result = TideChartProperty();
    result.name = name;

    return result;
  }

  static GraphProperty parse(String name, String value, [String type]) {
    switch (type) {
      case "String":
        return GraphPropertyString()
          ..name = name
          ..setValue(value);
      case "Boolean":
        return GraphPropertyBool()
          ..name = name
          ..setValue(value);
      case "Integer":
        return GraphPropertyInt()
          ..name = name
          ..setValue(value);
      case "Double":
        return GraphPropertyDouble()
          ..name = name
          ..setValue(value);
    }

    var lower = value.toLowerCase().trim();
    if (lower == "true" || lower == "false") {
      return GraphPropertyBool()
        ..name = name
        ..value = lower == "true";
    }

    if (integer.hasMatch(value)) {
      var ival = int.tryParse(value);
      if (ival != null) {
        return GraphPropertyInt()
          ..name = name
          ..value = ival;
      }
    }

    if (value.contains(".")) {
      var dval = double.tryParse(value);
      if (dval != null) {
        return GraphPropertyDouble()
          ..name = name
          ..value = dval;
      }
    }

    return GraphPropertyString()
      ..name = name
      ..value = value;
  }

  static GraphProperty asString(String name, String value) {
    return GraphPropertyString()
      ..name = name
      ..value = value;
  }

  static GraphProperty asInt(String name, int value) {
    return GraphPropertyInt()
      ..name = name
      ..value = value;
  }

  static GraphProperty asBool(String name, bool value) {
    return GraphPropertyBool()
      ..name = name
      ..value = value;
  }

  static GraphProperty asDouble(String name, double value) {
    return GraphPropertyDouble()
      ..name = name
      ..value = value;
  }

  static GraphProperty unpack(TideChartProperty packed) {
    if (packed.hasBoolValue()) {
      return GraphPropertyBool()
        ..name = packed.name
        ..value = packed.boolValue;
    }

    if (packed.hasStrValue()) {
      return GraphPropertyString()
        ..name = packed.name
        ..value = packed.strValue;
    }

    if (packed.hasLongValue()) {
      return GraphPropertyInt()
        ..name = packed.name
        ..value = packed.longValue.toInt();
    }

    if (packed.hasDoubleValue()) {
      return GraphPropertyDouble()
        ..name = packed.name
        ..value = packed.doubleValue;
    }
    return null;
  }
}

class GraphPropertyValue extends GraphProperty {}

class GraphPropertyBool extends GraphPropertyValue {
  bool value;

  @override
  TideChartProperty pack() {
    return super.pack()..boolValue = value;
  }

  @override
  String getValueType() {
    return "Boolean";
  }

  @override
  String getValue() {
    return value.toString();
  }

  @override
  void setValue(String val) {
    value = val.toLowerCase() == "true";
  }
}

class GraphPropertyString extends GraphPropertyValue {
  String value;

  @override
  TideChartProperty pack() {
    return super.pack()..strValue = value;
  }

  @override
  String getValueType() {
    return "String";
  }

  @override
  String getValue() {
    return value;
  }

  @override
  String getQuotedValue() {
    var quoted = value
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', '')
        .replaceAll('\t', r'\t');
    return '"$quoted"';
  }

  @override
  void setValue(String val) {
    value = val;
  }
}

class GraphPropertyInt extends GraphPropertyValue {
  int value;

  @override
  TideChartProperty pack() {
    return super.pack()..longValue = Int64(value);
  }

  @override
  String getValueType() {
    return "Integer";
  }

  @override
  String getValue() {
    return value.toString();
  }

  @override
  void setValue(String val) {
    var ival = int.tryParse(val);
    if (ival == null) {
      var dval = double.tryParse(val);
      if (dval != null) ival = dval.round();
    }

    value = ival ?? 0;
  }
}

class GraphPropertyDouble extends GraphPropertyValue {
  double value;

  @override
  TideChartProperty pack() {
    return super.pack()..doubleValue = value;
  }

  @override
  String getValueType() {
    return "Double";
  }

  @override
  String getValue() {
    return value.toString();
  }

  @override
  void setValue(String val) {
    value = double.tryParse(val) ?? 0;
  }
}

class GraphPropertyList extends GraphProperty {
  List<GraphProperty> props = [];

  @override
  TideChartProperty pack() {
    return super.pack()..props.addAll(props.map((x) => x.pack()));
  }

  @override
  String getValueType() {
    return "List";
  }

  @override
  String getValue() {
    return "[${props.map((x) => x.getQuotedValue()).join(',')}]";
  }
}

class GraphPropertySet extends GraphProperty {
  Map<String, GraphProperty> props = {};

  TideChartProperty pack() {
    return TideChartProperty()
      ..name = name
      ..props.addAll(packList());
  }

  List<TideChartProperty> packList() {
    var result = List<TideChartProperty>();
    for (var item in props.values) {
      if (item is GraphPropertyList) {
        for (var child in item.props) {
          result.add(child.pack());
        }
      } else {
        result.add(item.pack());
      }
    }

    return result;
  }

  bool get isNotEmpty => props.isNotEmpty;
  bool get isEmpty => props.isEmpty;

  Iterable<GraphProperty> get values sync* {
    var keys = props.keys.toList();
    keys.sort();
    for (var key in keys) {
      var prop = props[key];
      if (prop is GraphPropertyValue) {
        yield prop;
      }
    }
  }

  @override
  String getValueType() {
    return "Object";
  }

  @override
  String getValue() {
    var result = StringBuffer();

    result.write("{");
    bool first = true;
    for (var key in props.keys) {
      if (!first) result.write(',');
      result.write('"$key":${props[key].getQuotedValue()}');
      first = false;
    }

    result.write("}");
    return result.toString();
  }

  void remove(String name) {
    props.remove(name);
  }

  void rename(String name, String next) {
    var prop = props.remove(name);
    if (prop != null) {
      prop.name = next;
      props[next] = prop;
    }
  }

  void replace(GraphProperty prop) {
    props[prop.name] = prop;
  }

  void add(GraphProperty prop) {
    if (prop == null) return;

    var val = props[prop.name];

    if (val == null) {
      props[prop.name] = prop;
    } else if (val is GraphPropertyList) {
      val.props.add(prop);
    } else {
      props[prop.name] = GraphPropertyList()..props = [val, prop];
    }
  }

  void addPacked(TideChartProperty packed) {
    add(GraphProperty.unpack(packed));

    if (packed.props.isNotEmpty) {
      var ps = unpack(packed.props)..name = packed.name;
      add(ps);
    }
  }

  static GraphPropertySet unpack(List<TideChartProperty> packed) {
    var result = GraphPropertySet();

    for (var item in packed) {
      result.addPacked(item);
    }

    return result;
  }
}
