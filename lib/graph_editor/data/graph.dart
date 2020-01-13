import 'package:flutter/material.dart';

import 'package:tide_ui/graph_editor/fonts/SourceSansPro.dart';

class Graph {
  static const bool ShowHitBox = false;
  static const bool ShowPanRect = false;

  static const double MaxZoomScale = 5.0625;
  static const double MinZoomScale = 0.1316872427983539;

  static const double DefaultNodeSize = 80;

  static const double DefaultPortSpacing = 20;
  static const double WidgetPortSpacing = 30;
  static const double DefaultPortPadding = 20;
  static const double DefaultPortOffset = 6;
  static const double DefaultPortSize = 8;
  static const Size DefaultPortHitboxSize = Size(20, 18);

  static const double DefaultGamepadWidth = 250;
  static const double DefaultGamepadHeight = 100;

  static const double DefaultTabReloadMargin = 35; // clicking version #

  static TextStyle DefaultDialogTitleStyle = TextStyle(
      fontSize: 20, fontFamily: "Source Sans Pro", fontWeight: FontWeight.bold);

  static TextStyle DefaultDialogContentStyle =
      TextStyle(fontSize: 15, fontFamily: "Source Sans Pro");

  static TextStyle DefaultDialogButtonStyle =
      TextStyle(fontSize: 15, fontFamily: "Source Sans Pro");

  //
  // Canvas Styling
  //

  static Paint CanvasColor = Paint()..color = Color(0xfffffff0);

  //
  // Library Styling
  //

  static Paint LibraryScrollBarFront = Paint()
    ..color = Color(0xff000000).withAlpha(100);
  static Paint LibraryScrollBarBack = Paint()
    ..color = Color(0xff333300).withAlpha(50);

  static const double LibraryCollapsedWidth = 75;
  static const double LibraryExpandedWidth = 200;
  static const double LibraryShadowWidth = 10;
  static const double LibraryExpandSize = 15;
  static const double LibraryExpandIconSize = 20;
  static const double LibraryExpandIconPadding = 5;

  static const double LibraryTopIconSize = 18;
  static const double LibraryTopIconSpacing = 30;
  static const double LibraryTopIconPadding = 5;

  static const double LibraryCollapsedItemRadius = 5;
  static const double LibraryCollapsedItemSize = 30;
  static const double LibraryCollapsedItemIconSize = 20;
  static const double LibraryCollapsedItemSpacing = 50;
  static const double LibraryCollapsedItemMaxSpacing = 75;

  static const double LibraryDragIconSize = 40;

  static const double LibraryGroupTopPadding = 40;
  static const double LibraryGroupLabelSize = 9;
  static const double LibraryGroupTextSize = 15;
  static const double LibrarySubGroupLabelSize = 7;
  static const double LibraryGroupItemPadding = 5;

  static const double LibraryGroupCollapsedPadding = 10;
  static const double LibraryGroupPadding = 10;
  static const double LibraryGroupIconSize = 20;

  static const double LibraryGridPadding = 10;
  static const double LibraryGridLabelSize = 12;
  static const double LibraryGridIconSize = 20;
  static const int LibraryGridColumns = 5;

  static Paint LibraryClipboardFill = CanvasColor;
  static Paint LibraryClipboardHoverFill = Paint()..color = Color(0xFFDFFEFE);

  static Paint LibraryClipboardBorder = Paint()
    ..color = Color(0xFF333333).withAlpha(150)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static const double LibraryTabPadding = 12;
  static const double LibraryTabIconSize = 15;

  static const double LibraryTabTop = 30;
  static const double LibraryTabBottom = 5;

  static const double LibraryFirstTabPos = 5;
  static const double LibraryFirstTabWidth = 65;
  static const double LibraryFirstTabPadding = -2;

  static const double LibraryDetailedIconSize = 15;
  static const double LibraryDetailedIconSpacing = 10;

  static const double LibraryTitleSize = 12;
  static const double LibraryInfoSize = 10;

  static const double LibraryFileNameSize = 10;
  static const double LibraryFileNameSpacing = 20;
  static const double LibraryFileIconSize = 15;
  static const double LibraryFileIconSpacing = 10;

  static Paint LibraryTitleColor = Paint()
    ..color = Color(0xff333333).withAlpha(200);

  static Paint LibraryFileColor = Paint()
    ..color = Color(0xff333333).withAlpha(200);

  static Paint LibraryTabsBackFill = Paint()
    ..color = Color(0xffeeeeee)
    ..style = PaintingStyle.fill;

  static Paint LibraryTabsOutline = Paint()
    ..color = Color(0xff888888)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static Paint LibraryGroupLabelColor = Paint()
    ..color = Color(0xff333333).withAlpha(200);

  static Paint LibraryDragIconColor = Paint()
    ..color = Color(0xff333333).withAlpha(150);

  static Paint LibraryCollapsedItemBorder = Paint()
    ..color = Color(0xff888888).withAlpha(100)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static Paint LibraryItemIconActiveColor = Paint()
    ..color = Color(0xff333333).withAlpha(200);

