import 'graph_editor_controller.dart';

mixin GraphEditorBuild on GraphEditorControllerBase {
  static String remoteProxyUrl = "http://127.0.0.1:4040";
  static String remoteDirectUrl = "http://192.168.49.1:8080";

  String remoteUrl = remoteProxyUrl;
  bool remoteConnected = false;
  bool useRemoteProxy = false;

  void connectRemote() {}

  Future<List<String>> getRemoteFileList() async {
    List<String> result = [];

    return Future<List<String>>.value(result);
  }
}
