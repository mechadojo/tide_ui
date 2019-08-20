import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

class GraphFile {
  List<PackedGraph> sheets = [];

  GraphFile.editor(GraphEditorState editor) {
    sheets = [...editor.tabs.values.map((x) => x.graph.pack())];
  }

  GraphFile.chart(TideChartFile file) {
    sheets = [...file.chart.sheets.map((x) => PackedGraph.chart(x))];
  }

  Map<String, dynamic> toJson() => {
        'sheets': sheets,
      };

  TideChartData toChart() {
    TideChartData result = TideChartData();
    result.sheets.addAll(sheets.map((x) => x.toChart()));
    return result;
  }
}
