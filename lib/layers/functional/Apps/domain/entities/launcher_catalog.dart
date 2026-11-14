import 'package:equatable/equatable.dart';

import 'app_group.dart';
import 'launcher_entry.dart';

class LauncherGroup extends Equatable {
  const LauncherGroup({required this.group, required this.entries});

  final AppGroup group;
  final List<LauncherEntry> entries;

  @override
  List<Object?> get props => <Object?>[group, entries];
}

class LauncherCatalog extends Equatable {
  const LauncherCatalog({
    this.favorites = const <LauncherEntry>[],
    this.groups = const <LauncherGroup>[],
    this.visible = const <LauncherEntry>[],
    this.hidden = const <LauncherEntry>[],
    this.letterIndex = const <String, int>{},
  });

  final List<LauncherEntry> favorites;
  final List<LauncherGroup> groups;
  final List<LauncherEntry> visible;
  final List<LauncherEntry> hidden;
  final Map<String, int> letterIndex;

  List<String> get letters => letterIndex.keys.toList(growable: false);

  bool get isHomeEmpty => favorites.isEmpty && groups.isEmpty;

  @override
  List<Object?> get props => <Object?>[favorites, groups, visible, hidden, letterIndex];
}
