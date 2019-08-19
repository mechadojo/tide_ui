import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/icons/font_awesome_icons.dart';
import 'graph_editor/graph_editor.dart';

const String AppVersion = "0.18";
const String ReleaseVersion = "0.$AppVersion";

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
    return Card(
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Tide Charts UI"),
              IconButton(
                icon: Icon(FontAwesomeIcons.home),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
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