  static Paint LibraryItemIconColor = Paint()
    ..color = Color(0xff333333).withAlpha(150);

  static Paint LibraryItemIconDisabledColor = Paint()
    ..color = Color(0xff333333).withAlpha(50);

  static Paint LibraryItemIconHoverColor = Paint()..color = Colors.black;

  static Paint LibraryItemIconAlertColor = Paint()..color = GroupColors[0];

  static Paint LibraryTopIconColor = Paint()
    ..color = Color(0xff333333).withAlpha(150);

  static Paint LibraryTopIconHoverColor = Paint()
    ..color = Color(0xff333333).withAlpha(150);

  static Paint LibraryTopIconSelectedColor = Paint()..color = Colors.black;

  static Color LibraryShadowStart = Color(0xfffffff0).withAlpha(50);
  static Color LibraryShadowEnd = Color(0xff888888).withAlpha(100);

  static Paint LibraryColor = Paint()..color = Color(0xfffffff0);

  static Paint LibraryEdgeColor = Paint()
    ..color = Color(0xff888888).withAlpha(100)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static Paint LibraryExpandIconColor = Paint()
    ..color = Color(0xff333333).withAlpha(100);

  static Paint LibraryExpandIconEdgeColor = Paint()
    ..color = Color(0xff888888).withAlpha(100)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static Paint LibraryVersionHoverColor = Paint()..color = Colors.green;

  static Paint LibraryVersionColor = Paint()..color = Color(0xff888888);

  static Paint LibraryVersionLine = Paint()
    ..color = LibraryVersionColor.color
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static Paint LibraryVersionCurrentColor = Paint()..color = Color(0xff333333);

  static Paint LibraryVersionCurrentLine = Paint()
    ..color = LibraryVersionCurrentColor.color
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  //
  // Zoom Slider Styling
  //

  static const double ZoomSliderLeftMargin = 100;
  static const double ZoomSliderRightMargin = 35;
  static const double ZoomSliderBottomMargin = 15;

  static const double ZoomSliderSize = 10;

  static Paint ZoomSliderLeftLine = Paint()
    ..color = Color(0xff333300).withAlpha(100)
    ..color = Color(0xff000000).withAlpha(100)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  static Paint ZoomSliderIconColor = Paint()
    ..color = Color(0xff333300).withAlpha(50);

  static Paint ZoomSliderRightLine = Paint()
    //..color = Color(0xffbaba6c).withAlpha(100)
    ..color = Color(0xff333300).withAlpha(50)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static Paint ZoomSliderColor = Paint()..color = Color(0xfffffff0);
  static Paint ZoomSliderShadow = Paint()
    ..color = Color(0xff333333).withAlpha(25);

  static Paint ZoomSliderOutline = Paint()
    ..color = Color(0xff333300).withAlpha(100)
    ..strokeWidth = .5
    ..style = PaintingStyle.stroke;

  //
  //
  // Node Styling
  //
  static double NodeCornerRadius = 10;

  static double NodeTriggerLabelSize = 12;
  static double NodeTriggerIconSize = 22;
  static double NodeTriggerIconPadding = 5;
  static double NodeTriggerLabelPadding = 15;
  static double NodeTriggerPaddingLeft = 30;
  static double NodeTriggerPaddingRight = 5;
  static double NodeTriggerPaddingVertical = 10;
  static double NodeTriggerRadius = 6.5;
  static double NodeTriggerHeight = 35;
  static Paint NodeTriggerLabelColor = Paint()..color = Colors.white;

  static Paint NodeColor = Paint()..color = Colors.white;
  static Paint NodeDarkColor = Paint()..color = Color(0xFF333333);
  static Paint NodeHoverColor = Paint()..color = Color(0xFFDFFEFE);
  static Paint NodeSelectedColor = Paint()..color = Color(0xFFDEFCE9);

  static Paint NodeLabelBorder = Paint()
    ..color = Color(0xFF333333)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static Paint NodeBorder = Paint()
    ..color = Color(0xFF333333)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  static Paint NodeShadow = Paint()
    ..color = Color(0x80FFFFFF)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  static Paint NodeHoverShadow = Paint()
    ..color = Color(0x19000000)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  static Paint NodeIconColor = Paint()..color = Colors.black;
  static Paint NodeZoomedIconColor = Paint()
    ..color = Colors.black.withAlpha(64);
  static Paint NodeInportIconColor = Paint()..color = Color(0xFF2ecc40);
  static Paint NodeOutportIconColor = Paint()..color = Color(0xFFff851b);
  static Paint NodeHoverDarkIconColor = Paint()..color = Color(0xFFDFFEFE);

  static Paint NodeStatusIconColor = Paint()..color = Color(0xFF333333);
  static Paint NodeZoomedStatusIconColor = Paint()..color = Color(0x40333333);

  static Paint NodeLabelShadow = Paint()
    ..color = CanvasColor.color.withAlpha(200);

  //
  //  Port Styling
  //
  static Paint PortColor = Paint()..color = Colors.white;
  static Paint PortIconColor = Paint()
    ..color = Color(0xFF333333).withAlpha(128);

