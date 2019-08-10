///
//  Generated code. Do not modify.
//  source: tide_chart.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:protobuf/protobuf.dart' as $pb;

class TideChartPort extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPort')
    ..aOS(1, 'type')
    ..aOS(2, 'node')
    ..aOS(3, 'name')
    ..a<$core.int>(4, 'ordinal', $pb.PbFieldType.O3)
    ..pc<TideChartProperty>(5, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
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

  $core.String get node => $_getS(1, '');
  set node($core.String v) { $_setString(1, v); }
  $core.bool hasNode() => $_has(1);
  void clearNode() => clearField(2);

  $core.String get name => $_getS(2, '');
  set name($core.String v) { $_setString(2, v); }
  $core.bool hasName() => $_has(2);
  void clearName() => clearField(3);

  $core.int get ordinal => $_get(3, 0);
  set ordinal($core.int v) { $_setSignedInt32(3, v); }
  $core.bool hasOrdinal() => $_has(3);
  void clearOrdinal() => clearField(4);

  $core.List<TideChartProperty> get props => $_getList(4);
}

class TideChartLink extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartLink')
    ..a<TideChartPort>(1, 'fromPort', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..a<TideChartPort>(2, 'toPort', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..a<$core.int>(3, 'group', $pb.PbFieldType.O3)
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

  TideChartPort get fromPort => $_getN(0);
  set fromPort(TideChartPort v) { setField(1, v); }
  $core.bool hasFromPort() => $_has(0);
  void clearFromPort() => clearField(1);

  TideChartPort get toPort => $_getN(1);
  set toPort(TideChartPort v) { setField(2, v); }
  $core.bool hasToPort() => $_has(1);
  void clearToPort() => clearField(2);

  $core.int get group => $_get(2, 0);
  set group($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasGroup() => $_has(2);
  void clearGroup() => clearField(3);
}

class TideChartNode extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNode')
    ..aOS(1, 'name')
    ..aOS(2, 'type')
    ..a<TideChartOffset>(3, 'pos', $pb.PbFieldType.OM, TideChartOffset.getDefault, TideChartOffset.create)
    ..aOS(4, 'title')
    ..aOS(5, 'icon')
    ..aOS(6, 'method')
    ..aOS(7, 'comment')
    ..aOB(8, 'logging')
    ..aOB(9, 'debugging')
    ..a<$core.double>(10, 'delay', $pb.PbFieldType.OD)
    ..pc<TideChartPort>(11, 'inports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartPort>(12, 'outports', $pb.PbFieldType.PM,TideChartPort.create)
    ..pc<TideChartProperty>(13, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
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

  TideChartOffset get pos => $_getN(2);
  set pos(TideChartOffset v) { setField(3, v); }
  $core.bool hasPos() => $_has(2);
  void clearPos() => clearField(3);

  $core.String get title => $_getS(3, '');
  set title($core.String v) { $_setString(3, v); }
  $core.bool hasTitle() => $_has(3);
  void clearTitle() => clearField(4);

  $core.String get icon => $_getS(4, '');
  set icon($core.String v) { $_setString(4, v); }
  $core.bool hasIcon() => $_has(4);
  void clearIcon() => clearField(5);

  $core.String get method => $_getS(5, '');
  set method($core.String v) { $_setString(5, v); }
  $core.bool hasMethod() => $_has(5);
  void clearMethod() => clearField(6);

  $core.String get comment => $_getS(6, '');
  set comment($core.String v) { $_setString(6, v); }
  $core.bool hasComment() => $_has(6);
  void clearComment() => clearField(7);

  $core.bool get logging => $_get(7, false);
  set logging($core.bool v) { $_setBool(7, v); }
  $core.bool hasLogging() => $_has(7);
  void clearLogging() => clearField(8);

  $core.bool get debugging => $_get(8, false);
  set debugging($core.bool v) { $_setBool(8, v); }
  $core.bool hasDebugging() => $_has(8);
  void clearDebugging() => clearField(9);

  $core.double get delay => $_getN(9);
  set delay($core.double v) { $_setDouble(9, v); }
  $core.bool hasDelay() => $_has(9);
  void clearDelay() => clearField(10);

  $core.List<TideChartPort> get inports => $_getList(10);

  $core.List<TideChartPort> get outports => $_getList(11);

  $core.List<TideChartProperty> get props => $_getList(12);
}

class TideChartOffset extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartOffset')
    ..a<$core.double>(1, 'dx', $pb.PbFieldType.OD)
    ..a<$core.double>(2, 'dy', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  TideChartOffset._() : super();
  factory TideChartOffset() => create();
  factory TideChartOffset.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TideChartOffset.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TideChartOffset clone() => TideChartOffset()..mergeFromMessage(this);
  TideChartOffset copyWith(void Function(TideChartOffset) updates) => super.copyWith((message) => updates(message as TideChartOffset));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TideChartOffset create() => TideChartOffset._();
  TideChartOffset createEmptyInstance() => create();
  static $pb.PbList<TideChartOffset> createRepeated() => $pb.PbList<TideChartOffset>();
  static TideChartOffset getDefault() => _defaultInstance ??= create()..freeze();
  static TideChartOffset _defaultInstance;

  $core.double get dx => $_getN(0);
  set dx($core.double v) { $_setDouble(0, v); }
  $core.bool hasDx() => $_has(0);
  void clearDx() => clearField(1);

  $core.double get dy => $_getN(1);
  set dy($core.double v) { $_setDouble(1, v); }
  $core.bool hasDy() => $_has(1);
  void clearDy() => clearField(2);
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
    ..a<TideChartOffset>(2, 'fromPos', $pb.PbFieldType.OM, TideChartOffset.getDefault, TideChartOffset.create)
    ..a<TideChartOffset>(3, 'toPos', $pb.PbFieldType.OM, TideChartOffset.getDefault, TideChartOffset.create)
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

  TideChartOffset get fromPos => $_getN(1);
  set fromPos(TideChartOffset v) { setField(2, v); }
  $core.bool hasFromPos() => $_has(1);
  void clearFromPos() => clearField(2);

  TideChartOffset get toPos => $_getN(2);
  set toPos(TideChartOffset v) { setField(3, v); }
  $core.bool hasToPos() => $_has(2);
  void clearToPos() => clearField(3);
}

class TideChartNodeCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartNodeCommand')
    ..aOS(1, 'node')
    ..aOS(2, 'type')
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

  $core.String get node => $_getS(0, '');
  set node($core.String v) { $_setString(0, v); }
  $core.bool hasNode() => $_has(0);
  void clearNode() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);
}

class TideChartPortCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPortCommand')
    ..a<TideChartPort>(1, 'port', $pb.PbFieldType.OM, TideChartPort.getDefault, TideChartPort.create)
    ..aOS(2, 'type')
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

  TideChartPort get port => $_getN(0);
  set port(TideChartPort v) { setField(1, v); }
  $core.bool hasPort() => $_has(0);
  void clearPort() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);
}

class TideChartLinkCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartLinkCommand')
    ..a<TideChartLink>(1, 'link', $pb.PbFieldType.OM, TideChartLink.getDefault, TideChartLink.create)
    ..aOS(2, 'type')
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

  TideChartLink get link => $_getN(0);
  set link(TideChartLink v) { setField(1, v); }
  $core.bool hasLink() => $_has(0);
  void clearLink() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);
}

class TideChartGraphCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartGraphCommand')
    ..a<TideChartGraph>(1, 'graph', $pb.PbFieldType.OM, TideChartGraph.getDefault, TideChartGraph.create)
    ..aOS(2, 'type')
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

  TideChartGraph get graph => $_getN(0);
  set graph(TideChartGraph v) { setField(1, v); }
  $core.bool hasGraph() => $_has(0);
  void clearGraph() => clearField(1);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);
}

enum TideChartPropertyCommand_Target {
  node, 
  port, 
  graph, 
  chart, 
  notSet
}

class TideChartPropertyCommand extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartPropertyCommand_Target> _TideChartPropertyCommand_TargetByTag = {
    3 : TideChartPropertyCommand_Target.node,
    4 : TideChartPropertyCommand_Target.port,
    5 : TideChartPropertyCommand_Target.graph,
    6 : TideChartPropertyCommand_Target.chart,
    0 : TideChartPropertyCommand_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartPropertyCommand')
    ..oo(0, [3, 4, 5, 6])
    ..pc<TideChartProperty>(1, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
    ..aOS(2, 'type')
    ..aOS(3, 'node')
    ..aOS(4, 'port')
    ..aOS(5, 'graph')
    ..aOS(6, 'chart')
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

  $core.List<TideChartProperty> get props => $_getList(0);

  $core.String get type => $_getS(1, '');
  set type($core.String v) { $_setString(1, v); }
  $core.bool hasType() => $_has(1);
  void clearType() => clearField(2);

  $core.String get node => $_getS(2, '');
  set node($core.String v) { $_setString(2, v); }
  $core.bool hasNode() => $_has(2);
  void clearNode() => clearField(3);

  $core.String get port => $_getS(3, '');
  set port($core.String v) { $_setString(3, v); }
  $core.bool hasPort() => $_has(3);
  void clearPort() => clearField(4);

  $core.String get graph => $_getS(4, '');
  set graph($core.String v) { $_setString(4, v); }
  $core.bool hasGraph() => $_has(4);
  void clearGraph() => clearField(5);

  $core.String get chart => $_getS(5, '');
  set chart($core.String v) { $_setString(5, v); }
  $core.bool hasChart() => $_has(5);
  void clearChart() => clearField(6);
}

enum TideChartCommand_Command {
  group, 
  move, 
  node, 
  port, 
  link, 
  graph, 
  props, 
  notSet
}

class TideChartCommand extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TideChartCommand_Command> _TideChartCommand_CommandByTag = {
    3 : TideChartCommand_Command.group,
    4 : TideChartCommand_Command.move,
    5 : TideChartCommand_Command.node,
    6 : TideChartCommand_Command.port,
    7 : TideChartCommand_Command.link,
    8 : TideChartCommand_Command.graph,
    9 : TideChartCommand_Command.props,
    0 : TideChartCommand_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartCommand')
    ..oo(0, [3, 4, 5, 6, 7, 8, 9])
    ..aOS(1, 'version')
    ..aOS(2, 'id')
    ..a<TideChartGroupCommand>(3, 'group', $pb.PbFieldType.OM, TideChartGroupCommand.getDefault, TideChartGroupCommand.create)
    ..a<TideChartMoveCommand>(4, 'move', $pb.PbFieldType.OM, TideChartMoveCommand.getDefault, TideChartMoveCommand.create)
    ..a<TideChartNodeCommand>(5, 'node', $pb.PbFieldType.OM, TideChartNodeCommand.getDefault, TideChartNodeCommand.create)
    ..a<TideChartPortCommand>(6, 'port', $pb.PbFieldType.OM, TideChartPortCommand.getDefault, TideChartPortCommand.create)
    ..a<TideChartLinkCommand>(7, 'link', $pb.PbFieldType.OM, TideChartLinkCommand.getDefault, TideChartLinkCommand.create)
    ..a<TideChartGraphCommand>(8, 'graph', $pb.PbFieldType.OM, TideChartGraphCommand.getDefault, TideChartGraphCommand.create)
    ..a<TideChartPropertyCommand>(9, 'props', $pb.PbFieldType.OM, TideChartPropertyCommand.getDefault, TideChartPropertyCommand.create)
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

