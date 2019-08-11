///
//  Generated code. Do not modify.
//  source: tide_chart.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

class TideChartProperty extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartProperty')
    ..aOS(1, 'name')
    ..aOS(2, 'type')
    ..aOS(3, 'value')
    ..pc<TideChartProperty>(4, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..hasRequiredFields = false
  ;

  TideChartProperty._() : super();
  factory TideChartProperty() => create();
  factory TideChartProperty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartProperty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartProperty clone() => TideChartProperty()..mergeFromMessage(this);
  TideChartProperty copyWith(void Function(TideChartProperty) updates) => super.copyWith((message) => updates(message as TideChartProperty));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartProperty create() => TideChartProperty._();
  TideChartProperty createEmptyInstance() => create();
  static $pb.PbList<TideChartProperty> createRepeated() => $pb.PbList<TideChartProperty>();
  static TideChartProperty getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartProperty _defaultInstance;

  $core.String get name => $_getS(0, '');
  set name($core.String v) { $_setString(0, v); }
  $core.bool hasName() => $_has(0);
  void clearName() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.String get value => $_getS(2, '');
  set value($core.String v) { $_setString(2, v); }
  $core.bool hasValue() => $_has(2);
  void clearValue() => clearField(3);

  $core.List<TideChartProperty> get props => $_getList(3);
}

enum TideChartCommentBox_Content {
  text, 
  image, 
  icon, 
  notSet
}

