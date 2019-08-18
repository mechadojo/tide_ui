import 'package:tide_ui/graph_editor/controller/canvas_tabs_controller.dart';
import 'package:tide_ui/graph_editor/data/canvas_interactive.dart';

import 'update_notifier.dart';
import 'canvas_tab.dart';
import 'menu_item.dart';

class CanvasTabsState extends UpdateNotifier {
  CanvasTabsController controller;

  List<MenuItem> menu = [];
  List<CanvasTab> tabs = [];
  List<CanvasTab> history = [];

  String selected;
  String version;
  int nextTab = 1;
  int get length => tabs.length;
  bool requirePaint = false;

  CanvasTabsState({this.selected, this.tabs, this.menu}) {
    tabs = tabs ?? [];
    menu = menu ?? [];

    if (selected == null) {
      selected = first == null ? null : first.name;
    }
    nextTab = tabs.length + 1;
  }

  Iterable<CanvasInteractive> interactive() sync* {
    for (var item in menu) {
      yield item;
    }

    for (var tab in tabs) {
      yield tab.closeBtn;
      yield tab;
    }
  }

  int get selectedIndex => tabs.indexWhere((t) => t.name == selected);

  void shiftLeft() {
    if (tabs.length <= 1) return;
    var first = tabs.first;
    tabs = [...tabs.skip(1), first];
  }

  void shiftRight() {
    if (tabs.length <= 1) return;
    var last = tabs.last;
    tabs = [last, ...tabs.take(tabs.length - 1)];
  }

  void addRange(List<CanvasTab> tabs) {
    this.tabs = [...tabs];
    if (selected == null) {
      selected = first == null ? null : first.name;
    }
    nextTab = tabs.length + 1;
  }

  bool hasTab(String name) {
    return tabs.any((x) => x.name == name);
  }

  /// Add a new tab and optionally [select] it.
  CanvasTab add({String title, String name, String icon, bool select}) {
    if (name == null) name = "tab${nextTab++}";

    var tab = CanvasTab(title: title, name: name, icon: icon);
    addTab(tab, select);
    return tab;
  }

  /// Get the currently selected tab.
  CanvasTab get current {
    if (tabs.isEmpty) return null;
    return tabs.firstWhere((x) => x.name == selected);
  }

  /// Get the first tab in the list.
  CanvasTab get first {
    if (tabs.isEmpty) return null;
    return tabs.first;
  }

  /// Get the last tab in the list.
  CanvasTab get last {
    if (tabs.isEmpty) return null;
    return tabs.last;
  }

  /// Get the tab before the currently selected.
  CanvasTab get prev {
    CanvasTab last;
    for (var tab in tabs) {
      if (tab.name == selected) {
        return last;
      }
      last = tab;
    }

    return null;
  }

  /// Get the tab after the currently selected.
  CanvasTab get next {
    String last;
    for (var tab in tabs) {
      if (last != null) {
        return tab;
      }

      if (tab.name == selected) {
        last = tab.name;
      }
    }

    return null;
  }

  /// Find the tab with the given [name].
  CanvasTab find(String name) {
    if (name == null) return null;
    if (tabs.isEmpty) return null;
    return tabs.firstWhere((x) => x.name == name);
  }

  /// Select the tab with the given [name].
  void select(String name) {
    var tab = tabs.firstWhere((x) => x.name == name);
    selectTab(tab);
  }

  void selectIndex(int idx) {
    if (idx >= 0 && idx < tabs.length) {
      var tab = tabs[idx];
      selectTab(tab);
    }
  }

  /// Select a [tab].
  void selectTab(CanvasTab tab) {
    if (tab == null) return;
    if (!tabs.any((x) => x.name == tab.name)) return;
    if (tab.name == selected) return;

    selected = tab.name;
    notifyListeners();
  }

  /// Select the first tab.
  void selectFirst() {
    selectTab(first);
  }

  /// Select the last tab.
  void selectLast() {
    selectTab(last);
  }

  /// Select the tab before the currently selected one and optionally
  /// [wrap] around to the last tab.
  void selectPrev([bool wrap = true]) {
    var tab = prev;
    if (tab == null && wrap) tab = last;
    selectTab(tab);
  }

  /// Select the tab after the currently selected one and optionally
  /// [wrap] around to the first tab.
  void selectNext([bool wrap = true]) {
    var tab = next;
    if (tab == null && wrap) tab = first;
    selectTab(tab);
  }

  void addTab(CanvasTab tab, [bool select = false, bool replace = true]) {
    tabs = replace
        ? [...tabs.where((x) => x.name != tab.name), tab]
        : [...tabs, tab];

    if (select) selected = tab.name;

    notifyListeners();
  }

  void removeAll(List<String> names, [String select]) {
    if (select == null || !names.contains(select)) {
      if (names.contains(selected)) {
        String last;
        String next;

        for (var tab in tabs) {
          if (last != null && next != null) break;

          if (tab.name == selected) {
            next = tab.name;
            continue;
          }

          if (names.contains(tab.name)) continue;

          if (next != null) {
            next = tab.name;
            break;
          }

          last = tab.name;
        }

        select = next;
        if (select == null) select = last;
        if (select == null) select = first == null ? null : first.name;
      }
    }
    tabs = tabs.where((x) => !names.contains(x.name)).toList();
    if (select != null) {
      selected = select;
      if (current == null) selected = null;
    }

    notifyListeners();
  }

  void remove(String name) {
    CanvasTab tab = current;
    if (selected == name) {
      tab = next;
      if (tab == null) tab = prev;
      if (tab == null) tab = first;
    }

    selected = tab == null ? null : tab.name;

    var last = find(name);
    if (last != null) {
      history.add(last);
    }

    tabs = tabs.where((x) => x.name != name).toList();
    notifyListeners();
  }

  void restore([bool select = false]) {
    if (history.isNotEmpty) {
      var last = history.removeLast();
      last.clearInteractive();
      addTab(last, select);
    }
  }

  void replace(List<CanvasTab> tabs, [String select]) {
    this.tabs = [...tabs];
    history.clear();
    var tab = find(select);
    if (tab == null) tab = first;
    selectTab(tab);
  }

  void clear() {
    tabs.clear();
    history.clear();
    selected = null;
    notifyListeners();
  }
}
