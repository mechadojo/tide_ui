import 'package:flutter/material.dart';
import 'package:tide_ui/graph_editor/data/gamepad_state.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/data/graph_node.dart';
import 'package:tide_ui/graph_editor/data/widget_state.dart';
import '../utility/parse_path.dart' show parseSvgPathData;
import 'node_port_painter.dart';
import 'widget_node_painter.dart';

class GamepadPainter extends WidgetNodePainter {
  static Color colorBodyStart = Color(0xFF6B7592);
  static Color colorBodyEnd = Color(0xFF1C273D);
  static Paint paintBody = Paint()..color = colorBodyStart;

  static Color colorGripStart =
      Color(0xFF1C273D).withAlpha((255 * .25).round());
  static Color colorGripEnd = Colors.black;
  static Paint paintGrip = Paint()..color = colorGripStart;

  static Color colorThumbBaseStart = Colors.black;
  static Color colorThumbBaseEnd = Color(0xFF6B7592);
  static Paint paintThumbBase = Paint()..color = colorThumbBaseEnd;

  static Color colorButtonBaseStart =
      Color(0xFF6B7592).withAlpha((255 * .5).round());
  static Color colorButtonBaseEnd = Color(0xFF1C273D).withAlpha(0);
  static Paint paintButtonBase = Paint()..color = colorButtonBaseStart;

  static Color colorButtonUpperStart =
      Color(0xFF6B7592).withAlpha((255 * .5).round());
  static Color colorButtonUpperEnd =
      Color(0xFF6B7592).withAlpha((255 * .25).round());
  static Paint paintButtonUpper = Paint()..color = colorButtonUpperStart;

  static Color colorButtonTopStart = Color(0xFF333333).withAlpha(25);
  static Color colorButtonTopEnd = Colors.black.withAlpha((255 * .5).round());
  static Paint paintButtonTop = Paint()..color = colorButtonTopStart;
  static Paint paintThumbButtonTop = Paint()..color = Color(0xFF333333);

  static Color colorButtonShadowStart =
      Colors.black.withAlpha((255 * .5).round());
  static Color colorButtonShadowEnd = Colors.black.withAlpha(0);
  static Paint paintButtonShadow = Paint()..color = colorButtonShadowStart;

  static Color colorDpadTopStart = Color(0xFF555555);
  static Color colorDpadTopEnd =
      Color(0xFF333333).withAlpha((255 * .5).round());
  static Paint paintDpadTop = Paint()..color = colorDpadTopStart;

  static Color colorDpadStart =
      Color(0xFF333333).withAlpha((255 * .75).round());
  static Color colorDpadEnd = Color(0xFF333333).withAlpha((255 * .25).round());
  static Paint paintDpad = Paint()..color = colorDpadStart;

  static Color colorBButtonStart =
      Color(0xFFD91921).withAlpha((255 * .75).round());
  static Color colorBButtonEnd = Colors.black.withAlpha((255 * .25).round());
  static Paint paintBButton = Paint()..color = colorBButtonStart;

  static Color colorAButtonStart =
      Color(0xFF83B656).withAlpha((255 * .75).round());
  static Color colorAButtonEnd = Colors.black.withAlpha((255 * .25).round());
  static Paint paintAButton = Paint()..color = colorAButtonStart;

  static Color colorXButtonStart =
      Color(0xFF2657BC).withAlpha((255 * .75).round());
  static Color colorXButtonEnd = Colors.black.withAlpha((255 * .25).round());
  static Paint paintXButton = Paint()..color = colorXButtonStart;

  static Color colorYButtonStart =
      Color(0xFFFDC713).withAlpha((255 * .75).round());
  static Color colorYButtonEnd = Colors.black.withAlpha((255 * .25).round());
  static Paint paintYButton = Paint()..color = colorYButtonStart;

  static Paint paintABXYLabel = Paint()
    ..color = Colors.white.withAlpha((255 * .65).round());

  static Color colorSmallButtonTopStart =
      Color(0xFF333333).withAlpha((255 * .75).round());
  static Color colorSmallButtonTopEnd =
      Colors.black.withAlpha((255 * .5).round());
  static Paint paintSmallButtonTop = Paint()..color = colorSmallButtonTopStart;

  static Color colorSmallButtonShadowStart =
      Color(0xFF1C273D).withAlpha((255 * .125).round());
  static Color colorSmallButtonShadowEnd = Color(0xFF6B7592).withAlpha(0);
  static Paint paintSmallButtonShadow = Paint()
    ..color = colorSmallButtonShadowStart;

  static Paint paintSmallLabel = Paint()
    ..color = Color(0xFF1C273D).withAlpha((255 * .35).round());

