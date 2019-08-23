import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';

class GraphFile {
  List<TideChartGraph> sheets = [];

  GraphFile.editor(GraphEditorState editor) {
    sheets = [...editor.tabs.values.map((x) => x.graph.pack())];
  }

  GraphFile(TideChartData chart) {
    sheets = [...chart.sheets];
  }

  TideChartData toChart() {
    TideChartData result = TideChartData();
    result.sheets.addAll(sheets.map((x) => x));
    return result;
  }
}
