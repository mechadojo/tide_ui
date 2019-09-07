import 'package:tide_chart/tide_chart.dart';
import 'package:tide_ui/graph_editor/data/graph_file.dart';

import 'graph_editor_controller.dart';

mixin GraphEditorVersionControl on GraphEditorControllerBase {
  bool get isNewBranch {
    if ((editor.source ?? "").isEmpty) return false;

    var branch = editor.branch ?? "";
    if (branch.isEmpty) return false;

    for (var item in chartFile.history) {
      if (item.version == editor.source) {
        var source = item.branch ?? "";
        return branch != source;
      }
    }

    return false;
  }

  bool get allowCommit => (editor.version != editor.origin);
  bool get allowMerge =>
      editor.version == editor.origin &&
      (editor.branch ?? "").isNotEmpty &&
      !editor.branch.startsWith("~");

  bool get allowBranch =>
      editor.version == editor.origin && !editor.branch.startsWith("~");

  Future<bool> changeVersion(String version) async {
    for (var item in chartFile.history) {
      if (item.version == version) {
        await editor.controller.loadChart(data: item);

        clearHistory(update: false);

        editor.source = item.version;
        editor.merge = "";
        editor.origin = editor.version;

        editor.controller.updateHistory(graph);
        editor.controller.updateVersion();
        return true;
      }
    }
    return false;
  }

  String sanitizeBranch(String branch) {
    branch = branch ?? "";
    branch = branch.trim().toLowerCase();
    if (branch.isEmpty) branch == "master";
    return branch;
  }

  bool validateBranch(String branch, {bool open = true}) {
    branch = sanitizeBranch(branch);

    if (branch == "master") return false;
    if (branch == editor.branch) return false;

    return !getBranches(open: open).any((x) => x.branch == branch);
  }

  void commitChanges(String message, {String user}) {
    var current = editor.version;

    // for now don't commit empty changes
    if (current == editor.origin && !isNewBranch) {
      print("Commit changes requires there to be a version change.");
      return;
    }

    var packed = GraphFile.editor(editor);
    packed.commitDesc = message;
    packed.commitBy = user;
    packed.commitDate = DateTime.now().toIso8601String();

    chartFile.history.add(packed.toChart());
    print("Added ${packed.version} to history.");

    clearHistory(update: false);

    editor.source = packed.version;
    editor.merge = "";
    editor.origin = editor.version;

    editor.controller.updateHistory(graph);
    editor.controller.updateVersion();
  }

  void clearHistory({bool update = true}) {
    for (var item in [
      ...editor.sheets,
      ...editor.library.where((x) => !x.imported)
    ]) {
      item.history.clear();
    }

    if (update) {
      editor.controller.updateHistory(graph);
      editor.controller.updateVersion();
    }
  }

  void branchVersion(String branch) {
    var current = editor.version;

    // for now don't branch if there are uncommitted changes
    if (current != editor.origin) return;
    branch = sanitizeBranch(branch);

    // a new branch has to be a new name
    if (!validateBranch(branch)) {
      print("must have a unique branch name");
      return;
    }

    // branching does not clear history
    editor.branch = branch;
    editor.merge = "";
    editor.origin = editor.version;

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
    if (current != editor.origin) return;

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

    if (editor.source == last.version) {
      editor.branch = last.branch;
      editor.merge = "";
      editor.origin = editor.version;
    } else {
      // try to merge changes with the source branch
      var merged = await tryMergeChart(last, source);
      if (!merged) return;

      editor.branch = last.branch;
      editor.merge = editor.source;
      editor.source = last.version;

      var packed = GraphFile.editor(editor);
      packed.commitDesc = "merge #${editor.merge.substring(0, 7)}";
      packed.commitBy = user;
      packed.commitDate = DateTime.now().toIso8601String();

      chartFile.history.add(packed.toChart());

      clearHistory(update: false);

      editor.source = packed.version;
      editor.merge = "";
      editor.origin = editor.version;
    }

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
    Map<String, TideChartData> versions = {};
    Map<String, TideChartData> last = {};
    List<String> sorted = [];

    for (var data in chartFile.history) {
      var b = data.branch ?? "";
      last[b] = data;
      versions[data.version] = data;

      if (!sorted.contains(b)) {
        sorted.add(b);
      }

      if (open) {
        var m = versions[data.merge ?? ""];

        if (m != null && last.containsKey(m.branch)) last.remove(m.branch);
      }
    }

    for (var branch in sorted) {
      if (last.containsKey(branch)) {
        yield last[branch];
      }
    }
  }
}
