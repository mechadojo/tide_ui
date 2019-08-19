import 'package:tide_ui/graph_editor/data/graph_editor_state.dart';
import 'package:tide_ui/graph_editor/data/graph_state.dart';

class GraphFile {
  List<PackedGraph> sheets = [];

  GraphFile.editor(GraphEditorState editor) {
    sheets = [...editor.tabs.values.map((x) => x.graph.pack())];
  }
  Map<String, dynamic> toJson() => {
        'sheets': sheets,
      };
}
