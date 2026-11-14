import 'package:equatable/equatable.dart';

import 'installed_app.dart';

class LauncherEntry extends Equatable {
  const LauncherEntry({
    required this.app,
    required this.displayName,
    required this.sortKey,
    required this.letter,
    required this.notificationCount,
    required this.isFavorite,
    required this.isHidden,
  });

  final InstalledApp app;
  final String displayName;
  final String sortKey;
  final String letter;
  final int notificationCount;
  final bool isFavorite;
  final bool isHidden;

  String get packageName => app.packageName;

  @override
  List<Object?> get props => <Object?>[app, displayName, letter, notificationCount, isFavorite, isHidden];
}