  static Color colorBumperStart = Color(0xFF555555);
  static Color colorBumperEnd = Color(0xFF333333);
  static Paint paintBumper = Paint()..color = colorBumperStart;

  static Color colorTriggerStart = Color(0xFF444444);
  static Color colorTriggerEnd = Color(0xFF222222);
  static Paint paintTrigger = Paint()..color = colorTriggerStart;

  static Paint paintLogo = Paint()..color = Colors.white;

  static Paint penBody = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static Paint penHoverBodyShadow = Paint()
    ..color = Color(0xFFDFFEFE).withAlpha(200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static Paint penHoverBody = Paint()
    ..color = Colors.black.withAlpha(200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  static Paint paintLedOn = Paint()..color = Color(0xFF83B656);
  static Paint paintLedOff = Paint()..color = Colors.green;
  static Paint penLed = Paint()
    ..color = Colors.black.withAlpha((255 * .25).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static Paint penButtonBase = Paint()
    ..color = Colors.black.withAlpha((255 * .35).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static Paint penDpad = Paint()
    ..color = Colors.black.withAlpha((255 * .125).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  static Paint penSmallButton = Paint()
    ..color = Colors.black.withAlpha((255 * .125).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static Paint penABXYButton = Paint()
    ..color = Colors.black.withAlpha((255 * .125).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static Paint penBumper = Paint()
    ..color = Colors.black.withAlpha((255 * .75).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static Paint penCenterButton = Paint()
    ..color = Color(0xFF1C273D).withAlpha((255 * .35).round())
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static Path leftTrigger = parseSvgPathData(
      "m 139.59148,38.787013 c -0.53125,-3.232953 0.23,-7.632617 -1.74896,-10.322852 -1.97896,-2.690234 -3.87372,-3.463602 -6.10978,-3.650963 -1.96526,-0.164672 -8.31658,0.191091 -10.2413,0.463812 -2.06623,0.292771 -7.77223,1.510688 -10.17726,2.451095 -1.92809,0.753913 -5.68057,2.908396 -7.38329,4.576717 -1.70272,1.668321 -2.82154,2.716172 -3.49213,5.100475 -0.670583,2.384303 -0.596074,6.109777 -0.596074,6.109777 z");
  static Path rightTrigger = parseSvgPathData(
      "m 383.86237,40.566022 c 0.53125,-3.232953 -0.23,-7.632617 1.74896,-10.322852 1.97896,-2.690234 3.87372,-3.463602 6.10978,-3.650963 1.96526,-0.164672 8.31658,0.191091 10.2413,0.463812 2.06623,0.292771 7.77223,1.510688 10.17726,2.451095 1.92809,0.753913 5.68057,2.908396 7.38329,4.576717 1.70272,1.668321 2.82154,2.716172 3.49213,5.100475 0.67059,2.384303 0.59608,6.109777 0.59608,6.109777 z");
  static Path leftBumper = parseSvgPathData(
      "m 140.2482,40.282568 c 0.0652,-3.269103 0.0559,-4.908311 0.0559,-4.908311 0,0 -0.13039,-1.574012 -0.72647,-2.319107 -1.0439,-1.034869 -1.89725,-1.450051 -2.84788,-1.993676 -0.95063,-0.543625 -2.14527,-1.238616 -3.15013,-1.471013 -3.07862,-0.711995 -22.35284,0.335292 -27.9038,1.452933 -2.79958,0.563674 -4.24704,0.894114 -5.960755,1.49019 -2.28759,1.112556 -4.06622,2.804422 -5.58136,4.324518 -1.56215,1.567251 -1.67069,1.56248 -1.78979,2.598791 -0.0527,0.458423 -0.0309,2.765891 -0.0309,2.765891 z");
  static Path rightBumper = parseSvgPathData(
      "m 381.56298,41.428808 c -0.0652,-3.269103 -0.0559,-4.908311 -0.0559,-4.908311 0,0 0.13039,-1.574012 0.72647,-2.319107 1.0439,-1.034869 1.89725,-1.450051 2.84788,-1.993676 0.95063,-0.543625 2.14527,-1.238617 3.15013,-1.471014 3.07862,-0.711995 22.35284,0.335292 27.9038,1.452934 2.79958,0.563674 4.24704,0.894114 5.96075,1.49019 2.28759,1.112556 4.06622,2.804422 5.58136,4.324518 1.56215,1.567251 1.67069,1.56248 1.78979,2.598791 0.0527,0.458423 0.0309,2.765891 0.0309,2.765891 z");
  static Path gamepadBody = parseSvgPathData(
      "M 427.88255,322.14456 C 413.96411,317.57044 400.25435,305.8007 390,289.62262 c -13.55999,-21.39331 -17.25786,-26.74547 -19.48868,-28.20716 -2.28137,-1.49481 -2.61139,-1.38287 -7.63866,2.59096 -6.43282,5.08486 -12.60093,8.2773 -20.33859,10.5267 -8.04384,2.33841 -24.74686,1.64002 -32.44431,-1.35656 -11.74564,-4.57253 -21.9258,-13.34622 -28.47042,-24.53702 l -3.71385,-6.35039 -8.48264,0.20111 c -4.52389,0.10725 -13.31108,-0.22144 -18.8704,-0.22474 l -10.10787,-0.006 -3.5659,5.75 c -13.08064,21.09249 -38.17371,31.14799 -60.41858,25.46885 -8.1822,-2.08892 -17.25886,-6.66887 -22.68861,-11.44832 l -4.54437,-4.00012 -3.89178,4.23503 c -2.14048,2.32927 -7.17727,9.65617 -11.19288,16.28201 -9.25453,15.27017 -17.47906,25.24179 -25.94928,31.46153 -9.494949,6.97221 -15.647015,9.13412 -27.699516,9.73397 C 63.270407,320.59967 52.486156,316.4152 39.922028,304 24.100832,288.36634 18.553064,268.33819 18.593143,227 c 0.02317,-23.89839 1.029176,-35.75434 4.995409,-58.87175 4.110987,-23.96111 14.120859,-62.48405 20.960787,-80.667467 9.618792,-25.57081 23.00252,-40.433435 41.83955,-46.462804 21.917491,-5.65417 46.893781,-6.95003 62.415891,-5.522423 24.63245,2.241552 34.9379,7.805887 42.66997,23.039265 4.47036,8.807312 10.76562,15.174038 20.78483,15.940993 40.56734,0.974226 47.12418,0.517025 79.84847,1.169529 18.82413,-0.59989 23.79201,-0.136018 29.85064,-5.321974 2.44965,-2.096811 5.55285,-6.354806 7.61351,-10.446742 3.65099,-7.249889 9.313,-13.711662 14.25301,-16.266237 5.39314,-2.788906 17.58508,-5.634413 26.81873,-6.259294 l 9.14395,-0.618809 c 16.80233,-0.04168 44.66117,3.075489 53.96211,6.892429 24.21649,9.70379 33.82547,21.805417 45.19439,56.918224 10.63779,32.85471 19.10286,73.53316 22.05353,105.97706 1.28942,14.17778 1.27313,44.45317 -0.0301,56 -3.17332,28.11541 -14.82316,47.44117 -34.41317,57.08758 -10.09198,4.27613 -15.21362,4.00909 -20.5,4.15775 -9.36452,0.26334 -14.32995,-0.36743 -18.17206,-1.60077 z");
  static Path rightGrip = parseSvgPathData(
      "M 488.67773 135.19727 C 487.28545 157.8579 485.90039 163.70508 485.90039 163.70508 C 485.90039 163.70508 481.9979 181.0679 477.50391 190.29688 C 473.51291 198.49289 470.42005 209.1277 468.05859 219.11914 C 465.37613 230.46877 464.69996 245.26496 464.97656 261.70312 C 465.27853 279.64891 467.91035 294.02246 473.4043 303.26562 C 476.01482 307.65762 478.07224 309.79136 479.4082 310.85742 C 491.29806 300.03381 498.56593 283.7888 500.96875 262.5 C 502.27198 250.95317 502.28747 220.67778 500.99805 206.5 C 499.02552 184.81122 494.58064 159.44859 488.67773 135.19727 z ");
  static Path leftGrip = parseSvgPathData(
      "M 30.728516 134.86133 C 27.801475 146.79018 25.221289 158.60856 23.587891 168.12891 C 19.621658 191.24632 18.61692 203.10161 18.59375 227 C 18.553671 268.33819 24.100679 288.36634 39.921875 304 C 40.982885 305.04843 42.029739 306.01626 43.070312 306.94922 C 44.203568 305.72485 45.543405 303.62766 46.978516 300.01172 C 50.945086 290.01742 54.000764 277.40672 54.302734 259.46094 C 54.579334 243.02278 53.90121 228.22463 51.21875 216.875 C 48.85729 206.88356 45.766391 196.24874 41.775391 188.05273 C 37.281401 178.82376 33.378906 161.46289 33.378906 161.46289 C 33.378906 161.46289 32.076486 155.83788 30.728516 134.86133 z ");
  static Path rightButtonBase = parseSvgPathData(
      "m 399.37109,69.595703 c -39.83081,6e-6 -72.12028,33.090467 -72.12109,73.910157 0.01,8.40204 1.41741,16.73326 4.15522,24.63721 0.33235,0.95947 0.11075,1.5533 -0.2482,2.03928 -0.35894,0.48597 -1.30738,0.64172 -2.616,0.62429 -29.40033,4.7e-4 -53.23389,23.56821 -53.23438,52.64063 -6e-4,29.07318 23.83328,52.6421 53.23438,52.64257 29.40186,5.8e-4 53.23692,-23.56864 53.23632,-52.64257 -0.004,-1.75828 -0.0974,-3.51455 -0.27908,-5.26224 -0.1142,-1.09882 -0.0148,-1.64339 0.42184,-2.15189 0.43667,-0.50849 1.23718,-0.5804 2.29801,-0.34118 4.97431,1.12173 10.05361,1.70095 15.15298,1.72601 39.83156,0 72.12135,-33.09165 72.1211,-73.91211 -8.1e-4,-40.81969 -32.29029,-73.910156 -72.1211,-73.910157 z");
  static Path leftButtonBase = parseSvgPathData(
      "m 117.88274,67.879347 c 39.83081,6e-6 72.12028,33.090463 72.12109,73.910153 -0.01,8.40204 -1.41741,16.73326 -4.15522,24.63721 -0.33235,0.95947 -0.11075,1.5533 0.2482,2.03928 0.35894,0.48597 1.30738,0.64172 2.616,0.62429 29.40033,4.7e-4 53.23389,23.56821 53.23438,52.64063 6e-4,29.07318 -23.83328,52.6421 -53.23438,52.64257 -29.40186,5.8e-4 -53.23692,-23.56864 -53.23632,-52.64257 0.004,-1.75828 0.0974,-3.51455 0.27908,-5.26224 0.1142,-1.09882 0.0148,-1.64339 -0.42184,-2.15189 -0.43667,-0.50849 -1.23718,-0.5804 -2.29801,-0.34118 -4.97431,1.12173 -10.05361,1.70095 -15.15298,1.72601 -39.831564,0 -72.121354,-33.09165 -72.121104,-73.91211 8.1e-4,-40.81969 32.29029,-73.910152 72.121104,-73.910153 z");
  static Path gamepadDpad = parseSvgPathData(
      "M 119.21484 102.67578 A 38.744923 38.744923 0 0 0 107.29297 104.60547 L 107.29297 130.14062 L 82.158203 130.14062 A 38.744923 38.744923 0 0 0 80.470703 141.41992 A 38.744923 38.744923 0 0 0 82.498047 153.64062 L 107.29297 153.64062 L 107.29297 178.26367 A 38.744923 38.744923 0 0 0 119.21484 180.16602 A 38.744923 38.744923 0 0 0 130.83789 178.33594 L 130.83789 153.64062 L 155.94922 153.64062 A 38.744923 38.744923 0 0 0 157.96094 141.41992 A 38.744923 38.744923 0 0 0 156.24414 130.14062 L 130.83789 130.14062 L 130.83789 104.46875 A 38.744923 38.744923 0 0 0 119.21484 102.67578 z ");

  static Rect circleRightThumbButtonBase =
      Rect.fromCircle(center: Offset(328.46143, 223.25136), radius: 53.5);
  static Rect circleLeftThumbButtonBase =
      Rect.fromCircle(center: Offset(188.78754, 222.25136), radius: 53.5);

  static Rect circleRightThumbBase =
      Rect.fromCircle(center: Offset(328.46143, 223.25136), radius: 35);
  static Rect circleLeftThumbBase =
      Rect.fromCircle(center: Offset(188.78754, 222.25136), radius: 35);

  static Rect circleRightButtonBase =
      Rect.fromCircle(center: Offset(399.37076, 143.80481), radius: 72);
  static Rect circleLeftButtonBase =
      Rect.fromCircle(center: Offset(118.91711, 140.82445), radius: 72);

  static Rect circleRightButtonTop =
      Rect.fromCircle(center: Offset(399.37076, 143.80481), radius: 48);
  static Rect circleLeftButtonTop =
      Rect.fromCircle(center: Offset(118.91711, 140.82445), radius: 48);

  static Rect circleDpadBase =
      Rect.fromCircle(center: Offset(118.91711, 140.82445), radius: 46);
  static Rect circleDpadTop =
      Rect.fromCircle(center: Offset(118.91711, 140.82445), radius: 39);

  static Rect circleYBase =
      Rect.fromCircle(center: Offset(399.42575, 108.58138), radius: 22);
  static Rect circleBBase =
      Rect.fromCircle(center: Offset(434.83725, 144.69894), radius: 22);
  static Rect circleABase =
      Rect.fromCircle(center: Offset(399.42575, 180.46349), radius: 22);
  static Rect circleXBase =
      Rect.fromCircle(center: Offset(363.45718, 144.69894), radius: 22);

  static Rect circleYTop =
      Rect.fromCircle(center: Offset(399.42575, 108.58138), radius: 16);
  static Rect circleBTop =
      Rect.fromCircle(center: Offset(434.83725, 144.69894), radius: 16);
  static Rect circleATop =
      Rect.fromCircle(center: Offset(399.42575, 180.46349), radius: 16);
  static Rect circleXTop =
      Rect.fromCircle(center: Offset(363.45718, 144.69894), radius: 16);

  static RRect rrectBackBase = RRect.fromRectXY(
      Rect.fromLTWH(192.22656, 93.726585, 34.364595, 26.913649), 6, 6);
  static RRect rrectModeBase = RRect.fromRectXY(
      Rect.fromLTWH(201.14909, 136.97633, 34.364595, 26.913649), 6, 6);
  static RRect rrectStartBase = RRect.fromRectXY(
      Rect.fromLTWH(292.19077, 94.827423, 34.364595, 26.913649), 6, 6);

  static RRect rrectBackTop = RRect.fromRectXY(
      Rect.fromLTWH(197.22656, 98.726585, 24.364595, 16.913649), 4, 4);
  static RRect rrectModeTop = RRect.fromRectXY(
      Rect.fromLTWH(206.14909, 141.97633, 24.364595, 16.913649), 4, 4);
  static RRect rrectStartTop = RRect.fromRectXY(
      Rect.fromLTWH(297.19077, 99.827423, 24.364595, 16.913649), 4, 4);

  static RRect rrectCenterButton = RRect.fromRectXY(
      Rect.fromLTWH(232.9166, 104.61284, 53.646816, 40.980206), 20, 20);

  static Rect circleModeLed =
      Rect.fromCircle(center: Offset(241.82942, 157.75653), radius: 3.2665412);

  static Offset logitechOffset = Offset(241, 105);
  static double logitechScale = .075;
  static Path logitechText = parseSvgPathData(
      "M337.587,171.769c-4.808-1.918-19.319-2.662-29.721-1.364     c-7.961,1.567-4.73,5.689,3.453,8.797c6.451,2.907,15.142,3.003,21.344,0.433C339.301,177.101,341.882,173.636,337.587,171.769z      M296.871,210.588c-6.396-2.093-7.457,1.327-0.871,9.441c7.256,8.909,18.38,17.391,24.06,17.969     c4.351-0.711,2.028-7.911-3.522-14.429C311.544,217.621,303.119,212.302,296.871,210.588z M295.945,135.509     c12.791-6.753,22.174-15.824,20.94-20.252c-1.225-4.436-6.724-6.229-12.288-4.003c-5.557,2.223-14.935,11.282-20.953,20.25     C277.643,140.452,283.141,142.249,295.945,135.509z M225.101,154.137c3.939-13.451,16.313-30.513,20.531-36.52     c0.556-0.801,1.749-2.758,1.242-4.769c-0.628-2.517-4.055-3.814-6.936-4.183c-4.92-0.632-8.909,0.125-12.366,0.874     c-9.104,1.955-16.234,5.432-21.202,8.681c-3.604,2.366-7.581,5.484-11.457,9.309c-13.01,12.853-25.832,34.219-21.974,59.176     c2.209,14.932,10.043,25.908,16.756,34.081c8.799,10.199,22.787,19.578,35.111,17.399c5.686-1.115,10.084-5.773,12.137-9.596     c7.955-14.687-5.13-33.804-8.909-41.374C223.128,177.962,220.875,168.565,225.101,154.137z M296.871,169.144     c-0.688-10.363-15.346-17.677-33.843-17.172c-14.607,0.405-30.998,9.271-30.993,20.379c0.012,12.183,9.421,17.095,13.098,18.551     c0.888,0.35,1.189,0.241,1.751,1.872c1.069,3.095,4.09,10.656,13.925,10.635C274.115,203.38,297.891,184.388,296.871,169.144z      M251.278,176.302c-0.946,3.835-1.688,2.159-2.119,1.073c-0.669-1.672-0.923-3.448-0.923-5.024     c0-5.628,4.286-10.395,12.329-10.395c1.855,0,2.576,0.583,0.67,1.481c-0.66,0.322-1.369,0.769-1.98,1.156     C255.18,167.135,252.489,171.327,251.278,176.302z M272.641,194.138c-2.084,2.495-5.389,4.351-8.042,4.351     c-3.556,0-6.21-1.984-7.12-4.85c-0.228-0.716-0.316-1.477-0.352-2.284c-0.031-0.86,0.26-0.486,2.799,0.458     c1.742,0.645,3.926,1.26,6.164,1.26c0.906,0,1.787-0.087,2.627-0.245C270.158,192.553,274.689,191.7,272.641,194.138z      M269.486,183.469c-6.74,0-11.139-2.334-11.139-6.801c0-3.73,6.827-12.557,13.572-12.557c4.965,0,9.863,5.914,9.863,9.458     C281.783,178.091,276.885,183.469,269.486,183.469z");
  static Path logitechLogo = parseSvgPathData(
      "M211.606,325.119c-6.363-7.571-15.842-12.02-25.855-12.02     c-18.501,0-33.553,14.731-33.553,32.838v0.255c0,18.041,15.051,32.719,33.553,32.719c10.269,0,19.546-4.377,25.855-12.106v4.254     c0,15.95-9.099,25.1-24.966,25.1c-9.251,0-17.854-2.998-25.57-8.908l-1.779-1.364l-5.015,6.906l1.727,1.313     c9.286,7.021,19.308,10.433,30.637,10.433c10.036,0,18.782-3.234,24.628-9.108c5.836-5.869,8.921-14.118,8.921-23.854v-56.938     h-8.583V325.119z M211.988,346.192c0,13.416-11.602,24.332-25.861,24.332c-13.834,0-25.089-10.971-25.089-24.455v-0.259     c0-13.646,11.02-24.335,25.089-24.335c14.259,0,25.861,10.974,25.861,24.462V346.192z M112.803,313.104     c-19.956,0-35.589,15.83-35.589,36.038v0.258c0,20.066,15.581,35.785,35.471,35.785c19.886,0,35.462-15.832,35.462-36.043v-0.258     C148.147,328.821,132.622,313.104,112.803,313.104z M139.427,349.27c0,15.767-11.446,27.657-26.624,27.657     c-15.001,0-26.75-12.148-26.75-27.657v-0.251c0-15.771,11.394-27.665,26.502-27.665c15.068,0,26.872,12.151,26.872,27.665V349.27     z M80.558,376.033l-0.654-0.77H34.729v-85.748h-8.708v94.132h62.512l-4.292-3.84C82.86,378.563,81.622,377.293,80.558,376.033z      M457.271,313.1c-11.75,0-18.788,6.009-22.543,10.833v-34.417h-8.457v94.139h8.457v-38.615c0-13.281,9.68-23.686,22.036-23.686     c12.991,0,20.747,8.567,20.747,22.919v39.382h8.467v-40.026C485.979,324.798,474.978,313.1,457.271,313.1z M317.687,313.096     c-18.76,0-32.905,15.386-32.905,35.789v0.258c0,20.885,14.328,36.043,34.069,36.043c14.208,0,23.062-7.718,27.983-14.186     l1.338-1.725l-6.506-5.166l-1.352,1.762c-5.386,7.03-13.165,11.063-21.345,11.063c-13.139,0-23.585-10.056-25.168-24.056h55.532     v-3.615C349.334,331.844,339.43,313.096,317.687,313.096z M293.816,344.76c1.586-13.622,11.388-23.406,23.624-23.406     c14.062,0,21.539,11.598,22.872,23.406H293.816z M411.593,366.128c-6.583,7.371-13.397,10.806-21.445,10.806     c-14.608,0-26.491-12.47-26.491-27.798v-0.251c0-15.438,11.524-27.531,26.238-27.531c10.433,0,17.105,5.894,21.22,10.33     l1.545,1.65l6.073-6.074l-1.504-1.558c-5.958-6.233-13.849-12.606-27.207-12.606c-19.344,0-35.079,16.115-35.079,35.923v0.244     c0,19.808,15.679,35.923,34.952,35.923c11.133,0,20.005-4.315,27.92-13.58l1.43-1.668l-6.216-5.435L411.593,366.128z      M233.429,301.749h9.865v-12.235h-9.865V301.749z M234.543,383.654h8.583v-69.017h-8.583V383.654z M284.682,376.014l-0.969-1.282     l-1.512,0.558c-2.347,0.847-4.508,1.259-6.609,1.259c-7.433,0-11.201-4.048-11.201-12.029v-41.756h19.581l0.654-0.855     c0.927-1.199,1.962-2.383,3.079-3.518l3.664-3.752h-26.979v-25.122h-8.464v75.396c0,12.454,7.206,19.889,19.278,19.889     c3.865,0,7.623-0.847,11.163-2.513l2.753-1.284l-2.084-2.216C286.122,377.795,285.351,376.886,284.682,376.014z");

  static Size gamepadSize = Size(521, 342);

  NodePortPainter portPainter = NodePortPainter();

  Offset getRightThumbPos({Offset pos = Offset.zero}) {
    var cx = pos.dx * 20;
    var cy = pos.dy * 20;
    cx += 328.46143;
    cy += 223.25136;
    return Offset(cx, cy);
  }

  Offset getLeftThumbPos({Offset pos = Offset.zero}) {
    var cx = pos.dx * 20;
    var cy = pos.dy * 20;
    cx += 188.78754;
    cy += 222.25136;
    return Offset(cx, cy);
  }

  @override
  Size measure(Size size, WidgetState state, double zoom) {
    var scale = size.width / gamepadSize.width;
    var result =
        Size(gamepadSize.width * scale, (gamepadSize.height - 35) * scale);
    return result;
  }

  @override
  void paint(Canvas canvas, Size size, WidgetState state, double zoom,
      {GraphNode node}) {
    var gamepad = state as GamepadState ?? GamepadState();

    canvas.save();
    var scale = size.width / gamepadSize.width;
    canvas.scale(scale, scale);
    canvas.translate(-gamepadSize.width / 2, -gamepadSize.height / 2);

    var zoomedOut = Graph.isZoomedOut(zoom);

    if (node?.hovered ?? false) {
      canvas.drawPath(
          gamepadBody, penHoverBodyShadow..strokeWidth = 20 / scale);
      canvas.drawPath(gamepadBody, penHoverBody..strokeWidth = 4 / scale);
    }

    drawTriggers(canvas, gamepad);
    drawBumpers(canvas, gamepad);
    drawBody(canvas, gamepad, zoomedOut);
    drawABXYButtons(canvas, gamepad, zoomedOut);
    drawDpad(canvas, gamepad);
    drawThumbsticks(canvas, gamepad);
    drawSmallButtons(canvas, gamepad, zoomedOut);
    drawCenterButton(canvas, gamepad, zoomedOut);
    drawLed(canvas, gamepad);

    canvas.restore();
  }

  @override
  void drawNode(Canvas canvas, GraphNode node, double scale) {
    var rect = Rect.fromCenter(
        center: node.pos, width: node.size.width, height: node.size.height);

    var pos = rect.bottomCenter;

    var limits =
        Graph.font.limits(node.title, pos, 8, alignment: Alignment.topCenter);

    var rrect = RRect.fromRectXY(limits.inflate(5), 5, 5);
    if (node.selected) {
      canvas.drawRRect(rrect, Graph.NodeSelectedColor);
      canvas.drawRRect(rrect, Graph.NodeLabelBorder);
    } else {
      canvas.drawRRect(rrect, Graph.CanvasColor);
    }
    Graph.font.paint(canvas, node.title, pos, 8,
        fill: Graph.NodeDarkColor, alignment: Alignment.topCenter);

    for (var port in node.outports) {
      portPainter.paint(canvas, scale, port);
    }
  }

  void drawTriggers(Canvas canvas, GamepadState gamepad) {
    canvas.save();
    canvas.translate(0, -8);
    canvas.drawPath(leftTrigger, paintTrigger);
    canvas.restore();
    canvas.save();
    canvas.translate(0, -8);
    canvas.drawPath(rightTrigger, paintTrigger);
    canvas.restore();
  }

  void drawBumpers(Canvas canvas, GamepadState gamepad) {
    canvas.drawPath(leftBumper, paintBumper);
    canvas.drawPath(rightBumper, paintBumper);
    canvas.drawPath(leftBumper, penBumper);
    canvas.drawPath(rightBumper, penBumper);
  }

  void drawBody(Canvas canvas, GamepadState gamepad, bool zoomedOut) {
    canvas.drawPath(gamepadBody, paintBody);
    canvas.drawPath(rightGrip, paintGrip);
    canvas.drawPath(leftGrip, paintGrip);

    canvas.drawPath(gamepadBody, penBody);

    canvas.drawPath(leftButtonBase, paintButtonBase);
    canvas.drawPath(rightButtonBase, paintButtonBase);
    canvas.drawPath(leftButtonBase, penButtonBase);
    canvas.drawPath(rightButtonBase, penButtonBase);

    canvas.drawOval(circleLeftThumbButtonBase, paintButtonBase);
    canvas.drawOval(circleRightThumbButtonBase, paintButtonBase);

    canvas.drawOval(circleLeftThumbBase, paintThumbBase);
    canvas.drawOval(circleRightThumbBase, paintThumbBase);
    if (!zoomedOut) {
      canvas.drawOval(circleLeftButtonBase, paintButtonBase);
      canvas.drawOval(circleRightButtonBase, paintButtonBase);

      canvas.drawOval(circleLeftButtonTop, paintButtonTop);
      canvas.drawOval(circleRightButtonTop, paintButtonTop);
    }
    canvas.drawOval(circleDpadBase, paintThumbBase);
    canvas.drawOval(circleDpadTop, paintDpadTop);
  }

  void drawABXYButtons(Canvas canvas, GamepadState gamepad, bool zoomedOut) {
    if (!zoomedOut) {
      canvas.drawOval(circleABase, paintButtonBase);
      canvas.drawOval(circleBBase, paintButtonBase);
      canvas.drawOval(circleXBase, paintButtonBase);
      canvas.drawOval(circleYBase, paintButtonBase);
    }

    canvas.drawOval(circleATop, paintAButton);
    canvas.drawOval(circleBTop, paintBButton);
    canvas.drawOval(circleXTop, paintXButton);
    canvas.drawOval(circleYTop, paintYButton);

    if (!zoomedOut) {
      canvas.drawOval(circleATop, penABXYButton);
      canvas.drawOval(circleBTop, penABXYButton);
      canvas.drawOval(circleXTop, penABXYButton);
      canvas.drawOval(circleYTop, penABXYButton);

      Graph.font.paint(canvas, "A", circleATop.center, 18,
          fill: paintABXYLabel, alignment: Alignment.center);
      Graph.font.paint(canvas, "B", circleBTop.center, 18,
          fill: paintABXYLabel, alignment: Alignment.center);
      Graph.font.paint(canvas, "X", circleXTop.center, 18,
          fill: paintABXYLabel, alignment: Alignment.center);
      Graph.font.paint(canvas, "Y", circleYTop.center, 18,
          fill: paintABXYLabel, alignment: Alignment.center);
    }
  }

  void drawDpad(Canvas canvas, GamepadState gamepad) {
    canvas.drawPath(gamepadDpad, paintDpad);
    canvas.drawPath(gamepadDpad, penDpad);
  }

  void drawThumbsticks(Canvas canvas, GamepadState gamepad) {
    var leftPos = getLeftThumbPos();
    var rightPos = getRightThumbPos();

    canvas.drawCircle(leftPos, 35, paintButtonShadow);
    canvas.drawCircle(rightPos, 35, paintButtonShadow);

    canvas.drawCircle(leftPos, 28, paintThumbButtonTop);
    canvas.drawCircle(rightPos, 28, paintThumbButtonTop);
  }

  void drawSmallButtons(Canvas canvas, GamepadState gamepad, bool zoomedOut) {
    if (!zoomedOut) {
      canvas.drawRRect(rrectBackBase, paintSmallButtonShadow);
      canvas.drawRRect(rrectStartBase, paintSmallButtonShadow);
      canvas.drawRRect(rrectModeBase, paintSmallButtonShadow);
    }

    canvas.drawRRect(rrectBackTop, paintSmallButtonTop);
    canvas.drawRRect(rrectStartTop, paintSmallButtonTop);
    canvas.drawRRect(rrectModeTop, paintSmallButtonTop);

    if (!zoomedOut) {
      canvas.drawRRect(rrectBackTop, penSmallButton);
      canvas.drawRRect(rrectStartTop, penSmallButton);
      canvas.drawRRect(rrectModeTop, penSmallButton);

      Graph.font.paint(canvas, "BACK",
          Offset(rrectBackTop.center.dx, rrectBackTop.bottom + 2), 8,
          fill: paintSmallLabel, alignment: Alignment.topCenter);

      Graph.font.paint(canvas, "START",
          Offset(rrectStartTop.center.dx, rrectStartTop.bottom + 2), 8,
          fill: paintSmallLabel, alignment: Alignment.topCenter);

      Graph.font.paint(canvas, "MODE",
          Offset(rrectModeTop.center.dx, rrectModeTop.bottom + 2), 8,
          fill: paintSmallLabel, alignment: Alignment.topCenter);
    }
  }

  void drawCenterButton(Canvas canvas, GamepadState gamepad, bool zoomedOut) {
    canvas.drawRRect(rrectCenterButton, penCenterButton);
    if (!zoomedOut) {
      canvas.save();
      canvas.translate(logitechOffset.dx, logitechOffset.dy);
      canvas.scale(logitechScale);

      canvas.drawPath(logitechLogo, paintLogo);
      canvas.drawPath(logitechText, paintLogo);
      canvas.restore();
    }
  }

  void drawLed(Canvas canvas, GamepadState gamepad) {
    canvas.drawOval(circleModeLed, paintLedOff);
    canvas.drawOval(circleModeLed, penLed);
  }
}
