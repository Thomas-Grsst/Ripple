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

  List<LauncherEntry> entriesForLetter(String letter) {
    final int? start = letterIndex[letter];
    if (start == null) {
      return const <LauncherEntry>[];
    }
    return visible.skip(start).takeWhile((LauncherEntry entry) => entry.letter == letter).toList(growable: false);
  }

  LauncherGroup? groupById(String groupId) {
    for (final LauncherGroup group in groups) {
      if (group.group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[favorites, groups, visible, hidden, letterIndex];
}