  $core.String get id => $_getS(1, '');
  set id($core.String v) { $_setString(1, v); }
  $core.bool hasId() => $_has(1);
  void clearId() => clearField(2);

  TideChartGroupCommand get group => $_getN(2);
  set group(TideChartGroupCommand v) { setField(3, v); }
  $core.bool hasGroup() => $_has(2);
  void clearGroup() => clearField(3);

  TideChartMoveCommand get move => $_getN(3);
  set move(TideChartMoveCommand v) { setField(4, v); }
  $core.bool hasMove() => $_has(3);
  void clearMove() => clearField(4);

  TideChartNodeCommand get node => $_getN(4);
  set node(TideChartNodeCommand v) { setField(5, v); }
  $core.bool hasNode() => $_has(4);
  void clearNode() => clearField(5);

  TideChartPortCommand get port => $_getN(5);
  set port(TideChartPortCommand v) { setField(6, v); }
  $core.bool hasPort() => $_has(5);
  void clearPort() => clearField(6);

  TideChartLinkCommand get link => $_getN(6);
  set link(TideChartLinkCommand v) { setField(7, v); }
  $core.bool hasLink() => $_has(6);
  void clearLink() => clearField(7);

  TideChartGraphCommand get graph => $_getN(7);
  set graph(TideChartGraphCommand v) { setField(8, v); }
  $core.bool hasGraph() => $_has(7);
  void clearGraph() => clearField(8);

  TideChartPropertyCommand get props => $_getN(8);
  set props(TideChartPropertyCommand v) { setField(9, v); }
  $core.bool hasProps() => $_has(8);
  void clearProps() => clearField(9);
}

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

class TideChartGraph extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartGraph')
    ..aOS(1, 'id')
    ..aOS(2, 'title')
    ..aOS(3, 'version')
    ..aOS(4, 'source')
    ..pc<TideChartNode>(5, 'nodes', $pb.PbFieldType.PM,TideChartNode.create)
    ..pc<TideChartLink>(6, 'links', $pb.PbFieldType.PM,TideChartLink.create)
    ..pc<TideChartCommand>(7, 'history', $pb.PbFieldType.PM,TideChartCommand.create)
    ..pc<TideChartProperty>(8, 'props', $pb.PbFieldType.PM,TideChartProperty.create)
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

