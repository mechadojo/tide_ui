import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/library_state.dart';
import 'painter/library_painter.dart';

class GraphLibrary extends StatefulWidget {
  GraphLibrary({Key key}) : super(key: key);

  _GraphLibraryState createState() => _GraphLibraryState();
}

class _GraphLibraryState extends State<GraphLibrary> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryState>(
      builder: (context, LibraryState library, widget) {
        return CustomPaint(
            painter: GraphLibraryPainter(library), child: Container());
      },
    );
  }
}

class GraphLibraryPainter extends CustomPainter {
  final LibraryState library;
  final LibraryPainter libraryPainter = LibraryPainter();

  GraphLibraryPainter(this.library);

  @override
  void paint(Canvas canvas, Size size) {
    libraryPainter.paint(canvas, size, library);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
