///
//  Generated code. Do not modify.
//  source: tide_chart.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_const

const TideChartPort$json = const {
  '1': 'TideChartPort',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'node', '3': 2, '4': 1, '5': 9, '10': 'node'},
    const {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'ordinal', '3': 4, '4': 1, '5': 5, '10': 'ordinal'},
    const {
      '1': 'props',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
  ],
};

const TideChartLink$json = const {
  '1': 'TideChartLink',
  '2': const [
    const {
      '1': 'fromPort',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.TideChartPort',
      '10': 'fromPort'
    },
    const {
      '1': 'toPort',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.TideChartPort',
      '10': 'toPort'
    },
    const {'1': 'group', '3': 3, '4': 1, '5': 5, '10': 'group'},
  ],
};

const TideChartNode$json = const {
  '1': 'TideChartNode',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'version', '3': 3, '4': 1, '5': 5, '10': 'version'},
    const {
      '1': 'pos',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.TideChartOffset',
      '10': 'pos'
    },
    const {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    const {'1': 'method', '3': 7, '4': 1, '5': 9, '10': 'method'},
    const {'1': 'comment', '3': 8, '4': 1, '5': 9, '10': 'comment'},
    const {'1': 'logging', '3': 9, '4': 1, '5': 8, '10': 'logging'},
    const {'1': 'debugging', '3': 10, '4': 1, '5': 8, '10': 'debugging'},
    const {'1': 'delay', '3': 11, '4': 1, '5': 1, '10': 'delay'},
    const {
      '1': 'inports',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.TideChartPort',
      '10': 'inports'
    },
    const {
      '1': 'outports',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.TideChartPort',
      '10': 'outports'
    },
    const {
      '1': 'props',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
  ],
};

const TideChartOffset$json = const {
  '1': 'TideChartOffset',
  '2': const [
    const {'1': 'x', '3': 1, '4': 1, '5': 1, '10': 'x'},
    const {'1': 'y', '3': 2, '4': 1, '5': 1, '10': 'y'},
  ],
};

const TideChartGroupCommand$json = const {
  '1': 'TideChartGroupCommand',
  '2': const [
    const {
      '1': 'cmds',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.TideChartCommand',
      '10': 'cmds'
    },
  ],
};

const TideChartMoveCommand$json = const {
  '1': 'TideChartMoveCommand',
  '2': const [
    const {'1': 'node', '3': 1, '4': 1, '5': 9, '10': 'node'},
    const {
      '1': 'fromPos',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.TideChartOffset',
      '10': 'fromPos'
    },
    const {
      '1': 'toPos',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.TideChartOffset',
      '10': 'toPos'
    },
  ],
};

const TideChartNodeCommand$json = const {
  '1': 'TideChartNodeCommand',
  '2': const [
    const {'1': 'node', '3': 1, '4': 1, '5': 9, '10': 'node'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
  ],
};

const TideChartPortCommand$json = const {
  '1': 'TideChartPortCommand',
  '2': const [
    const {
      '1': 'port',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.TideChartPort',
      '10': 'port'
    },
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
  ],
};

const TideChartLinkCommand$json = const {
  '1': 'TideChartLinkCommand',
  '2': const [
    const {
      '1': 'link',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.TideChartLink',
      '10': 'link'
    },
    const {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
  ],
};

const TideChartPropertyCommand$json = const {
  '1': 'TideChartPropertyCommand',
  '2': const [
    const {
      '1': 'props',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'node', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'node'},
    const {'1': 'port', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'port'},
    const {'1': 'graph', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'graph'},
    const {'1': 'chart', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'chart'},
  ],
  '8': const [
    const {'1': 'target'},
  ],
};

const TideChartCommand$json = const {
  '1': 'TideChartCommand',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'source', '3': 2, '4': 1, '5': 9, '10': 'source'},
    const {
      '1': 'group',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.TideChartGroupCommand',
      '9': 0,
      '10': 'group'
    },
    const {
      '1': 'move',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.TideChartMoveCommand',
      '9': 0,
      '10': 'move'
    },
    const {
      '1': 'node',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.TideChartNodeCommand',
      '9': 0,
      '10': 'node'
    },
    const {
      '1': 'port',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.TideChartPortCommand',
      '9': 0,
      '10': 'port'
    },
    const {
      '1': 'link',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.TideChartLinkCommand',
      '9': 0,
      '10': 'link'
    },
    const {
      '1': 'props',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.TideChartPropertyCommand',
      '9': 0,
      '10': 'props'
    },
  ],
  '8': const [
    const {'1': 'command'},
  ],
};

const TideChartHistory$json = const {
  '1': 'TideChartHistory',
  '2': const [
    const {'1': 'verion', '3': 1, '4': 1, '5': 9, '10': 'verion'},
    const {
      '1': 'undo',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.TideChartCommand',
      '10': 'undo'
    },
    const {
      '1': 'redo',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.TideChartCommand',
      '10': 'redo'
    },
  ],
};

const TideChartProperty$json = const {
  '1': 'TideChartProperty',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
    const {
      '1': 'props',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
  ],
};

const TideChartGraph$json = const {
  '1': 'TideChartGraph',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'version', '3': 3, '4': 1, '5': 5, '10': 'version'},
    const {
      '1': 'nodes',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.TideChartNode',
      '10': 'nodes'
    },
    const {
      '1': 'links',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.TideChartLink',
      '10': 'links'
    },
    const {
      '1': 'referenced',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.TideChartNode',
      '10': 'referenced'
    },
    const {
      '1': 'history',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.TideChartHistory',
      '10': 'history'
    },
    const {
      '1': 'props',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
  ],
};

const TideChart$json = const {
  '1': 'TideChart',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'branch', '3': 2, '4': 1, '5': 9, '10': 'branch'},
    const {'1': 'source', '3': 3, '4': 1, '5': 9, '10': 'source'},
    const {'1': 'merge', '3': 4, '4': 1, '5': 9, '10': 'merge'},
    const {'1': 'commitDate', '3': 5, '4': 1, '5': 9, '10': 'commitDate'},
    const {'1': 'commitBy', '3': 6, '4': 1, '5': 9, '10': 'commitBy'},
    const {'1': 'commitDesc', '3': 7, '4': 1, '5': 9, '10': 'commitDesc'},
    const {'1': 'commitNotes', '3': 8, '4': 1, '5': 9, '10': 'commitNotes'},
    const {
      '1': 'graphs',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.TideChartGraph',
      '10': 'graphs'
    },
    const {
      '1': 'props',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.TideChartProperty',
      '10': 'props'
    },
  ],
};

const TideChartFile$json = const {
  '1': 'TideChartFile',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    const {'1': 'folder', '3': 3, '4': 1, '5': 9, '10': 'folder'},
    const {'1': 'createdDate', '3': 4, '4': 1, '5': 9, '10': 'createdDate'},
    const {'1': 'createdBy', '3': 5, '4': 1, '5': 9, '10': 'createdBy'},
    const {'1': 'origin', '3': 6, '4': 1, '5': 9, '10': 'origin'},
    const {
      '1': 'current',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.TideChart',
      '10': 'current'
    },
    const {
      '1': 'history',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.TideChart',
      '10': 'history'
    },
    const {
      '1': 'working',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.TideChartCommand',
      '10': 'working'
    },
    const {
      '1': 'remote',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.TideChartCommand',
      '10': 'remote'
    },
  ],
};
