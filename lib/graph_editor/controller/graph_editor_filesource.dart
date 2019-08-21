import 'dart:convert';
import 'dart:html';
import 'dart:indexed_db';
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

  void loadChartBlob(Blob blob) {
    FileReader reader = FileReader();
    reader.onLoad.listen((evt) {
      var data = reader.result as Uint8List;
      loadChartBytes(data);
    });

    reader.readAsArrayBuffer(blob);
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

  /// Save the current file to the file system
  void saveSystemFile() {
    String url = getChartObjectUrl();
    AnchorElement link = AnchorElement();
    link.href = url;
    link.download = chartFile.name;
    link.click();
  }

  void initChartsStore(VersionChangeEvent evt) {
    Database db = evt.target.result;
    var store = db.createObjectStore("charts", keyPath: "filename");
    store.createIndex("file_index", "filename", unique: true);
    print("Created object store 'charts'");
  }

  /// Save the current file to local storage
  void saveLocalFile() {
    if (window.navigator.userAgent.contains("iPhone") ||
        !IdbFactory.supported) {
      var base64 = getChartBase64();
      window.localStorage["LastChartFile"] = chartFile.name;
      window.localStorage["charts:${chartFile.name}"] = base64;

      print("Saved ${chartFile.name} to Local Storage");
      return;
    }

    window.indexedDB
        .open("charts", version: 1, onUpgradeNeeded: initChartsStore)
        .then((db) {
      Transaction txn = db.transaction("charts", "readwrite");
      var store = txn.objectStore("charts");

      var data = getChartBytes();
      var blob = Blob([data], "application/octet-stream");
      store.put({"filename": chartFile.name, "content": blob}).then((evt) {
        window.localStorage["LastChartFile"] = chartFile.name;
        print("Saved ${chartFile.name} to IndexedDB");
      });
    });
  }

  void openSystemFile() {
    FileUploadInputElement upload = FileUploadInputElement();
    upload.accept = ".chart";

    upload.onChange.listen((evt) {
      if (upload.files.isNotEmpty) {
        loadChartBlob(upload.files.first);
      }
    });

    upload.click();
  }

  /// Open a file from local storage
  void openLocalFile() {
    if (!window.localStorage.containsKey("LastChartFile")) return;

    var lastFile = window.localStorage["LastChartFile"];

    if (window.navigator.userAgent.contains("iPhone") ||
        !IdbFactory.supported) {
      var path = "charts:${lastFile}";
      if (!window.localStorage.containsKey(path)) return;

      var base64 = window.localStorage[path];
      loadChartBytes(Base64Decoder().convert(base64));

      print("Loaded ${lastFile} from Local Storage");
      return;
    }

    window.indexedDB
        .open("charts", version: 1, onUpgradeNeeded: initChartsStore)
        .then((db) {
      Transaction txn = db.transaction("charts", "readonly");
      var store = txn.objectStore("charts");

      store.getObject(lastFile).then((data) {
        loadChartBlob(data["content"]);
        print("Loaded ${data['filename']} from IndexedDB");
      });
    });
  }

  void openFileType(FileSourceType source) {
    source = source ?? lastSource;
    lastSource = source;

    switch (source) {
      case FileSourceType.file:
        openSystemFile();
        break;
      case FileSourceType.local:
        openLocalFile();
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
        saveSystemFile();
        break;
      case FileSourceType.local:
        saveLocalFile();
        break;
      default:
        print("Save File Type $source not implemented.");
        break;
    }
  }
}
