import 'package:flutter_web/material.dart';
import 'package:provider/provider.dart';

import 'graph_editor/graph_canvas.dart';

void main() => runApp(TheApp());

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class TheApp extends StatefulWidget {
  @override
  _TheAppState createState() => _TheAppState();
}

class _TheAppState extends State<TheApp> {
  GraphEditorPage _editorPage;
  AboutPage _aboutPage;

  @override
  void initState() {
    _editorPage = GraphEditorPage();
    _aboutPage = AboutPage();
    print("Creating New App Pages");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tide Chart Editor",
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/about':
            return SlideRightRoute(widget: _aboutPage);
        }

        return MaterialPageRoute(builder: (ctx) => _editorPage);
      },
      navigatorObservers: [routeObserver],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text("Tide Charts UI"),
            RaisedButton(
              child: Text("Back"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

class GraphEditorPage extends StatelessWidget {
  const GraphEditorPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Container(color: Colors.green, child: Text("Side Bar")),
      body: MultiProvider(
        providers: [...GraphCanvas.providers],
        child: Row(
          children: <Widget>[
            Expanded(child: GraphCanvas()),
            Container(width: 300, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  SlideRightRoute({this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}
