import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:indexed_db';
import 'dart:typed_data';

import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
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

  Future<String> getGraphImageUrl() async {
    var data = await graph.getImage();
    var file = Blob([data], "image/png");
    return Url.createObjectUrlFromBlob(file);
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

  void printFile() {
    getGraphImageUrl().then((String url) {
      print("Got url");
      AnchorElement link = AnchorElement();
      link.href = url;
      link.download = "sheet_${graph.name}.png";
      link.click();
    });
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

  void openLastFile() {
    if (!window.localStorage.containsKey("LastChartFile")) return;
    var lastFile = window.localStorage["LastChartFile"];
    openLocalFile(lastFile);
  }

  Future<List<String>> getLocalFileList() async {
    if (window.navigator.userAgent.contains("iPhone") ||
        !IdbFactory.supported) {
      List<String> result = [];
      for (var key in window.localStorage.keys) {
        if (key.startsWith("charts:")) {
          result.add(key.substring("charts:".length));
        }
      }

      return Future<List<String>>.value(result);
    }

    var db = await window.indexedDB
        .open("charts", version: 1, onUpgradeNeeded: initChartsStore);

    Transaction txn = db.transaction("charts", "readonly");
    var store = txn.objectStore("charts");
    var result = Completer<List<String>>();

    var request = store.getAllKeys(null);
    request.onSuccess.listen((onData) {
      List<dynamic> keys = request.result;

      result.complete(keys.map((x) => x.toString()).toList());
    });

    return result.future;
  }

  void deleteLocalFile(String filename, {bool confirmed = false}) {
    if (!confirmed) {
      editor.controller.dialogActive = true;
      editor.controller.setCursor("default");
      showDialog<bool>(
          context: editor.controller.scaffold.currentContext,
          builder: (BuildContext context) {
            return AlertDialog(
                title:
                    Text("Delete file?", style: Graph.DefaultDialogTitleStyle),
                content: Text("This will permanently delete $filename.",
                    style: Graph.DefaultDialogContentStyle),
                actions: <Widget>[
                  FlatButton(
                    child:
                        Text("CANCEL", style: Graph.DefaultDialogButtonStyle),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child:
                        Text("CONTINUE", style: Graph.DefaultDialogButtonStyle),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ]);
          }).then((bool result) {
        editor.controller.dialogActive = false;
        if (result ?? false) {
          deleteLocalFile(filename, confirmed: true);
        }
      });

      return;
    }

    print("Delete file: $filename");
  }

  /// Open a file from local storage
  void openLocalFile([String filename]) {
    if (filename == null) {
      getLocalFileList().then((List<String> files) {
        library.controller.openFile("Open File", openLocalFile, files);
      });

      return;
    }

    if (window.navigator.userAgent.contains("iPhone") ||
        !IdbFactory.supported) {
      var path = "charts:${filename}";
      if (!window.localStorage.containsKey(path)) return;

      var base64 = window.localStorage[path];
      loadChartBytes(Base64Decoder().convert(base64));

      print("Loaded ${filename} from Local Storage");
      return;
    }

    window.indexedDB
        .open("charts", version: 1, onUpgradeNeeded: initChartsStore)
        .then((db) {
      Transaction txn = db.transaction("charts", "readonly");
      var store = txn.objectStore("charts");

      store.getObject(filename).then((data) {
        loadChartBlob(data["content"]);
        window.localStorage["LastChartFile"] = filename;
        print("Loaded ${data['filename']} from IndexedDB");
      });
    });
  }

  void openFileType(FileSourceType source, [String filename]) {
    source = source ?? lastSource;
    lastSource = source;

    switch (source) {
      case FileSourceType.file:
        openSystemFile();
        break;
      case FileSourceType.local:
        openLocalFile(filename);
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