class TideChartCommentBox extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartCommentBox_Content> _TideChartCommentBox_ContentByTag = {
    7 : TideChartCommentBox_Content.text,
    8 : TideChartCommentBox_Content.image,
    9 : TideChartCommentBox_Content.icon,
    0 : TideChartCommentBox_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartCommentBox')
    ..oo(0, [7, 8, 9])
    ..aOS(1, 'id')
    ..aOS(2, 'region')
    ..a<$core.int>(3, 'posX', $pb.PbFieldType.OS3)
    ..a<$core.int>(4, 'posY', $pb.PbFieldType.OS3)
    ..a<$core.int>(5, 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(6, 'height', $pb.PbFieldType.O3)
    ..aOS(7, 'text')
    ..a<$core.List<$core.int>>(8, 'image', $pb.PbFieldType.OY)
    ..aOS(9, 'icon')
    ..a<$core.double>(10, 'fontSize', $pb.PbFieldType.OD)
    ..aOS(11, 'fontStyle')
    ..a<$core.int>(12, 'alignment', $pb.PbFieldType.OS3)
    ..a<$core.int>(13, 'color', $pb.PbFieldType.O3)
    ..a<$core.int>(14, 'background', $pb.PbFieldType.O3)
    ..a<$core.int>(15, 'border', $pb.PbFieldType.O3)
    ..aOB(16, 'raised')
    ..aOB(17, 'reversed')
    ..hasRequiredFields = false
  ;

  TideChartCommentBox._() : super();
  factory TideChartCommentBox() => create();
  factory TideChartCommentBox.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartCommentBox.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartCommentBox clone() => TideChartCommentBox()..mergeFromMessage(this);
  TideChartCommentBox copyWith(void Function(TideChartCommentBox) updates) => super.copyWith((message) => updates(message as TideChartCommentBox));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartCommentBox create() => TideChartCommentBox._();
  TideChartCommentBox createEmptyInstance() => create();
  static $pb.PbList<TideChartCommentBox> createRepeated() => $pb.PbList<TideChartCommentBox>();
  static TideChartCommentBox getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartCommentBox _defaultInstance;

  TideChartCommentBox_Content whichContent() => _TideChartCommentBox_ContentByTag[$_whichOneof(0)];
  void clearContent() => clearField($_whichOneof(0));

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get region => $_getS(1, '');
  set region($core.String v) { $_setString(1, v); }
  $core.bool hasRegion() => $_has(1);
  void clearRegion() => clearField(2);

  $core.int get posX => $_get(2, 0);
  set posX($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasPosX() => $_has(2);
  void clearPosX() => clearField(3);

  $core.int get posY => $_get(3, 0);
  set posY($core.int v) { $_setSignedInt32(3, v); }
  $core.bool hasPosY() => $_has(3);
  void clearPosY() => clearField(4);

  $core.int get width => $_get(4, 0);
  set width($core.int v) { $_setSignedInt32(4, v); }
  $core.bool hasWidth() => $_has(4);
  void clearWidth() => clearField(5);

  $core.int get height => $_get(5, 0);
  set height($core.int v) { $_setSignedInt32(5, v); }
  $core.bool hasHeight() => $_has(5);
  void clearHeight() => clearField(6);

  $core.String get text => $_getS(6, '');
  set text($core.String v) { $_setString(6, v); }
  $core.bool hasText() => $_has(6);
  void clearText() => clearField(7);

  $core.List<$core.int> get image => $_getN(7);
  set image($core.List<$core.int> v) { $_setBytes(7, v); }
  $core.bool hasImage() => $_has(7);
  void clearImage() => clearField(8);

  $core.String get icon => $_getS(8, '');
  set icon($core.String v) { $_setString(8, v); }
  $core.bool hasIcon() => $_has(8);
  void clearIcon() => clearField(9);

  $core.double get fontSize => $_getN(9);
  set fontSize($core.double v) { $_setDouble(9, v); }
  $core.bool hasFontSize() => $_has(9);
  void clearFontSize() => clearField(10);

  $core.String get fontStyle => $_getS(10, '');
  set fontStyle($core.String v) { $_setString(10, v); }
  $core.bool hasFontStyle() => $_has(10);
  void clearFontStyle() => clearField(11);

  $core.int get alignment => $_get(11, 0);
  set alignment($core.int v) { $_setSignedInt32(11, v); }
  $core.bool hasAlignment() => $_has(11);
  void clearAlignment() => clearField(12);

  $core.int get color => $_get(12, 0);
  set color($core.int v) { $_setSignedInt32(12, v); }
  $core.bool hasColor() => $_has(12);
  void clearColor() => clearField(13);

  $core.int get background => $_get(13, 0);
  set background($core.int v) { $_setSignedInt32(13, v); }
  $core.bool hasBackground() => $_has(13);
  void clearBackground() => clearField(14);

  $core.int get border => $_get(14, 0);
  set border($core.int v) { $_setSignedInt32(14, v); }
  $core.bool hasBorder() => $_has(14);
  void clearBorder() => clearField(15);

  $core.bool get raised => $_get(15, false);
  set raised($core.bool v) { $_setBool(15, v); }
  $core.bool hasRaised() => $_has(15);
  void clearRaised() => clearField(16);

  $core.bool get reversed => $_get(16, false);
  set reversed($core.bool v) { $_setBool(16, v); }
  $core.bool hasReversed() => $_has(16);
  void clearReversed() => clearField(17);
}

enum TideChartWidget_Target {
  link, 
  port, 
  node, 
  notSet
}

class TideChartWidget extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartWidget_Target> _TideChartWidget_TargetByTag = {
    9 : TideChartWidget_Target.link,
    10 : TideChartWidget_Target.port,
    11 : TideChartWidget_Target.node,
    0 : TideChartWidget_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartWidget')
    ..oo(0, [9, 10, 11])
    ..aOS(1, 'id')
    ..aOS(2, 'type')
    ..aOS(3, 'title')
    ..aOS(4, 'region')
    ..a<$core.int>(5, 'posX', $pb.PbFieldType.OS3)
    ..a<$core.int>(6, 'posY', $pb.PbFieldType.OS3)
    ..a<$core.int>(7, 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(8, 'height', $pb.PbFieldType.O3)
    ..aOS(9, 'link')
    ..aOS(10, 'port')
    ..aOS(11, 'node')
    ..pc<TideChartProperty>(12, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..hasRequiredFields = false
  ;

  TideChartWidget._() : super();
  factory TideChartWidget() => create();
  factory TideChartWidget.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartWidget.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartWidget clone() => TideChartWidget()..mergeFromMessage(this);
  TideChartWidget copyWith(void Function(TideChartWidget) updates) => super.copyWith((message) => updates(message as TideChartWidget));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartWidget create() => TideChartWidget._();
  TideChartWidget createEmptyInstance() => create();
  static $pb.PbList<TideChartWidget> createRepeated() => $pb.PbList<TideChartWidget>();
  static TideChartWidget getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartWidget _defaultInstance;

  TideChartWidget_Target whichTarget() => _TideChartWidget_TargetByTag[$_whichOneof(0)];
  void clearTarget() => clearField($_whichOneof(0));

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.String get title => $_getS(2, '');
  set title($core.String v) { $_setString(2, v); }
  $core.bool hasTitle() => $_has(2);
  void clearTitle() => clearField(3);

  $core.String get region => $_getS(3, '');
  set region($core.String v) { $_setString(3, v); }
  $core.bool hasRegion() => $_has(3);
  void clearRegion() => clearField(4);

  $core.int get posX => $_get(4, 0);
  set posX($core.int v) { $_setSignedInt32(4, v); }
  $core.bool hasPosX() => $_has(4);
  void clearPosX() => clearField(5);

  $core.int get posY => $_get(5, 0);
  set posY($core.int v) { $_setSignedInt32(5, v); }
  $core.bool hasPosY() => $_has(5);
  void clearPosY() => clearField(6);

  $core.int get width => $_get(6, 0);
  set width($core.int v) { $_setSignedInt32(6, v); }
  $core.bool hasWidth() => $_has(6);
  void clearWidth() => clearField(7);

  $core.int get height => $_get(7, 0);
  set height($core.int v) { $_setSignedInt32(7, v); }
  $core.bool hasHeight() => $_has(7);
  void clearHeight() => clearField(8);

  $core.String get link => $_getS(8, '');
  set link($core.String v) { $_setString(8, v); }
  $core.bool hasLink() => $_has(8);
  void clearLink() => clearField(9);

  $core.String get port => $_getS(9, '');
  set port($core.String v) { $_setString(9, v); }
  $core.bool hasPort() => $_has(9);
  void clearPort() => clearField(10);

  $core.String get node => $_getS(10, '');
  set node($core.String v) { $_setString(10, v); }
  $core.bool hasNode() => $_has(10);
  void clearNode() => clearField(11);

  $core.List<TideChartProperty> get props => $_getList(11);
}

class TideChartPort extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPort')
    ..aOS(1, 'type')
    ..aOS(2, 'name')
    ..a<$core.int>(3, 'ordinal', $pb.PbFieldType.O3)
    ..aOB(4, 'default_4')
    ..aOB(5, 'required')
    ..pPS(6, 'allowed')
    ..aOS(7, 'hint')
    ..a<TideChartProperty>(8, 'constant', $pb.PbFieldType.OM, TideChartProperty.getDefault, TideChartProperty.create)
    ..aOS(9, 'trigger')
    ..aOS(10, 'filter')
    ..aOS(11, 'event')
    ..aOS(12, 'sync')
    ..aOB(13, 'block')
    ..aOB(14, 'queue')
    ..hasRequiredFields = false
  ;

  TideChartPort._() : super();
  factory TideChartPort() => create();
  factory TideChartPort.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartPort.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartPort clone() => TideChartPort()..mergeFromMessage(this);
  TideChartPort copyWith(void Function(TideChartPort) updates) => super.copyWith((message) => updates(message as TideChartPort));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartPort create() => TideChartPort._();
  TideChartPort createEmptyInstance() => create();
  static $pb.PbList<TideChartPort> createRepeated() => $pb.PbList<TideChartPort>();
  static TideChartPort getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartPort _defaultInstance;

  $core.String get type => $_getS(0, '');
  set type($core.String v) { $_setString(0, v); }
  $core.bool hasType() => $_has(0);
  void clearType() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.int get ordinal => $_get(2, 0);
  set ordinal($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasOrdinal() => $_has(2);
  void clearOrdinal() => clearField(3);

  $core.bool get default_4 => $_get(3, false);
  set default_4($core.bool v) { $_setBool(3, v); }
  $core.bool hasDefault_4() => $_has(3);
  void clearDefault_4() => clearField(4);

  $core.bool get required => $_get(4, false);
  set required($core.bool v) { $_setBool(4, v); }
  $core.bool hasRequired() => $_has(4);
  void clearRequired() => clearField(5);

  $core.List<$core.String> get allowed => $_getList(5);

  $core.String get hint => $_getS(6, '');
  set hint($core.String v) { $_setString(6, v); }
  $core.bool hasHint() => $_has(6);
  void clearHint() => clearField(7);

  TideChartProperty get constant => $_getN(7);
  set constant(TideChartProperty v) { setField(8, v); }
  $core.bool hasConstant() => $_has(7);
  void clearConstant() => clearField(8);

  $core.String get trigger => $_getS(8, '');
  set trigger($core.String v) { $_setString(8, v); }
  $core.bool hasTrigger() => $_has(8);
  void clearTrigger() => clearField(9);

  $core.String get filter => $_getS(9, '');
  set filter($core.String v) { $_setString(9, v); }
  $core.bool hasFilter() => $_has(9);
  void clearFilter() => clearField(10);

  $core.String get event => $_getS(10, '');
  set event($core.String v) { $_setString(10, v); }
  $core.bool hasEvent() => $_has(10);
  void clearEvent() => clearField(11);

  $core.String get sync => $_getS(11, '');
  set sync($core.String v) { $_setString(11, v); }
  $core.bool hasSync() => $_has(11);
  void clearSync() => clearField(12);

  $core.bool get block => $_get(12, false);
  set block($core.bool v) { $_setBool(12, v); }
  $core.bool hasBlock() => $_has(12);
  void clearBlock() => clearField(13);

  $core.bool get queue => $_get(13, false);
  set queue($core.bool v) { $_setBool(13, v); }
  $core.bool hasQueue() => $_has(13);
  void clearQueue() => clearField(14);
}

class TideChartLink extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartLink')
    ..aOS(1, 'outNode')
    ..aOS(2, 'outPort')
    ..aOS(3, 'inNode')
    ..aOS(4, 'inPort')
    ..a<$core.int>(5, 'group', $pb.PbFieldType.O3)
    ..a<$core.int>(6, 'delay', $pb.PbFieldType.O3)
    ..aOS(7, 'filter')
    ..aOB(16, 'logging')
    ..aOB(17, 'debugging')
    ..aOB(18, 'paused')
    ..aOB(19, 'disabled')
    ..hasRequiredFields = false
  ;

  TideChartLink._() : super();
  factory TideChartLink() => create();
  factory TideChartLink.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartLink.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartLink clone() => TideChartLink()..mergeFromMessage(this);
  TideChartLink copyWith(void Function(TideChartLink) updates) => super.copyWith((message) => updates(message as TideChartLink));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartLink create() => TideChartLink._();
  TideChartLink createEmptyInstance() => create();
  static $pb.PbList<TideChartLink> createRepeated() => $pb.PbList<TideChartLink>();
  static TideChartLink getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartLink _defaultInstance;

  $core.String get outNode => $_getS(0, '');
  set outNode($core.String v) { $_setString(0, v); }
  $core.bool hasOutNode() => $_has(0);
  void clearOutNode() => clearField(1);

  $core.String get outPort => $_getS(1, '');
  set outPort($core.String v) { $_setString(1, v); }
  $core.bool hasOutPort() => $_has(1);
  void clearOutPort() => clearField(2);

  $core.String get inNode => $_getS(2, '');
  set inNode($core.String v) { $_setString(2, v); }
  $core.bool hasInNode() => $_has(2);
  void clearInNode() => clearField(3);

  $core.String get inPort => $_getS(3, '');
  set inPort($core.String v) { $_setString(3, v); }
  $core.bool hasInPort() => $_has(3);
  void clearInPort() => clearField(4);

  $core.int get group => $_get(4, 0);
  set group($core.int v) { $_setSignedInt32(4, v); }
  $core.bool hasGroup() => $_has(4);
  void clearGroup() => clearField(5);

  $core.int get delay => $_get(5, 0);
  set delay($core.int v) { $_setSignedInt32(5, v); }
  $core.bool hasDelay() => $_has(5);
  void clearDelay() => clearField(6);

  $core.String get filter => $_getS(6, '');
  set filter($core.String v) { $_setString(6, v); }
  $core.bool hasFilter() => $_has(6);
  void clearFilter() => clearField(7);

  $core.bool get logging => $_get(7, false);
  set logging($core.bool v) { $_setBool(7, v); }
  $core.bool hasLogging() => $_has(7);
  void clearLogging() => clearField(16);

  $core.bool get debugging => $_get(8, false);
  set debugging($core.bool v) { $_setBool(8, v); }
  $core.bool hasDebugging() => $_has(8);
  void clearDebugging() => clearField(17);

  $core.bool get paused => $_get(9, false);
  set paused($core.bool v) { $_setBool(9, v); }
  $core.bool hasPaused() => $_has(9);
  void clearPaused() => clearField(18);

  $core.bool get disabled => $_get(10, false);
  set disabled($core.bool v) { $_setBool(10, v); }
  $core.bool hasDisabled() => $_has(10);
  void clearDisabled() => clearField(19);
}

class TideChartNote extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNote')
    ..aOS(1, 'id')
    ..aOS(2, 'replyTo')
    ..aOS(3, 'changeTo')
    ..aOS(4, 'content')
    ..aOS(5, 'createdBy')
    ..aOS(6, 'createdDate')
    ..hasRequiredFields = false
  ;

  TideChartNote._() : super();
  factory TideChartNote() => create();
  factory TideChartNote.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartNote.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartNote clone() => TideChartNote()..mergeFromMessage(this);
  TideChartNote copyWith(void Function(TideChartNote) updates) => super.copyWith((message) => updates(message as TideChartNote));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartNote create() => TideChartNote._();
  TideChartNote createEmptyInstance() => create();
  static $pb.PbList<TideChartNote> createRepeated() => $pb.PbList<TideChartNote>();
  static TideChartNote getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartNote _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get replyTo => $_getS(1, '');
  set replyTo($core.String v) { $_setString(1, v); }
  $core.bool hasReplyTo() => $_has(1);
  void clearReplyTo() => clearField(2);

  $core.String get changeTo => $_getS(2, '');
  set changeTo($core.String v) { $_setString(2, v); }
  $core.bool hasChangeTo() => $_has(2);
  void clearChangeTo() => clearField(3);

  $core.String get content => $_getS(3, '');
  set content($core.String v) { $_setString(3, v); }
  $core.bool hasContent() => $_has(3);
  void clearContent() => clearField(4);

  $core.String get createdBy => $_getS(4, '');
  set createdBy($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedBy() => $_has(4);
  void clearCreatedBy() => clearField(5);

  $core.String get createdDate => $_getS(5, '');
  set createdDate($core.String v) { $_setString(5, v); }
  $core.bool hasCreatedDate() => $_has(5);
  void clearCreatedDate() => clearField(6);
}

class TideChartNode extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNode')
    ..aOS(1, 'name')
    ..aOS(2, 'type')
    ..a<$core.int>(3, 'posX', $pb.PbFieldType.OS3)
    ..a<$core.int>(4, 'posY', $pb.PbFieldType.OS3)
    ..aOS(5, 'title')
    ..aOS(6, 'icon')
    ..aOS(7, 'library')
    ..aOS(8, 'method')
    ..a<$core.int>(9, 'delay', $pb.PbFieldType.O3)
    ..pc<TideChartPort>(10, 'inports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartPort>(11, 'outports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartProperty>(12, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..aOB(16, 'logging')
    ..aOB(17, 'debugging')
    ..aOB(18, 'paused')
    ..aOB(19, 'disabled')
    ..pc<TideChartNote>(20, 'notes', $pb.PbFieldType.PM,TideChartNote.create)
    ..aOS(21, 'script')
    ..hasRequiredFields = false
  ;

  TideChartNode._() : super();
  factory TideChartNode() => create();
  factory TideChartNode.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartNode.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartNode clone() => TideChartNode()..mergeFromMessage(this);
  TideChartNode copyWith(void Function(TideChartNode) updates) => super.copyWith((message) => updates(message as TideChartNode));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartNode create() => TideChartNode._();
  TideChartNode createEmptyInstance() => create();
  static $pb.PbList<TideChartNode> createRepeated() => $pb.PbList<TideChartNode>();
  static TideChartNode getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartNode _defaultInstance;

  $core.String get name => $_getS(0, '');
  set name($core.String v) { $_setString(0, v); }
  $core.bool hasName() => $_has(0);
  void clearName() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.int get posX => $_get(2, 0);
  set posX($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasPosX() => $_has(2);
  void clearPosX() => clearField(3);

  $core.int get posY => $_get(3, 0);
  set posY($core.int v) { $_setSignedInt32(3, v); }
  $core.bool hasPosY() => $_has(3);
  void clearPosY() => clearField(4);

  $core.String get title => $_getS(4, '');
  set title($core.String v) { $_setString(4, v); }
  $core.bool hasTitle() => $_has(4);
  void clearTitle() => clearField(5);

  $core.String get icon => $_getS(5, '');
  set icon($core.String v) { $_setString(5, v); }
  $core.bool hasIcon() => $_has(5);
  void clearIcon() => clearField(6);

  $core.String get library => $_getS(6, '');
  set library($core.String v) { $_setString(6, v); }
  $core.bool hasLibrary() => $_has(6);
  void clearLibrary() => clearField(7);

  $core.String get method => $_getS(7, '');
  set method($core.String v) { $_setString(7, v); }
  $core.bool hasMethod() => $_has(7);
  void clearMethod() => clearField(8);

  $core.int get delay => $_get(8, 0);
  set delay($core.int v) { $_setSignedInt32(8, v); }
  $core.bool hasDelay() => $_has(8);
  void clearDelay() => clearField(9);

  $core.List<TideChartPort> get inports => $_getList(9);

  $core.List<TideChartPort> get outports => $_getList(10);

  $core.List<TideChartProperty> get props => $_getList(11);

  $core.bool get logging => $_get(12, false);
  set logging($core.bool v) { $_setBool(12, v); }
  $core.bool hasLogging() => $_has(12);
  void clearLogging() => clearField(16);

  $core.bool get debugging => $_get(13, false);
  set debugging($core.bool v) { $_setBool(13, v); }
  $core.bool hasDebugging() => $_has(13);
  void clearDebugging() => clearField(17);

  $core.bool get paused => $_get(14, false);
  set paused($core.bool v) { $_setBool(14, v); }
  $core.bool hasPaused() => $_has(14);
  void clearPaused() => clearField(18);

  $core.bool get disabled => $_get(15, false);
  set disabled($core.bool v) { $_setBool(15, v); }
  $core.bool hasDisabled() => $_has(15);
  void clearDisabled() => clearField(19);

  $core.List<TideChartNote> get notes => $_getList(16);

  $core.String get script => $_getS(17, '');
  set script($core.String v) { $_setString(17, v); }
  $core.bool hasScript() => $_has(17);
  void clearScript() => clearField(21);
}

class TideChartRegion extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartRegion')
    ..aOS(1, 'name')
    ..aOS(2, 'title')
    ..pPS(3, 'nodes')
    ..a<$core.int>(4, 'group', $pb.PbFieldType.O3)
    ..aOS(5, 'scope')
    ..pc<TideChartProperty>(6, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..aOB(16, 'logging')
    ..aOB(17, 'debugging')
    ..aOB(18, 'paused')
    ..aOB(19, 'disabled')
    ..pc<TideChartNote>(20, 'notes', $pb.PbFieldType.PM,TideChartNote.create)
    ..aOS(21, 'script')
    ..hasRequiredFields = false
  ;

  TideChartRegion._() : super();
  factory TideChartRegion() => create();
  factory TideChartRegion.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartRegion.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartRegion clone() => TideChartRegion()..mergeFromMessage(this);
  TideChartRegion copyWith(void Function(TideChartRegion) updates) => super.copyWith((message) => updates(message as TideChartRegion));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartRegion create() => TideChartRegion._();
  TideChartRegion createEmptyInstance() => create();
  static $pb.PbList<TideChartRegion> createRepeated() => $pb.PbList<TideChartRegion>();
  static TideChartRegion getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartRegion _defaultInstance;

  $core.String get name => $_getS(0, '');
  set name($core.String v) { $_setString(0, v); }
  $core.bool hasName() => $_has(0);
  void clearName() => clearField(1);

  $core.String get title => $_getS(1, '');
  set title($core.String v) { $_setString(1, v); }
  $core.bool hasTitle() => $_has(1);
  void clearTitle() => clearField(2);

  $core.List<$core.String> get nodes => $_getList(2);

  $core.int get group => $_get(3, 0);
  set group($core.int v) { $_setSignedInt32(3, v); }
  $core.bool hasGroup() => $_has(3);
  void clearGroup() => clearField(4);

  $core.String get scope => $_getS(4, '');
  set scope($core.String v) { $_setString(4, v); }
  $core.bool hasScope() => $_has(4);
  void clearScope() => clearField(5);

  $core.List<TideChartProperty> get props => $_getList(5);

  $core.bool get logging => $_get(6, false);
  set logging($core.bool v) { $_setBool(6, v); }
  $core.bool hasLogging() => $_has(6);
  void clearLogging() => clearField(16);

  $core.bool get debugging => $_get(7, false);
  set debugging($core.bool v) { $_setBool(7, v); }
  $core.bool hasDebugging() => $_has(7);
  void clearDebugging() => clearField(17);

  $core.bool get paused => $_get(8, false);
  set paused($core.bool v) { $_setBool(8, v); }
  $core.bool hasPaused() => $_has(8);
  void clearPaused() => clearField(18);

  $core.bool get disabled => $_get(9, false);
  set disabled($core.bool v) { $_setBool(9, v); }
  $core.bool hasDisabled() => $_has(9);
  void clearDisabled() => clearField(19);

  $core.List<TideChartNote> get notes => $_getList(10);

  $core.String get script => $_getS(11, '');
  set script($core.String v) { $_setString(11, v); }
  $core.bool hasScript() => $_has(11);
  void clearScript() => clearField(21);
}

class TideChartGraph extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartGraph')
    ..aOS(1, 'id')
    ..aOS(2, 'type')
    ..aOS(3, 'name')
    ..aOS(4, 'title')
    ..aOS(5, 'version')
    ..aOS(6, 'source')
    ..pc<TideChartNode>(7, 'nodes', $pb.PbFieldType.PM,TideChartNode.create)
    ..pc<TideChartLink>(8, 'links', $pb.PbFieldType.PM,TideChartLink.create)
    ..pc<TideChartRegion>(9, 'regions', $pb.PbFieldType.PM,TideChartRegion.create)
    ..pc<TideChartCommentBox>(10, 'comments', $pb.PbFieldType.PM,TideChartCommentBox.create)
    ..pc<TideChartWidget>(11, 'widgets', $pb.PbFieldType.PM,TideChartWidget.create)
    ..pc<TideChartProperty>(12, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..pc<TideChartCommand>(13, 'history', $pb.PbFieldType.PM,TideChartCommand.create)
    ..aOB(16, 'logging')
    ..aOB(17, 'debugging')
    ..aOB(18, 'paused')
    ..aOB(19, 'disabled')
    ..pc<TideChartNote>(20, 'notes', $pb.PbFieldType.PM,TideChartNote.create)
    ..aOS(21, 'script')
    ..hasRequiredFields = false
  ;

  TideChartGraph._() : super();
  factory TideChartGraph() => create();
  factory TideChartGraph.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartGraph.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartGraph clone() => TideChartGraph()..mergeFromMessage(this);
  TideChartGraph copyWith(void Function(TideChartGraph) updates) => super.copyWith((message) => updates(message as TideChartGraph));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartGraph create() => TideChartGraph._();
  TideChartGraph createEmptyInstance() => create();
  static $pb.PbList<TideChartGraph> createRepeated() => $pb.PbList<TideChartGraph>();
  static TideChartGraph getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartGraph _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.String get name => $_getS(2, '');
  set name($core.String v) { $_setString(2, v); }
  $core.bool hasName() => $_has(2);
  void clearName() => clearField(3);

  $core.String get title => $_getS(3, '');
  set title($core.String v) { $_setString(3, v); }
  $core.bool hasTitle() => $_has(3);
  void clearTitle() => clearField(4);

  $core.String get version => $_getS(4, '');
  set version($core.String v) { $_setString(4, v); }
  $core.bool hasVersion() => $_has(4);
  void clearVersion() => clearField(5);

  $core.String get source => $_getS(5, '');
  set source($core.String v) { $_setString(5, v); }
  $core.bool hasSource() => $_has(5);
  void clearSource() => clearField(6);

  $core.List<TideChartNode> get nodes => $_getList(6);

  $core.List<TideChartLink> get links => $_getList(7);

  $core.List<TideChartRegion> get regions => $_getList(8);

  $core.List<TideChartCommentBox> get comments => $_getList(9);

  $core.List<TideChartWidget> get widgets => $_getList(10);

  $core.List<TideChartProperty> get props => $_getList(11);

  $core.List<TideChartCommand> get history => $_getList(12);

  $core.bool get logging => $_get(13, false);
  set logging($core.bool v) { $_setBool(13, v); }
  $core.bool hasLogging() => $_has(13);
  void clearLogging() => clearField(16);

  $core.bool get debugging => $_get(14, false);
  set debugging($core.bool v) { $_setBool(14, v); }
  $core.bool hasDebugging() => $_has(14);
  void clearDebugging() => clearField(17);

  $core.bool get paused => $_get(15, false);
  set paused($core.bool v) { $_setBool(15, v); }
  $core.bool hasPaused() => $_has(15);
  void clearPaused() => clearField(18);

  $core.bool get disabled => $_get(16, false);
  set disabled($core.bool v) { $_setBool(16, v); }
  $core.bool hasDisabled() => $_has(16);
  void clearDisabled() => clearField(19);

  $core.List<TideChartNote> get notes => $_getList(17);

  $core.String get script => $_getS(18, '');
  set script($core.String v) { $_setString(18, v); }
  $core.bool hasScript() => $_has(18);
  void clearScript() => clearField(21);
}

enum TideChartCommand_Command {
  group, 
  move, 
  comment, 
  widget, 
  port, 
  link, 
  node, 
  region, 
  graph, 
  props, 
  note, 
  notSet
}

class TideChartCommand extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartCommand_Command> _TideChartCommand_CommandByTag = {
    3 : TideChartCommand_Command.group,
    4 : TideChartCommand_Command.move,
    5 : TideChartCommand_Command.comment,
    6 : TideChartCommand_Command.widget,
    7 : TideChartCommand_Command.port,
    8 : TideChartCommand_Command.link,
    9 : TideChartCommand_Command.node,
    10 : TideChartCommand_Command.region,
    11 : TideChartCommand_Command.graph,
    12 : TideChartCommand_Command.props,
    13 : TideChartCommand_Command.note,
    0 : TideChartCommand_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartCommand')
    ..oo(0, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13])
    ..aOS(1, 'version')
    ..aOS(2, 'target')
    ..a<TideChartGroupCommand>(3, 'group', $pb.PbFieldType.OM, TideChartGroupCommand.getDefault, TideChartGroupCommand.create)
    ..a<TideChartMoveCommand>(4, 'move', $pb.PbFieldType.OM, TideChartMoveCommand.getDefault, TideChartMoveCommand.create)
    ..a<TideChartCommentBoxCommand>(5, 'comment', $pb.PbFieldType.OM, TideChartCommentBoxCommand.getDefault, TideChartCommentBoxCommand.create)
    ..a<TideChartWidgetCommand>(6, 'widget', $pb.PbFieldType.OM, TideChartWidgetCommand.getDefault, TideChartWidgetCommand.create)
    ..a<TideChartPortCommand>(7, 'port', $pb.PbFieldType.OM, TideChartPortCommand.getDefault, TideChartPortCommand.create)
    ..a<TideChartLinkCommand>(8, 'link', $pb.PbFieldType.OM, TideChartLinkCommand.getDefault, TideChartLinkCommand.create)
    ..a<TideChartNodeCommand>(9, 'node', $pb.PbFieldType.OM, TideChartNodeCommand.getDefault, TideChartNodeCommand.create)
    ..a<TideChartRegionCommand>(10, 'region', $pb.PbFieldType.OM, TideChartRegionCommand.getDefault, TideChartRegionCommand.create)
    ..a<TideChartGraphCommand>(11, 'graph', $pb.PbFieldType.OM, TideChartGraphCommand.getDefault, TideChartGraphCommand.create)
    ..a<TideChartPropertyCommand>(12, 'props', $pb.PbFieldType.OM, TideChartPropertyCommand.getDefault, TideChartPropertyCommand.create)
    ..a<TideChartNoteCommand>(13, 'note', $pb.PbFieldType.OM, TideChartNoteCommand.getDefault, TideChartNoteCommand.create)
    ..hasRequiredFields = false
  ;

  TideChartCommand._() : super();
  factory TideChartCommand() => create();
  factory TideChartCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartCommand clone() => TideChartCommand()..mergeFromMessage(this);
  TideChartCommand copyWith(void Function(TideChartCommand) updates) => super.copyWith((message) => updates(message as TideChartCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartCommand create() => TideChartCommand._();
  TideChartCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartCommand> createRepeated() => $pb.PbList<TideChartCommand>();
  static TideChartCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartCommand _defaultInstance;

  TideChartCommand_Command whichCommand() => _TideChartCommand_CommandByTag[$_whichOneof(0)];
  void clearCommand() => clearField($_whichOneof(0));

  $core.String get version => $_getS(0, '');
  set version($core.String v) { $_setString(0, v); }
  $core.bool hasVersion() => $_has(0);
  void clearVersion() => clearField(1);

  $core.String get target => $_getS(1, '');
  set target($core.String v) { $_setString(1, v); }
  $core.bool hasTarget() => $_has(1);
  void clearTarget() => clearField(2);

  TideChartGroupCommand get group => $_getN(2);
  set group(TideChartGroupCommand v) { setField(3, v); }
  $core.bool hasGroup() => $_has(2);
  void clearGroup() => clearField(3);

  TideChartMoveCommand get move => $_getN(3);
  set move(TideChartMoveCommand v) { setField(4, v); }
  $core.bool hasMove() => $_has(3);
  void clearMove() => clearField(4);

  TideChartCommentBoxCommand get comment => $_getN(4);
  set comment(TideChartCommentBoxCommand v) { setField(5, v); }
  $core.bool hasComment() => $_has(4);
  void clearComment() => clearField(5);

  TideChartWidgetCommand get widget => $_getN(5);
  set widget(TideChartWidgetCommand v) { setField(6, v); }
  $core.bool hasWidget() => $_has(5);
  void clearWidget() => clearField(6);

  TideChartPortCommand get port => $_getN(6);
  set port(TideChartPortCommand v) { setField(7, v); }
  $core.bool hasPort() => $_has(6);
  void clearPort() => clearField(7);

  TideChartLinkCommand get link => $_getN(7);
  set link(TideChartLinkCommand v) { setField(8, v); }
  $core.bool hasLink() => $_has(7);
  void clearLink() => clearField(8);

  TideChartNodeCommand get node => $_getN(8);
  set node(TideChartNodeCommand v) { setField(9, v); }
  $core.bool hasNode() => $_has(8);
  void clearNode() => clearField(9);

  TideChartRegionCommand get region => $_getN(9);
  set region(TideChartRegionCommand v) { setField(10, v); }
  $core.bool hasRegion() => $_has(9);
  void clearRegion() => clearField(10);

  TideChartGraphCommand get graph => $_getN(10);
  set graph(TideChartGraphCommand v) { setField(11, v); }
  $core.bool hasGraph() => $_has(10);
  void clearGraph() => clearField(11);

  TideChartPropertyCommand get props => $_getN(11);
  set props(TideChartPropertyCommand v) { setField(12, v); }
  $core.bool hasProps() => $_has(11);
  void clearProps() => clearField(12);

  TideChartNoteCommand get note => $_getN(12);
  set note(TideChartNoteCommand v) { setField(13, v); }
  $core.bool hasNote() => $_has(12);
  void clearNote() => clearField(13);
}

class TideChartGroupCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartGroupCommand')
    ..pc<TideChartCommand>(1, 'cmds', $pb.PbFieldType.PM,TideChartCommand.create)
    ..hasRequiredFields = false
  ;

  TideChartGroupCommand._() : super();
  factory TideChartGroupCommand() => create();
  factory TideChartGroupCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartGroupCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartGroupCommand clone() => TideChartGroupCommand()..mergeFromMessage(this);
  TideChartGroupCommand copyWith(void Function(TideChartGroupCommand) updates) => super.copyWith((message) => updates(message as TideChartGroupCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartGroupCommand create() => TideChartGroupCommand._();
  TideChartGroupCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartGroupCommand> createRepeated() => $pb.PbList<TideChartGroupCommand>();
  static TideChartGroupCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartGroupCommand _defaultInstance;

  $core.List<TideChartCommand> get cmds => $_getList(0);
}

class TideChartMoveCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartMoveCommand')
    ..aOS(1, 'node')
    ..a<$core.int>(2, 'fromPosX', $pb.PbFieldType.OS3)
    ..a<$core.int>(3, 'fromPosY', $pb.PbFieldType.OS3)
    ..a<$core.int>(4, 'toPosX', $pb.PbFieldType.OS3)
    ..a<$core.int>(5, 'toPosY', $pb.PbFieldType.OS3)
    ..hasRequiredFields = false
  ;

  TideChartMoveCommand._() : super();
  factory TideChartMoveCommand() => create();
  factory TideChartMoveCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartMoveCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartMoveCommand clone() => TideChartMoveCommand()..mergeFromMessage(this);
  TideChartMoveCommand copyWith(void Function(TideChartMoveCommand) updates) => super.copyWith((message) => updates(message as TideChartMoveCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartMoveCommand create() => TideChartMoveCommand._();
  TideChartMoveCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartMoveCommand> createRepeated() => $pb.PbList<TideChartMoveCommand>();
  static TideChartMoveCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartMoveCommand _defaultInstance;

  $core.String get node => $_getS(0, '');
  set node($core.String v) { $_setString(0, v); }
  $core.bool hasNode() => $_has(0);
  void clearNode() => clearField(1);

  $core.int get fromPosX => $_get(1, 0);
  set fromPosX($core.int v) { $_setSignedInt32(1, v); }
  $core.bool hasFromPosX() => $_has(1);
  void clearFromPosX() => clearField(2);

  $core.int get fromPosY => $_get(2, 0);
  set fromPosY($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasFromPosY() => $_has(2);
  void clearFromPosY() => clearField(3);

  $core.int get toPosX => $_get(3, 0);
  set toPosX($core.int v) { $_setSignedInt32(3, v); }
  $core.bool hasToPosX() => $_has(3);
  void clearToPosX() => clearField(4);

  $core.int get toPosY => $_get(4, 0);
  set toPosY($core.int v) { $_setSignedInt32(4, v); }
  $core.bool hasToPosY() => $_has(4);
  void clearToPosY() => clearField(5);
}

class TideChartCommentBoxCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartCommentBoxCommand')
    ..a<TideChartPort>(1, 'fromComment', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..a<TideChartPort>(2, 'toComment', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartCommentBoxCommand._() : super();
  factory TideChartCommentBoxCommand() => create();
  factory TideChartCommentBoxCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartCommentBoxCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartCommentBoxCommand clone() => TideChartCommentBoxCommand()..mergeFromMessage(this);
  TideChartCommentBoxCommand copyWith(void Function(TideChartCommentBoxCommand) updates) => super.copyWith((message) => updates(message as TideChartCommentBoxCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartCommentBoxCommand create() => TideChartCommentBoxCommand._();
  TideChartCommentBoxCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartCommentBoxCommand> createRepeated() => $pb.PbList<TideChartCommentBoxCommand>();
  static TideChartCommentBoxCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartCommentBoxCommand _defaultInstance;

  TideChartPort get fromComment => $_getN(0);
  set fromComment(TideChartPort v) { setField(1, v); }
  $core.bool hasFromComment() => $_has(0);
  void clearFromComment() => clearField(1);

  TideChartPort get toComment => $_getN(1);
  set toComment(TideChartPort v) { setField(2, v); }
  $core.bool hasToComment() => $_has(1);
  void clearToComment() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartWidgetCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartWidgetCommand')
    ..a<TideChartPort>(1, 'fromWidget', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..a<TideChartPort>(2, 'toWidget', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartWidgetCommand._() : super();
  factory TideChartWidgetCommand() => create();
  factory TideChartWidgetCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartWidgetCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartWidgetCommand clone() => TideChartWidgetCommand()..mergeFromMessage(this);
  TideChartWidgetCommand copyWith(void Function(TideChartWidgetCommand) updates) => super.copyWith((message) => updates(message as TideChartWidgetCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartWidgetCommand create() => TideChartWidgetCommand._();
  TideChartWidgetCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartWidgetCommand> createRepeated() => $pb.PbList<TideChartWidgetCommand>();
  static TideChartWidgetCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartWidgetCommand _defaultInstance;

  TideChartPort get fromWidget => $_getN(0);
  set fromWidget(TideChartPort v) { setField(1, v); }
  $core.bool hasFromWidget() => $_has(0);
  void clearFromWidget() => clearField(1);

  TideChartPort get toWidget => $_getN(1);
  set toWidget(TideChartPort v) { setField(2, v); }
  $core.bool hasToWidget() => $_has(1);
  void clearToWidget() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartPortCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPortCommand')
    ..a<TideChartPort>(1, 'fromPort', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..a<TideChartPort>(2, 'toPort', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartPortCommand._() : super();
  factory TideChartPortCommand() => create();
  factory TideChartPortCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartPortCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartPortCommand clone() => TideChartPortCommand()..mergeFromMessage(this);
  TideChartPortCommand copyWith(void Function(TideChartPortCommand) updates) => super.copyWith((message) => updates(message as TideChartPortCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartPortCommand create() => TideChartPortCommand._();
  TideChartPortCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartPortCommand> createRepeated() => $pb.PbList<TideChartPortCommand>();
  static TideChartPortCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartPortCommand _defaultInstance;

  TideChartPort get fromPort => $_getN(0);
  set fromPort(TideChartPort v) { setField(1, v); }
  $core.bool hasFromPort() => $_has(0);
  void clearFromPort() => clearField(1);

  TideChartPort get toPort => $_getN(1);
  set toPort(TideChartPort v) { setField(2, v); }
  $core.bool hasToPort() => $_has(1);
  void clearToPort() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartLinkCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartLinkCommand')
    ..a<TideChartLink>(1, 'fromLink', $pb.PbFieldType.OM, TideChartLink.getDefault, TideChartLink.create)
    ..a<TideChartLink>(2, 'toLink', $pb.PbFieldType.OM, TideChartLink.getDefault, TideChartLink.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartLinkCommand._() : super();
  factory TideChartLinkCommand() => create();
  factory TideChartLinkCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartLinkCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartLinkCommand clone() => TideChartLinkCommand()..mergeFromMessage(this);
  TideChartLinkCommand copyWith(void Function(TideChartLinkCommand) updates) => super.copyWith((message) => updates(message as TideChartLinkCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartLinkCommand create() => TideChartLinkCommand._();
  TideChartLinkCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartLinkCommand> createRepeated() => $pb.PbList<TideChartLinkCommand>();
  static TideChartLinkCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartLinkCommand _defaultInstance;

  TideChartLink get fromLink => $_getN(0);
  set fromLink(TideChartLink v) { setField(1, v); }
  $core.bool hasFromLink() => $_has(0);
  void clearFromLink() => clearField(1);

  TideChartLink get toLink => $_getN(1);
  set toLink(TideChartLink v) { setField(2, v); }
  $core.bool hasToLink() => $_has(1);
  void clearToLink() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartNodeCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNodeCommand')
    ..a<TideChartNode>(1, 'fromNode', $pb.PbFieldType.OM, TideChartNode.getDefault, TideChartNode.create)
    ..a<TideChartNode>(2, 'toNode', $pb.PbFieldType.OM, TideChartNode.getDefault, TideChartNode.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartNodeCommand._() : super();
  factory TideChartNodeCommand() => create();
  factory TideChartNodeCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartNodeCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartNodeCommand clone() => TideChartNodeCommand()..mergeFromMessage(this);
  TideChartNodeCommand copyWith(void Function(TideChartNodeCommand) updates) => super.copyWith((message) => updates(message as TideChartNodeCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartNodeCommand create() => TideChartNodeCommand._();
  TideChartNodeCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartNodeCommand> createRepeated() => $pb.PbList<TideChartNodeCommand>();
  static TideChartNodeCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartNodeCommand _defaultInstance;

  TideChartNode get fromNode => $_getN(0);
  set fromNode(TideChartNode v) { setField(1, v); }
  $core.bool hasFromNode() => $_has(0);
  void clearFromNode() => clearField(1);

  TideChartNode get toNode => $_getN(1);
  set toNode(TideChartNode v) { setField(2, v); }
  $core.bool hasToNode() => $_has(1);
  void clearToNode() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartRegionCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartRegionCommand')
    ..a<TideChartRegion>(1, 'fromRegion', $pb.PbFieldType.OM, TideChartRegion.getDefault, TideChartRegion.create)
    ..a<TideChartRegion>(2, 'toRegion', $pb.PbFieldType.OM, TideChartRegion.getDefault, TideChartRegion.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartRegionCommand._() : super();
  factory TideChartRegionCommand() => create();
  factory TideChartRegionCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartRegionCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartRegionCommand clone() => TideChartRegionCommand()..mergeFromMessage(this);
  TideChartRegionCommand copyWith(void Function(TideChartRegionCommand) updates) => super.copyWith((message) => updates(message as TideChartRegionCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartRegionCommand create() => TideChartRegionCommand._();
  TideChartRegionCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartRegionCommand> createRepeated() => $pb.PbList<TideChartRegionCommand>();
  static TideChartRegionCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartRegionCommand _defaultInstance;

  TideChartRegion get fromRegion => $_getN(0);
  set fromRegion(TideChartRegion v) { setField(1, v); }
  $core.bool hasFromRegion() => $_has(0);
  void clearFromRegion() => clearField(1);

  TideChartRegion get toRegion => $_getN(1);
  set toRegion(TideChartRegion v) { setField(2, v); }
  $core.bool hasToRegion() => $_has(1);
  void clearToRegion() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

class TideChartGraphCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartGraphCommand')
    ..a<TideChartGraph>(1, 'fromGraph', $pb.PbFieldType.OM, TideChartGraph.getDefault, TideChartGraph.create)
    ..a<TideChartGraph>(2, 'toGraph', $pb.PbFieldType.OM, TideChartGraph.getDefault, TideChartGraph.create)
    ..aOS(3, 'type')
    ..hasRequiredFields = false
  ;

  TideChartGraphCommand._() : super();
  factory TideChartGraphCommand() => create();
  factory TideChartGraphCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartGraphCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartGraphCommand clone() => TideChartGraphCommand()..mergeFromMessage(this);
  TideChartGraphCommand copyWith(void Function(TideChartGraphCommand) updates) => super.copyWith((message) => updates(message as TideChartGraphCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartGraphCommand create() => TideChartGraphCommand._();
  TideChartGraphCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartGraphCommand> createRepeated() => $pb.PbList<TideChartGraphCommand>();
  static TideChartGraphCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartGraphCommand _defaultInstance;

  TideChartGraph get fromGraph => $_getN(0);
  set fromGraph(TideChartGraph v) { setField(1, v); }
  $core.bool hasFromGraph() => $_has(0);
  void clearFromGraph() => clearField(1);

  TideChartGraph get toGraph => $_getN(1);
  set toGraph(TideChartGraph v) { setField(2, v); }
  $core.bool hasToGraph() => $_has(1);
  void clearToGraph() => clearField(2);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);
}

enum TideChartPropertyCommand_Target {
  node, 
  region, 
  widget, 
  graph, 
  notSet
}

class TideChartPropertyCommand extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartPropertyCommand_Target> _TideChartPropertyCommand_TargetByTag = {
    5 : TideChartPropertyCommand_Target.node,
    6 : TideChartPropertyCommand_Target.region,
    7 : TideChartPropertyCommand_Target.widget,
    8 : TideChartPropertyCommand_Target.graph,
    0 : TideChartPropertyCommand_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPropertyCommand')
    ..oo(0, [5, 6, 7, 8])
    ..pc<TideChartProperty>(1, 'fromProps', $pb.PbFieldType.PM,TideChartProperty.create)
    ..pc<TideChartProperty>(2, 'toProps', $pb.PbFieldType.PM,TideChartProperty.create)
    ..aOS(3, 'type')
    ..aOS(5, 'node')
    ..aOS(6, 'region')
    ..aOS(7, 'widget')
    ..aOS(8, 'graph')
    ..hasRequiredFields = false
  ;

  TideChartPropertyCommand._() : super();
  factory TideChartPropertyCommand() => create();
  factory TideChartPropertyCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartPropertyCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartPropertyCommand clone() => TideChartPropertyCommand()..mergeFromMessage(this);
  TideChartPropertyCommand copyWith(void Function(TideChartPropertyCommand) updates) => super.copyWith((message) => updates(message as TideChartPropertyCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartPropertyCommand create() => TideChartPropertyCommand._();
  TideChartPropertyCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartPropertyCommand> createRepeated() => $pb.PbList<TideChartPropertyCommand>();
  static TideChartPropertyCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartPropertyCommand _defaultInstance;

  TideChartPropertyCommand_Target whichTarget() => _TideChartPropertyCommand_TargetByTag[$_whichOneof(0)];
  void clearTarget() => clearField($_whichOneof(0));

  $core.List<TideChartProperty> get fromProps => $_getList(0);

  $core.List<TideChartProperty> get toProps => $_getList(1);

  $core.String get type => $_getS(2, '');
  set type($core.String v) { $_setString(2, v); }
  $core.bool hasType() => $_has(2);
  void clearType() => clearField(3);

  $core.String get node => $_getS(3, '');
  set node($core.String v) { $_setString(3, v); }
  $core.bool hasNode() => $_has(3);
  void clearNode() => clearField(5);

  $core.String get region => $_getS(4, '');
  set region($core.String v) { $_setString(4, v); }
  $core.bool hasRegion() => $_has(4);
  void clearRegion() => clearField(6);

  $core.String get widget => $_getS(5, '');
  set widget($core.String v) { $_setString(5, v); }
  $core.bool hasWidget() => $_has(5);
  void clearWidget() => clearField(7);

  $core.String get graph => $_getS(6, '');
  set graph($core.String v) { $_setString(6, v); }
  $core.bool hasGraph() => $_has(6);
  void clearGraph() => clearField(8);
}

enum TideChartNoteCommand_Target {
  node, 
  region, 
  graph, 
  notSet
}

class TideChartNoteCommand extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartNoteCommand_Target> _TideChartNoteCommand_TargetByTag = {
    3 : TideChartNoteCommand_Target.node,
    4 : TideChartNoteCommand_Target.region,
    5 : TideChartNoteCommand_Target.graph,
    0 : TideChartNoteCommand_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNoteCommand')
    ..oo(0, [3, 4, 5])
    ..pc<TideChartNote>(1, 'notes', $pb.PbFieldType.PM,TideChartNote.create)
    ..aOS(2, 'type')
    ..aOS(3, 'node')
    ..aOS(4, 'region')
    ..aOS(5, 'graph')
    ..hasRequiredFields = false
  ;

  TideChartNoteCommand._() : super();
  factory TideChartNoteCommand() => create();
  factory TideChartNoteCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartNoteCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartNoteCommand clone() => TideChartNoteCommand()..mergeFromMessage(this);
  TideChartNoteCommand copyWith(void Function(TideChartNoteCommand) updates) => super.copyWith((message) => updates(message as TideChartNoteCommand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartNoteCommand create() => TideChartNoteCommand._();
  TideChartNoteCommand createEmptyInstance() => create();
  static $pb.PbList<TideChartNoteCommand> createRepeated() => $pb.PbList<TideChartNoteCommand>();
  static TideChartNoteCommand getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartNoteCommand _defaultInstance;

  TideChartNoteCommand_Target whichTarget() => _TideChartNoteCommand_TargetByTag[$_whichOneof(0)];
  void clearTarget() => clearField($_whichOneof(0));

  $core.List<TideChartNote> get notes => $_getList(0);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.String get node => $_getS(2, '');
  set node($core.String v) { $_setString(2, v); }
  $core.bool hasNode() => $_has(2);
  void clearNode() => clearField(3);

  $core.String get region => $_getS(3, '');
  set region($core.String v) { $_setString(3, v); }
  $core.bool hasRegion() => $_has(3);
  void clearRegion() => clearField(4);

  $core.String get graph => $_getS(4, '');
  set graph($core.String v) { $_setString(4, v); }
  $core.bool hasGraph() => $_has(4);
  void clearGraph() => clearField(5);
}

class TideChartMethod extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartMethod')
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'extends_3')
    ..aOS(4, 'script')
    ..pc<TideChartPort>(5, 'inports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartPort>(6, 'outports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartPort>(7, 'props', $pb.PbFieldType.PM,TideChartPort.create)
    ..hasRequiredFields = false
  ;

  TideChartMethod._() : super();
  factory TideChartMethod() => create();
  factory TideChartMethod.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartMethod.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartMethod clone() => TideChartMethod()..mergeFromMessage(this);
  TideChartMethod copyWith(void Function(TideChartMethod) updates) => super.copyWith((message) => updates(message as TideChartMethod));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartMethod create() => TideChartMethod._();
  TideChartMethod createEmptyInstance() => create();
  static $pb.PbList<TideChartMethod> createRepeated() => $pb.PbList<TideChartMethod>();
  static TideChartMethod getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartMethod _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get extends_3 => $_getS(2, '');
  set extends_3($core.String v) { $_setString(2, v); }
  $core.bool hasExtends_3() => $_has(2);
  void clearExtends_3() => clearField(3);

  $core.String get script => $_getS(3, '');
  set script($core.String v) { $_setString(3, v); }
  $core.bool hasScript() => $_has(3);
  void clearScript() => clearField(4);

  $core.List<TideChartPort> get inports => $_getList(4);

  $core.List<TideChartPort> get outports => $_getList(5);

  $core.List<TideChartPort> get props => $_getList(6);
}

enum TideChartSource_Content {
  version, 
  script, 
  notSet
}

class TideChartSource extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartSource_Content> _TideChartSource_ContentByTag = {
    7 : TideChartSource_Content.version,
    8 : TideChartSource_Content.script,
    0 : TideChartSource_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartSource')
    ..oo(0, [7, 8])
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'path')
    ..aOS(5, 'createdDate')
    ..aOS(6, 'createdBy')
    ..aOS(7, 'version')
    ..aOS(8, 'script')
    ..hasRequiredFields = false
  ;

  TideChartSource._() : super();
  factory TideChartSource() => create();
  factory TideChartSource.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartSource.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartSource clone() => TideChartSource()..mergeFromMessage(this);
  TideChartSource copyWith(void Function(TideChartSource) updates) => super.copyWith((message) => updates(message as TideChartSource));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartSource create() => TideChartSource._();
  TideChartSource createEmptyInstance() => create();
  static $pb.PbList<TideChartSource> createRepeated() => $pb.PbList<TideChartSource>();
  static TideChartSource getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartSource _defaultInstance;

  TideChartSource_Content whichContent() => _TideChartSource_ContentByTag[$_whichOneof(0)];
  void clearContent() => clearField($_whichOneof(0));

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get path => $_getS(2, '');
  set path($core.String v) { $_setString(2, v); }
  $core.bool hasPath() => $_has(2);
  void clearPath() => clearField(3);

  $core.String get createdDate => $_getS(3, '');
  set createdDate($core.String v) { $_setString(3, v); }
  $core.bool hasCreatedDate() => $_has(3);
  void clearCreatedDate() => clearField(5);

  $core.String get createdBy => $_getS(4, '');
  set createdBy($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedBy() => $_has(4);
  void clearCreatedBy() => clearField(6);

  $core.String get version => $_getS(5, '');
  set version($core.String v) { $_setString(5, v); }
  $core.bool hasVersion() => $_has(5);
  void clearVersion() => clearField(7);

  $core.String get script => $_getS(6, '');
  set script($core.String v) { $_setString(6, v); }
  $core.bool hasScript() => $_has(6);
  void clearScript() => clearField(8);
}

class TideChartLibrary extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartLibrary')
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'title')
    ..aOS(4, 'origin')
    ..aOS(5, 'branch')
    ..aOS(6, 'path')
    ..pc<TideChartSource>(7, 'files', $pb.PbFieldType.PM,TideChartSource.create)
    ..pc<TideChartMethod>(8, 'methods', $pb.PbFieldType.PM,TideChartMethod.create)
    ..hasRequiredFields = false
  ;

  TideChartLibrary._() : super();
  factory TideChartLibrary() => create();
  factory TideChartLibrary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartLibrary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartLibrary clone() => TideChartLibrary()..mergeFromMessage(this);
  TideChartLibrary copyWith(void Function(TideChartLibrary) updates) => super.copyWith((message) => updates(message as TideChartLibrary));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartLibrary create() => TideChartLibrary._();
  TideChartLibrary createEmptyInstance() => create();
  static $pb.PbList<TideChartLibrary> createRepeated() => $pb.PbList<TideChartLibrary>();
  static TideChartLibrary getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartLibrary _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get title => $_getS(2, '');
  set title($core.String v) { $_setString(2, v); }
  $core.bool hasTitle() => $_has(2);
  void clearTitle() => clearField(3);

  $core.String get origin => $_getS(3, '');
  set origin($core.String v) { $_setString(3, v); }
  $core.bool hasOrigin() => $_has(3);
  void clearOrigin() => clearField(4);

  $core.String get branch => $_getS(4, '');
  set branch($core.String v) { $_setString(4, v); }
  $core.bool hasBranch() => $_has(4);
  void clearBranch() => clearField(5);

  $core.String get path => $_getS(5, '');
  set path($core.String v) { $_setString(5, v); }
  $core.bool hasPath() => $_has(5);
  void clearPath() => clearField(6);

  $core.List<TideChartSource> get files => $_getList(6);

  $core.List<TideChartMethod> get methods => $_getList(7);
}

class TideChartSite extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartSite')
    ..aInt64(1, 'index')
    ..pc<TideChartSite>(2, 'stack', $pb.PbFieldType.PM,TideChartSite.create)
    ..aOS(3, 'path')
    ..aOS(4, 'trigger')
    ..aOS(5, 'event')
    ..pPS(6, 'scope')
    ..aOS(7, 'filter')
    ..aOS(8, 'graph')
    ..aOS(9, 'region')
    ..aOS(10, 'node')
    ..aOS(11, 'port')
    ..hasRequiredFields = false
  ;

  TideChartSite._() : super();
  factory TideChartSite() => create();
  factory TideChartSite.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartSite.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartSite clone() => TideChartSite()..mergeFromMessage(this);
  TideChartSite copyWith(void Function(TideChartSite) updates) => super.copyWith((message) => updates(message as TideChartSite));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartSite create() => TideChartSite._();
  TideChartSite createEmptyInstance() => create();
  static $pb.PbList<TideChartSite> createRepeated() => $pb.PbList<TideChartSite>();
  static TideChartSite getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartSite _defaultInstance;

  Int64 get index => $_getI64(0);
  set index(Int64 v) { $_setInt64(0, v); }
  $core.bool hasIndex() => $_has(0);
  void clearIndex() => clearField(1);

  $core.List<TideChartSite> get stack => $_getList(1);

  $core.String get path => $_getS(2, '');
  set path($core.String v) { $_setString(2, v); }
  $core.bool hasPath() => $_has(2);
  void clearPath() => clearField(3);

  $core.String get trigger => $_getS(3, '');
  set trigger($core.String v) { $_setString(3, v); }
  $core.bool hasTrigger() => $_has(3);
  void clearTrigger() => clearField(4);

  $core.String get event => $_getS(4, '');
  set event($core.String v) { $_setString(4, v); }
  $core.bool hasEvent() => $_has(4);
  void clearEvent() => clearField(5);

  $core.List<$core.String> get scope => $_getList(5);

  $core.String get filter => $_getS(6, '');
  set filter($core.String v) { $_setString(6, v); }
  $core.bool hasFilter() => $_has(6);
  void clearFilter() => clearField(7);

  $core.String get graph => $_getS(7, '');
  set graph($core.String v) { $_setString(7, v); }
  $core.bool hasGraph() => $_has(7);
  void clearGraph() => clearField(8);

  $core.String get region => $_getS(8, '');
  set region($core.String v) { $_setString(8, v); }
  $core.bool hasRegion() => $_has(8);
  void clearRegion() => clearField(9);

  $core.String get node => $_getS(9, '');
  set node($core.String v) { $_setString(9, v); }
  $core.bool hasNode() => $_has(9);
  void clearNode() => clearField(10);

  $core.String get port => $_getS(10, '');
  set port($core.String v) { $_setString(10, v); }
  $core.bool hasPort() => $_has(10);
  void clearPort() => clearField(11);
}

enum TideChartMessage_Content {
  jsonContent, 
  msgContent, 
  notSet
}

class TideChartMessage extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartMessage_Content> _TideChartMessage_ContentByTag = {
    14 : TideChartMessage_Content.jsonContent,
    15 : TideChartMessage_Content.msgContent,
    0 : TideChartMessage_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartMessage')
    ..oo(0, [14, 15])
    ..aInt64(1, 'index')
    ..aInt64(2, 'timestamp')
    ..aInt64(4, 'origin')
    ..aInt64(5, 'previous')
    ..aInt64(7, 'source')
    ..aInt64(8, 'target')
    ..aInt64(9, 'delayUntil')
    ..aInt64(10, 'holdToken')
    ..aInt64(11, 'cancelToken')
    ..aOS(12, 'type')
    ..a<$core.int>(13, 'version', $pb.PbFieldType.O3)
    ..aOS(14, 'jsonContent')
    ..a<$core.List<$core.int>>(15, 'msgContent', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  TideChartMessage._() : super();
  factory TideChartMessage() => create();
  factory TideChartMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartMessage clone() => TideChartMessage()..mergeFromMessage(this);
  TideChartMessage copyWith(void Function(TideChartMessage) updates) => super.copyWith((message) => updates(message as TideChartMessage));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartMessage create() => TideChartMessage._();
  TideChartMessage createEmptyInstance() => create();
  static $pb.PbList<TideChartMessage> createRepeated() => $pb.PbList<TideChartMessage>();
  static TideChartMessage getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartMessage _defaultInstance;

  TideChartMessage_Content whichContent() => _TideChartMessage_ContentByTag[$_whichOneof(0)];
  void clearContent() => clearField($_whichOneof(0));

  Int64 get index => $_getI64(0);
  set index(Int64 v) { $_setInt64(0, v); }
  $core.bool hasIndex() => $_has(0);
  void clearIndex() => clearField(1);

  Int64 get timestamp => $_getI64(1);
  set timestamp(Int64 v) { $_setInt64(1, v); }
  $core.bool hasTimestamp() => $_has(1);
  void clearTimestamp() => clearField(2);

  Int64 get origin => $_getI64(2);
  set origin(Int64 v) { $_setInt64(2, v); }
  $core.bool hasOrigin() => $_has(2);
  void clearOrigin() => clearField(4);

  Int64 get previous => $_getI64(3);
  set previous(Int64 v) { $_setInt64(3, v); }
  $core.bool hasPrevious() => $_has(3);
  void clearPrevious() => clearField(5);

  Int64 get source => $_getI64(4);
  set source(Int64 v) { $_setInt64(4, v); }
  $core.bool hasSource() => $_has(4);
  void clearSource() => clearField(7);

  Int64 get target => $_getI64(5);
  set target(Int64 v) { $_setInt64(5, v); }
  $core.bool hasTarget() => $_has(5);
  void clearTarget() => clearField(8);

  Int64 get delayUntil => $_getI64(6);
  set delayUntil(Int64 v) { $_setInt64(6, v); }
  $core.bool hasDelayUntil() => $_has(6);
  void clearDelayUntil() => clearField(9);

  Int64 get holdToken => $_getI64(7);
  set holdToken(Int64 v) { $_setInt64(7, v); }
  $core.bool hasHoldToken() => $_has(7);
  void clearHoldToken() => clearField(10);

  Int64 get cancelToken => $_getI64(8);
  set cancelToken(Int64 v) { $_setInt64(8, v); }
  $core.bool hasCancelToken() => $_has(8);
  void clearCancelToken() => clearField(11);

  $core.String get type => $_getS(9, '');
  set type($core.String v) { $_setString(9, v); }
  $core.bool hasType() => $_has(9);
  void clearType() => clearField(12);

  $core.int get version => $_get(10, 0);
  set version($core.int v) { $_setSignedInt32(10, v); }
  $core.bool hasVersion() => $_has(10);
  void clearVersion() => clearField(13);

  $core.String get jsonContent => $_getS(11, '');
  set jsonContent($core.String v) { $_setString(11, v); }
  $core.bool hasJsonContent() => $_has(11);
  void clearJsonContent() => clearField(14);

  $core.List<$core.int> get msgContent => $_getN(12);
  set msgContent($core.List<$core.int> v) { $_setBytes(12, v); }
  $core.bool hasMsgContent() => $_has(12);
  void clearMsgContent() => clearField(15);
}

class TideChart extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChart')
    ..aOS(1, 'version')
    ..aOS(2, 'branch')
    ..aOS(3, 'source')
    ..aOS(4, 'merge')
    ..aOS(5, 'commitDate')
    ..aOS(6, 'commitBy')
    ..aOS(7, 'commitDesc')
    ..aOS(8, 'commitNotes')
    ..pc<TideChartGraph>(9, 'graphs', $pb.PbFieldType.PM,TideChartGraph.create)
    ..pc<TideChartProperty>(10, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..pc<TideChartNote>(11, 'notes', $pb.PbFieldType.PM,TideChartNote.create)
    ..pc<TideChartLibrary>(12, 'library', $pb.PbFieldType.PM,TideChartLibrary.create)
    ..pc<TideChartProperty>(13, 'global', $pb.PbFieldType.PM,TideChartProperty.create)
    ..hasRequiredFields = false
  ;

  TideChart._() : super();
  factory TideChart() => create();
  factory TideChart.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChart.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChart clone() => TideChart()..mergeFromMessage(this);
  TideChart copyWith(void Function(TideChart) updates) => super.copyWith((message) => updates(message as TideChart));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChart create() => TideChart._();
  TideChart createEmptyInstance() => create();
  static $pb.PbList<TideChart> createRepeated() => $pb.PbList<TideChart>();
  static TideChart getDefault() => _defaultInstance ??= create()..freeze();
  static TideChart _defaultInstance;

  $core.String get version => $_getS(0, '');
  set version($core.String v) { $_setString(0, v); }
  $core.bool hasVersion() => $_has(0);
  void clearVersion() => clearField(1);

  $core.String get branch => $_getS(1, '');
  set branch($core.String v) { $_setString(1, v); }
  $core.bool hasBranch() => $_has(1);
  void clearBranch() => clearField(2);

  $core.String get source => $_getS(2, '');
  set source($core.String v) { $_setString(2, v); }
  $core.bool hasSource() => $_has(2);
  void clearSource() => clearField(3);

  $core.String get merge => $_getS(3, '');
  set merge($core.String v) { $_setString(3, v); }
  $core.bool hasMerge() => $_has(3);
  void clearMerge() => clearField(4);

  $core.String get commitDate => $_getS(4, '');
  set commitDate($core.String v) { $_setString(4, v); }
  $core.bool hasCommitDate() => $_has(4);
  void clearCommitDate() => clearField(5);

  $core.String get commitBy => $_getS(5, '');
  set commitBy($core.String v) { $_setString(5, v); }
  $core.bool hasCommitBy() => $_has(5);
  void clearCommitBy() => clearField(6);

  $core.String get commitDesc => $_getS(6, '');
  set commitDesc($core.String v) { $_setString(6, v); }
  $core.bool hasCommitDesc() => $_has(6);
  void clearCommitDesc() => clearField(7);

  $core.String get commitNotes => $_getS(7, '');
  set commitNotes($core.String v) { $_setString(7, v); }
  $core.bool hasCommitNotes() => $_has(7);
  void clearCommitNotes() => clearField(8);

  $core.List<TideChartGraph> get graphs => $_getList(8);

  $core.List<TideChartProperty> get props => $_getList(9);

  $core.List<TideChartNote> get notes => $_getList(10);

  $core.List<TideChartLibrary> get library => $_getList(11);

  $core.List<TideChartProperty> get global => $_getList(12);
}

class TideChartHeader extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartHeader')
    ..aOS(1, 'version')
    ..aOS(2, 'branch')
    ..aOS(3, 'source')
    ..aOS(4, 'merge')
    ..aOS(5, 'commitDate')
    ..aOS(6, 'commitBy')
    ..aOS(7, 'commitDesc')
    ..aOS(8, 'commitNotes')
    ..hasRequiredFields = false
  ;

  TideChartHeader._() : super();
  factory TideChartHeader() => create();
  factory TideChartHeader.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartHeader.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartHeader clone() => TideChartHeader()..mergeFromMessage(this);
  TideChartHeader copyWith(void Function(TideChartHeader) updates) => super.copyWith((message) => updates(message as TideChartHeader));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartHeader create() => TideChartHeader._();
  TideChartHeader createEmptyInstance() => create();
  static $pb.PbList<TideChartHeader> createRepeated() => $pb.PbList<TideChartHeader>();
  static TideChartHeader getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartHeader _defaultInstance;

  $core.String get version => $_getS(0, '');
  set version($core.String v) { $_setString(0, v); }
  $core.bool hasVersion() => $_has(0);
  void clearVersion() => clearField(1);

  $core.String get branch => $_getS(1, '');
  set branch($core.String v) { $_setString(1, v); }
  $core.bool hasBranch() => $_has(1);
  void clearBranch() => clearField(2);

  $core.String get source => $_getS(2, '');
  set source($core.String v) { $_setString(2, v); }
  $core.bool hasSource() => $_has(2);
  void clearSource() => clearField(3);

  $core.String get merge => $_getS(3, '');
  set merge($core.String v) { $_setString(3, v); }
  $core.bool hasMerge() => $_has(3);
  void clearMerge() => clearField(4);

  $core.String get commitDate => $_getS(4, '');
  set commitDate($core.String v) { $_setString(4, v); }
  $core.bool hasCommitDate() => $_has(4);
  void clearCommitDate() => clearField(5);

  $core.String get commitBy => $_getS(5, '');
  set commitBy($core.String v) { $_setString(5, v); }
  $core.bool hasCommitBy() => $_has(5);
  void clearCommitBy() => clearField(6);

  $core.String get commitDesc => $_getS(6, '');
  set commitDesc($core.String v) { $_setString(6, v); }
  $core.bool hasCommitDesc() => $_has(6);
  void clearCommitDesc() => clearField(7);

  $core.String get commitNotes => $_getS(7, '');
  set commitNotes($core.String v) { $_setString(7, v); }
  $core.bool hasCommitNotes() => $_has(7);
  void clearCommitNotes() => clearField(8);
}

class TideChartFile extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartFile')
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'path')
    ..aOS(4, 'origin')
    ..aOS(5, 'createdDate')
    ..aOS(6, 'createdBy')
    ..a<TideChart>(7, 'chart', $pb.PbFieldType.OM, TideChart.getDefault, TideChart.create)
    ..pc<TideChartCommand>(8, 'working', $pb.PbFieldType.PM,TideChartCommand.create)
    ..pc<TideChartCommand>(9, 'remote', $pb.PbFieldType.PM,TideChartCommand.create)
    ..pc<TideChart>(10, 'history', $pb.PbFieldType.PM,TideChart.create)
    ..hasRequiredFields = false
  ;

  TideChartFile._() : super();
  factory TideChartFile() => create();
  factory TideChartFile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartFile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartFile clone() => TideChartFile()..mergeFromMessage(this);
  TideChartFile copyWith(void Function(TideChartFile) updates) => super.copyWith((message) => updates(message as TideChartFile));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartFile create() => TideChartFile._();
  TideChartFile createEmptyInstance() => create();
  static $pb.PbList<TideChartFile> createRepeated() => $pb.PbList<TideChartFile>();
  static TideChartFile getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartFile _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get path => $_getS(2, '');
  set path($core.String v) { $_setString(2, v); }
  $core.bool hasPath() => $_has(2);
  void clearPath() => clearField(3);

  $core.String get origin => $_getS(3, '');
  set origin($core.String v) { $_setString(3, v); }
  $core.bool hasOrigin() => $_has(3);
  void clearOrigin() => clearField(4);

  $core.String get createdDate => $_getS(4, '');
  set createdDate($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedDate() => $_has(4);
  void clearCreatedDate() => clearField(5);

  $core.String get createdBy => $_getS(5, '');
  set createdBy($core.String v) { $_setString(5, v); }
  $core.bool hasCreatedBy() => $_has(5);
  void clearCreatedBy() => clearField(6);

  TideChart get chart => $_getN(6);
  set chart(TideChart v) { setField(7, v); }
  $core.bool hasChart() => $_has(6);
  void clearChart() => clearField(7);

  $core.List<TideChartCommand> get working => $_getList(7);

  $core.List<TideChartCommand> get remote => $_getList(8);

  $core.List<TideChart> get history => $_getList(9);
}

class TideChartFileHeader extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartFileHeader')
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'path')
    ..aOS(4, 'origin')
    ..aOS(5, 'createdDate')
    ..aOS(6, 'createdBy')
    ..hasRequiredFields = false
  ;

  TideChartFileHeader._() : super();
  factory TideChartFileHeader() => create();
  factory TideChartFileHeader.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartFileHeader.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartFileHeader clone() => TideChartFileHeader()..mergeFromMessage(this);
  TideChartFileHeader copyWith(void Function(TideChartFileHeader) updates) => super.copyWith((message) => updates(message as TideChartFileHeader));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartFileHeader create() => TideChartFileHeader._();
  TideChartFileHeader createEmptyInstance() => create();
  static $pb.PbList<TideChartFileHeader> createRepeated() => $pb.PbList<TideChartFileHeader>();
  static TideChartFileHeader getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartFileHeader _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get path => $_getS(2, '');
  set path($core.String v) { $_setString(2, v); }
  $core.bool hasPath() => $_has(2);
  void clearPath() => clearField(3);

  $core.String get origin => $_getS(3, '');
  set origin($core.String v) { $_setString(3, v); }
  $core.bool hasOrigin() => $_has(3);
  void clearOrigin() => clearField(4);

  $core.String get createdDate => $_getS(4, '');
  set createdDate($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedDate() => $_has(4);
  void clearCreatedDate() => clearField(5);

  $core.String get createdBy => $_getS(5, '');
  set createdBy($core.String v) { $_setString(5, v); }
  $core.bool hasCreatedBy() => $_has(5);
  void clearCreatedBy() => clearField(6);
}

class TideChartFileCurrent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartFileCurrent')
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'path')
    ..aOS(4, 'origin')
    ..aOS(5, 'createdDate')
    ..aOS(6, 'createdBy')
    ..a<TideChart>(7, 'chart', $pb.PbFieldType.OM, TideChart.getDefault, TideChart.create)
    ..hasRequiredFields = false
  ;

  TideChartFileCurrent._() : super();
  factory TideChartFileCurrent() => create();
  factory TideChartFileCurrent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartFileCurrent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartFileCurrent clone() => TideChartFileCurrent()..mergeFromMessage(this);
  TideChartFileCurrent copyWith(void Function(TideChartFileCurrent) updates) => super.copyWith((message) => updates(message as TideChartFileCurrent));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartFileCurrent create() => TideChartFileCurrent._();
  TideChartFileCurrent createEmptyInstance() => create();
  static $pb.PbList<TideChartFileCurrent> createRepeated() => $pb.PbList<TideChartFileCurrent>();
  static TideChartFileCurrent getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartFileCurrent _defaultInstance;

  $core.String get id => $_getS(0, '');
  set id($core.String v) { $_setString(0, v); }
  $core.bool hasId() => $_has(0);
  void clearId() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get path => $_getS(2, '');
  set path($core.String v) { $_setString(2, v); }
  $core.bool hasPath() => $_has(2);
  void clearPath() => clearField(3);

  $core.String get origin => $_getS(3, '');
  set origin($core.String v) { $_setString(3, v); }
  $core.bool hasOrigin() => $_has(3);
  void clearOrigin() => clearField(4);

  $core.String get createdDate => $_getS(4, '');
  set createdDate($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedDate() => $_has(4);
  void clearCreatedDate() => clearField(5);

  $core.String get createdBy => $_getS(5, '');
  set createdBy($core.String v) { $_setString(5, v); }
  $core.bool hasCreatedBy() => $_has(5);
  void clearCreatedBy() => clearField(6);

  TideChart get chart => $_getN(6);
  set chart(TideChart v) { setField(7, v); }
  $core.bool hasChart() => $_has(6);
  void clearChart() => clearField(7);
}