  static Paint DefaultPortColor = PortColor;
  static Paint PortHoverColor = Paint()..color = Colors.cyan[50];
  static Paint PortBorder = Paint()
    ..color = Color(0xFF333333).withAlpha(128)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  static Paint PortHoverBorder = Paint()
    ..color = Color(0xFF333333).withAlpha(128)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  static Paint PortLabelShadow = Paint()
    ..color = CanvasColor.color.withAlpha(200);

  static double PortValueLabelSize = 10;
  static double PortValueIconSize = 10;
  static double PortValueLeader = 5;
  static double PortValueHeight = 20;

  static double PortValueFlagWidth = 10;
  static double PortValueIconPadding = 3;
  static double PortValuePaddingEnd = 5;
  static double PortValuePaddingStart = 0;

  static double PortFilterFlagPadding = 25;
  static Paint PortValueBorder = Paint()
    ..color = Color(0xFF333333)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  static Paint PortErrorLabelColor = Paint()..color = Colors.red[200];
  static Paint PortValueLabelColor = Paint()..color = Colors.yellow[200];
  static Paint PortTriggerLabelColor = Paint()..color = Colors.green[200];
  static Paint PortLinkLabelColor = Paint()..color = Colors.purple[100];
  static Paint PortEventLabelColor = Paint()..color = Colors.orange[200];

  //
  // Link Styles
  //
  static const double LinkPathWidth = 4;
  static double LinkPathHitWidth = 6;
  static Paint LinkHoverShadowColor = Paint()
    ..color = Colors.black.withAlpha(128)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  static Paint LinkArrowHoverShadowColor = Paint()
    ..color = Colors.black.withAlpha(128)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  static Paint LinkShadowColor = Paint()
    ..color = CanvasColor.color.withAlpha(200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  static Paint LinkArrowShadowColor = Paint()
    ..color = CanvasColor.color.withAlpha(200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  static Color DefaultLinkColor = Color(0xFF333333);
  static const double LinkArrowSize = 16;
  static const double LinkArrowEpsilon = 0.01;
  static const int LinkPathSteps = 10;

  //
  //  Radial Menu Styles
  //

  static const double RadialMenuSize = 100;
  static const double RadialMenuCenter = 40;
  static const double RadialMenuIconPos = 70;
  static const double RadialMenuIconSize = RadialMenuCenter * .90;
  static const double RadialMenuMargin = 10;

  static Paint RadialMenuColor = Paint()
    ..color = Color(0xefefef).withAlpha(250);
  static Paint RadialMenuHoverColor = Paint()..color = Colors.cyan[50];
  static Paint RadialMenuIconColor = Paint()
    ..color = Color(0xff333333).withAlpha(190);
  static Paint RadialMenuHoverIconColor = Paint()..color = Colors.black;

  static Paint RadialMenuDisabledIconColor = Paint()..color = Color(0xffaaaaaa);

  static Paint RadialMenuCenterColor = Paint()..color = Color(0xfff8f8f8);
  static Paint RadialMenuBorder = Paint()
    ..color = Colors.black.withAlpha(200)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static Paint RadialMenuSectorBorder = Paint()
    ..color = Colors.black.withAlpha(90)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static Paint RaidalMenuCenterBorder = Paint()
    ..color = Colors.black.withAlpha(90)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  //
  //  Other Styles
  //
  static var font = SourceSansProFont;
  static Paint blackPaint = Paint()..color = Colors.black;
  static Paint whitePaint = Paint()..color = Colors.white;

  static Paint redPen = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  static Paint SelectionBorder = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0;

  static double SelectDashSize = 10;

  //
  // Utlitity methods and properties
  //
  static double TabSwipeDelta = 25;

  static Duration DoubleClickDuration = Duration(milliseconds: 250);
  static Duration LongPressDuration = Duration(milliseconds: 350);
  static Duration LongPressUpdatePeriod = Duration(milliseconds: 20);

  static const double LongPressDistance = 10;
  static const double LongPressRadius = 75;
  static const double LongPressStartRadius = 15;

  static Paint LongPressHighlight = Paint()
    ..color = Colors.blue[200].withAlpha(100);

  static const double AutoPanMargin = 50;
  static const double MaxAutoPan = 15;

  static bool isZoomedIn(double scale) => scale > 2.0;
  static bool isZoomedOut(double scale) => scale < .5;

  static Color getGroupColor(int group, [bool disabled = false]) {
    return disabled
        ? DisabledGroupColor
        : GroupColors[group % GroupColors.length];
  }

  static int MaxGroupNumber = 2 ^ 32 - 1;

  static List<Color> GroupColors = [
    Color(0xFF001f3f),
    Color(0xFF0074d9),
    Color(0xFF7fdbff),
    Color(0xFF39cccc),
    Color(0xFF3d9970),
    Color(0xFF2ecc40),
    Color(0xFF01ff70),
    Color(0xFFffdc00),
    Color(0xFFff851b),
    Color(0xFFff4136),
    Color(0xFF85144b),
    Color(0xFFf012be),
    Color(0xFFb10dc9),
  ];

  static Color DisabledGroupColor = Color(0xFF777777);
}