  $core.String get title => $_getS(1, '');
  set title($core.String v) { $_setString(1, v); }
  $core.bool hasTitle() => $_has(1);
  void clearTitle() => clearField(2);

  $core.String get version => $_getS(2, '');
  set version($core.String v) { $_setString(2, v); }
  $core.bool hasVersion() => $_has(2);
  void clearVersion() => clearField(3);

  $core.String get source => $_getS(3, '');
  set source($core.String v) { $_setString(3, v); }
  $core.bool hasSource() => $_has(3);
  void clearSource() => clearField(4);

  $core.List<TideChartNode> get nodes => $_getList(4);

  $core.List<TideChartLink> get links => $_getList(5);

  $core.List<TideChartCommand> get history => $_getList(6);

  $core.List<TideChartProperty> get props => $_getList(7);
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
}

class TideChartFile extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartFile')
    ..aOS(1, 'id')
    ..aOS(2, 'filename')
    ..aOS(3, 'folder')
    ..aOS(4, 'createdDate')
    ..aOS(5, 'createdBy')
    ..aOS(6, 'origin')
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

  $core.String get filename => $_getS(1, '');
  set filename($core.String v) { $_setString(1, v); }
  $core.bool hasFilename() => $_has(1);
  void clearFilename() => clearField(2);

  $core.String get folder => $_getS(2, '');
  set folder($core.String v) { $_setString(2, v); }
  $core.bool hasFolder() => $_has(2);
  void clearFolder() => clearField(3);

  $core.String get createdDate => $_getS(3, '');
  set createdDate($core.String v) { $_setString(3, v); }
  $core.bool hasCreatedDate() => $_has(3);
  void clearCreatedDate() => clearField(4);

  $core.String get createdBy => $_getS(4, '');
  set createdBy($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedBy() => $_has(4);
  void clearCreatedBy() => clearField(5);

  $core.String get origin => $_getS(5, '');
  set origin($core.String v) { $_setString(5, v); }
  $core.bool hasOrigin() => $_has(5);
  void clearOrigin() => clearField(6);

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
    ..aOS(2, 'filename')
    ..aOS(3, 'folder')
    ..aOS(4, 'createdDate')
    ..aOS(5, 'createdBy')
    ..aOS(6, 'origin')
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

  $core.String get filename => $_getS(1, '');
  set filename($core.String v) { $_setString(1, v); }
  $core.bool hasFilename() => $_has(1);
  void clearFilename() => clearField(2);

  $core.String get folder => $_getS(2, '');
  set folder($core.String v) { $_setString(2, v); }
  $core.bool hasFolder() => $_has(2);
  void clearFolder() => clearField(3);

  $core.String get createdDate => $_getS(3, '');
  set createdDate($core.String v) { $_setString(3, v); }
  $core.bool hasCreatedDate() => $_has(3);
  void clearCreatedDate() => clearField(4);

  $core.String get createdBy => $_getS(4, '');
  set createdBy($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedBy() => $_has(4);
  void clearCreatedBy() => clearField(5);

  $core.String get origin => $_getS(5, '');
  set origin($core.String v) { $_setString(5, v); }
  $core.bool hasOrigin() => $_has(5);
  void clearOrigin() => clearField(6);
}

class TideChartFileCurrent extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TideChartFileCurrent')
    ..aOS(1, 'id')
    ..aOS(2, 'filename')
    ..aOS(3, 'folder')
    ..aOS(4, 'createdDate')
    ..aOS(5, 'createdBy')
    ..aOS(6, 'origin')
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

  $core.String get filename => $_getS(1, '');
  set filename($core.String v) { $_setString(1, v); }
  $core.bool hasFilename() => $_has(1);
  void clearFilename() => clearField(2);

  $core.String get folder => $_getS(2, '');
  set folder($core.String v) { $_setString(2, v); }
  $core.bool hasFolder() => $_has(2);
  void clearFolder() => clearField(3);

  $core.String get createdDate => $_getS(3, '');
  set createdDate($core.String v) { $_setString(3, v); }
  $core.bool hasCreatedDate() => $_has(3);
  void clearCreatedDate() => clearField(4);

  $core.String get createdBy => $_getS(4, '');
  set createdBy($core.String v) { $_setString(4, v); }
  $core.bool hasCreatedBy() => $_has(4);
  void clearCreatedBy() => clearField(5);

  $core.String get origin => $_getS(5, '');
  set origin($core.String v) { $_setString(5, v); }
  $core.bool hasOrigin() => $_has(5);
  void clearOrigin() => clearField(6);

  TideChart get chart => $_getN(6);
  set chart(TideChart v) { setField(7, v); }
  $core.bool hasChart() => $_has(6);
  void clearChart() => clearField(7);
}

