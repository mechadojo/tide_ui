import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:uuid/uuid.dart';

class GraphFile {
  List<TideChartGraph> sheets = [];
  List<TideChartLibrary> library = [];
  List<TideChartSource> imports = [];
  List<TideChartProperty> settings = [];
  List<TideChartProperty> props = [];

  String version;
  String branch;
  String source;
  String merge;
  String origin;

  String commitDate;
  String commitBy;
  String commitDesc;
  String commitNotes;

  static List<String> defaultImports = ["default.chart", "common.chart"];

  GraphFile.empty() {
    imports = [...defaultImports.map(packSource)];
  }

  GraphFile.editor(GraphEditorState editor) {
    sheets = [...editor.sheets.map((x) => x.pack())];

    var libs = editor.library.where((x) => !x.imported).toList();
    library = [...libs.map((x) => x.packLibrary())];
    imports = [...editor.imports.map(packSource)];

    version = editor.version;
    branch = editor.branch;
    source = editor.source;
    merge = editor.merge;
    origin = editor.origin;
  }

  static TideChartSource packSource(String filename) {
    TideChartSource source = TideChartSource();
    source.id = Uuid().v1().toString();
    source.name = filename;
    return source;
  }

  GraphFile(TideChartData chart) {
    sheets = [...chart.sheets.map((x) => x.clone())];
    library = [...chart.library.map((x) => x.clone())];
    imports = [...chart.imports.map((x) => x.clone())];
    settings = [...chart.settings.map((x) => x.clone())];
    props = [...chart.props.map((x) => x.clone())];

    version = chart.version;
    branch = chart.branch;
    source = chart.source;
    merge = chart.merge;
    origin = chart.origin;

    commitDate = chart.commitDate;
    commitBy = chart.commitBy;
    commitDesc = chart.commitDesc;
    commitNotes = chart.commitNotes;
  }

  TideChartData toChart() {
    TideChartData result = TideChartData();

    result.sheets.addAll(sheets.map((x) => x.clone()));
    result.library.addAll(library.map((x) => x.clone()));
    result.imports.addAll(imports.map((x) => x.clone()));
    result.props.addAll(props.map((x) => x.clone()));
    result.settings.addAll(settings.map((x) => x.clone()));

    if (version != null) result.version = version;
    if (branch != null) result.branch = branch;
    if (source != null) result.source = source;
    if (merge != null) result.merge = merge;
    if (origin != null) result.origin = origin;

    if (commitDate != null) result.commitDate = commitDate;
    if (commitBy != null) result.commitBy = commitBy;
    if (commitDesc != null) result.commitDesc = commitDesc;
    if (commitNotes != null) result.commitNotes = commitNotes;

    return result;
  }
}
