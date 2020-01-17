import 'package:tide_chart/tide_chart.dart';
import 'java_file.dart';

class JavaProject {
  /// java files used to generate chart templates
  List<JavaFile> sourceFiles = [];

  /// extra java files needed to build output
  List<JavaFile> supportFiles = [];

  /// java files generated as output
  List<JavaFile> outputFiles = [];

  /// chart templates generated from java source files
  List<TideChartLibrary> library = [];

  /// chart files used to generate java output files
  List<TideChartData> charts = [];
}
