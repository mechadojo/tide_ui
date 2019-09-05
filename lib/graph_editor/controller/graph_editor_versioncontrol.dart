import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_file.dart';

import 'graph_editor_controller.dart';

mixin GraphEditorVersionControl on GraphEditorControllerBase {
  bool get allowCommit => editor.version != editor.source;
  bool get allowMerge => editor.version == editor.source;
  bool get allowBranch => editor.version == editor.source;

  void commitChanges(String message, {String user}) {
    var current = editor.version;

    // for now don't commit empty changes
    if (current == editor.source) return;

    var packed = GraphFile.editor(editor);
    packed.commitDesc = message;
    packed.commitBy = user;
    packed.commitDate = DateTime.now().toIso8601String();

    chartFile.history.add(packed.toChart());

    editor.source = current;

    for (var item in editor.sheets) {
      item.history.clear();
    }

    for (var item in editor.library) {
      item.history.clear();
    }

    editor.controller.updateHistory(graph);
    editor.controller.updateVersion();
  }

  void branchVersion(String branch) {
    var current = editor.version;

    // for now don't branch if there are uncommitted changes
    if (current != editor.source) return;

    // a new branch has to be a new name
    if (branch == null || branch.isEmpty || branch == editor.branch) return;

    // a new branch cannot match a currently open branch name
    var branches = getBranches().map((x) => x.branch).toSet();
    if (branches.contains(branch)) return;

    editor.source = current;
    editor.branch = branch;

    editor.controller.updateHistory(graph);
    editor.controller.updateVersion();
  }

  Future<bool> tryMergeChart(TideChartData last, TideChartData source) async {
    // check that changes between current and source are not also
    // changed between source and last

    return Future.value(true);
  }

  void mergeVersion({String user}) async {
    var current = editor.version;

    // for now don't merge if there are uncommitted changes
    if (current != editor.source) return;

    // find the origin of the current branch
    var versions = getVersions();
    var source = versions[editor.source];
    while (source != null && source.branch == editor.branch) {
      source = versions[source.source];
    }

    // cannot merge if there is not source point
    if (source == null) return;

    // find the current end of the source branch
    var last = source;
    for (var data in chartFile.history) {
      if (data.source == last.version && data.branch == last.branch) {
        last = data;
      }

      // follow merges
      if (data.merge == last.version) {
        last = data;
      }
    }

    // try to merge changes with the source branch
    var merged = await tryMergeChart(last, source);
    if (!merged) return;

    editor.branch = last.branch;
    editor.source = last.version;
    editor.merge = current;

    // capture the new version number
    current = editor.version;

    var packed = GraphFile.editor(editor);
    packed.commitDesc = "Merged from ${editor.merge.substring(0, 8)}";
    packed.commitBy = user;
    packed.commitDate = DateTime.now().toIso8601String();

    chartFile.history.add(packed.toChart());

    editor.source = current;
    editor.merge = "";
    editor.controller.updateHistory(graph);
    editor.controller.updateVersion();
  }

  Map<String, TideChartData> getVersions() {
    Map<String, TideChartData> result = {};
    for (var data in chartFile.history) {
      result[data.version] = data;
    }
    return result;
  }

  Iterable<TideChartData> getBranches({bool open = true}) sync* {
    Map<String, TideChartData> last = {};
    List<String> sorted = [];

    for (var data in chartFile.history) {
      var b = data.branch ?? "";
      if (b.isNotEmpty) {
        last[b] = data;
      }

      if (!sorted.contains(b)) {
        sorted.add(b);
      }

      if (open) {
        var m = data.merge ?? "";
        if (last.containsKey(m)) last.remove(m);
      }
    }

    for (var branch in sorted) {
      if (last.containsKey(branch)) {
        yield last[branch];
      }
    }
  }
}
