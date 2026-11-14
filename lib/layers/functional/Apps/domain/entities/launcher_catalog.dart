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
    this.home = const <LauncherEntry>[],
    this.homeLetterIndex = const <String, int>{},
    this.visible = const <LauncherEntry>[],
    this.hidden = const <LauncherEntry>[],
    this.letterIndex = const <String, int>{},
  });

  final List<LauncherEntry> favorites;
  final List<LauncherGroup> groups;
  final List<LauncherEntry> home;
  final Map<String, int> homeLetterIndex;
  final List<LauncherEntry> visible;
  final List<LauncherEntry> hidden;
  final Map<String, int> letterIndex;

  List<String> get letters => letterIndex.keys.toList(growable: false);

  List<String> get homeLetters => homeLetterIndex.keys.toList(growable: false);

  bool get isHomeEmpty => favorites.isEmpty && groups.isEmpty && home.isEmpty;

  @override
  List<Object?> get props => <Object?>[favorites, groups, home, homeLetterIndex, visible, hidden, letterIndex];
}
