import 'dart:convert';
import 'dart:html';

import 'package:tide_ui/graph_editor/controller/graph_editor_comand.dart';
import 'package:tide_ui/graph_editor/data/graph_file.dart';
import 'graph_editor_controller.dart';

enum FileSourceType {
  branch,
  local,
  github,
  onedrive,
  slack,
  google,
  dropbox,
  file,
  device
}

mixin GraphEditorFileSource on GraphEditorControllerBase {
  void saveFile() {
    var json = JsonEncoder.withIndent("  ");

    List data = List();

    editor.saveChanges();

    var packed = GraphFile.editor(editor);
    data.add(json.convert(packed));

    var file = Blob(data, "text/json", "native");
    var url = Url.createObjectUrlFromBlob(file);

    AnchorElement link = AnchorElement();
    link.href = url;
    link.download = "graph_${editor.controller.graph.name}.json";
    link.click();
  }

  void loadChartJson(String content, String filename) {
    print("Load $filename (${content.length})");
  }

  void openFileFolder() {
    FileUploadInputElement upload = FileUploadInputElement();
    upload.onChange.listen((evt) {
      if (upload.files.isNotEmpty) {
        var file = upload.files.first;
        var blob = file.slice();

        FileReader reader = FileReader();
        reader.onLoad.listen((evt) {
          editor.controller.dispatch(GraphEditorCommand.loadChartJson(
              reader.result as String, file.name));
        });

        reader.readAsText(blob);
      }
    });

    upload.click();
  }

  void openFolderType(FileSourceType source) {
    source = source ?? lastSource;
    lastSource = source;

    switch (source) {
      case FileSourceType.file:
        openFileFolder();
        break;
      default:
        print("Open Folder Type $source not implemented.");
        break;
    }
  }
}
