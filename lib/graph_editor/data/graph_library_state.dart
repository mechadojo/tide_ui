import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_property_set.dart';
import 'package:uuid/uuid.dart';

import 'graph_state.dart';

class GraphLibraryFields {
  String id = Uuid().v1().toString();
  String name;
  String title;
  String origin;
  String branch;
  String path;

  List<TideChartSource> files = [];
  GraphPropertySet settings = GraphPropertySet();
}

class GraphLibraryState extends GraphState {
  GraphLibraryFields library = GraphLibraryFields();

  void unpackLibrary(TideChartLibrary library) {
    this.library.id = library.id;
    this.library.name = library.name;
    this.library.title = library.title;
    this.library.origin = library.origin;
    this.library.branch = library.branch;
    this.library.path = library.path;

    this.library.files = [...library.files.map((f) => f.clone())];
    this.library.settings = GraphPropertySet.unpack(library.settings);

    this.unpackGraph(library.methods);
    this.type = GraphType.library;
  }

  TideChartLibrary packLibrary() {
    TideChartLibrary result = TideChartLibrary();

    result.id = library.id;
    result.name = library.name;
    result.title = library.title;
    result.origin = library.origin;
    result.branch = library.branch;
    result.path = library.path;

    result.files.addAll(library.files.map((f) => f.clone()));
    result.settings.addAll(library.settings.packList());

    result.methods = pack();
    return result;
  }
}
