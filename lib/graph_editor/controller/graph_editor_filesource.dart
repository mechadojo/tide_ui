import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

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
  void updateChartFile() {
    editor.saveChanges();

    var packed = GraphFile.editor(editor);
    chartFile.chart = packed.toChart();
  }

  String getChartJson() {
    updateChartFile();
    return chartFile.writeToJson();
  }

  void loadChartBytes(Uint8List bytes) {
    chartFile.clear();
    chartFile.mergeFromBuffer(bytes);
    editor.controller.loadChart();
  }

  Uint8List getChartBytes() {
    updateChartFile();
    return chartFile.writeToBuffer();
  }

  String getChartBase64() {
    updateChartFile();
    var data = chartFile.writeToBuffer();
    return Base64Encoder().convert(data);
  }

  String getChartObjectUrl() {
    if (chartFile.name.endsWith(".chart")) {
      var data = getChartBytes();
      var file = Blob([data], "application/octet-stream");
      return Url.createObjectUrlFromBlob(file);
    } else if (chartFile.name.endsWith(".json")) {
      var data = getChartJson();
      var file = Blob([data], "application/json");
      return Url.createObjectUrlFromBlob(file);
    } else {
      var data = getChartBase64();
      var file = Blob([data], "application/base64");
      return Url.createObjectUrlFromBlob(file);
    }
  }

  void saveFileSystem() {
    String url = getChartObjectUrl();
    AnchorElement link = AnchorElement();
    link.href = url;
    link.download = chartFile.name;
    link.click();
  }

  void openFileSystem() {
    FileUploadInputElement upload = FileUploadInputElement();
    upload.accept = ".chart";

    upload.onChange.listen((evt) {
      if (upload.files.isNotEmpty) {
        var file = upload.files.first;

        FileReader reader = FileReader();
        reader.onLoad.listen((evt) {
          var data = reader.result as Uint8List;
          loadChartBytes(data);
        });

        reader.readAsArrayBuffer(file);
      }
    });

    upload.click();
  }

  void openFileType(FileSourceType source) {
    source = source ?? lastSource;
    lastSource = source;

    switch (source) {
      case FileSourceType.file:
        openFileSystem();
        break;
      default:
        print("Open File Type $source not implemented.");
        break;
    }
  }

  void saveFileType(FileSourceType source) {
    source = source ?? lastSource;
    lastSource = source;

    switch (source) {
      case FileSourceType.file:
        saveFileSystem();
        break;
      default:
        print("Save File Type $source not implemented.");
        break;
    }
  }
}
