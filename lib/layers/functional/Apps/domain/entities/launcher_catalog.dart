import 'package:equatable/equatable.dart';

import 'launcher_entry.dart';

class LauncherCatalog extends Equatable {
  const LauncherCatalog({
    this.favorites = const <LauncherEntry>[],
    this.visible = const <LauncherEntry>[],
    this.hidden = const <LauncherEntry>[],
    this.letterIndex = const <String, int>{},
  });

  final List<LauncherEntry> favorites;
  final List<LauncherEntry> visible;
  final List<LauncherEntry> hidden;
  final Map<String, int> letterIndex;

  List<String> get letters => letterIndex.keys.toList(growable: false);

  @override
  List<Object?> get props => <Object?>[favorites, visible, hidden, letterIndex];
}
