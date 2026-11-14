import '../entities/app_customization.dart';
import '../entities/app_group.dart';
import '../entities/installed_app.dart';
import '../entities/label_normalizer.dart';
import '../entities/launcher_catalog.dart';
import '../entities/launcher_entry.dart';

class BuildLauncherCatalog {
  const BuildLauncherCatalog();

  LauncherCatalog call({
    required List<InstalledApp> apps,
    required AppCustomization customization,
    required Map<String, int> notificationCounts,
  }) {
    final List<LauncherEntry> entries = apps
        .map((InstalledApp app) => _toEntry(app, customization, notificationCounts))
        .toList()
      ..sort(_compareEntries);

    final Map<String, LauncherEntry> byPackage = <String, LauncherEntry>{
      for (final LauncherEntry entry in entries) entry.packageName: entry,
    };
    final List<LauncherEntry> favorites = customization.favorites
        .map((String packageName) => byPackage[packageName])
        .whereType<LauncherEntry>()
        .where((LauncherEntry entry) => !entry.isHidden)
        .toList(growable: false);
    final List<LauncherEntry> visible = entries.where((LauncherEntry entry) => !entry.isHidden).toList(growable: false);
    final List<LauncherEntry> hidden = entries.where((LauncherEntry entry) => entry.isHidden).toList(growable: false);

    final List<LauncherGroup> groups = customization.groups
        .map(
          (AppGroup group) => LauncherGroup(
            group: group,
            entries: group.packages
                .map((String packageName) => byPackage[packageName])
                .whereType<LauncherEntry>()
                .where((LauncherEntry entry) => !entry.isHidden)
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return LauncherCatalog(
      favorites: favorites,
      groups: groups,
      visible: visible,
      hidden: hidden,
      letterIndex: _indexLetters(visible),
    );
  }

  LauncherEntry _toEntry(InstalledApp app, AppCustomization customization, Map<String, int> notificationCounts) {
    final String displayName = customization.renames[app.packageName] ?? app.label;
    final String sortKey = LabelNormalizer.normalize(displayName);
    return LauncherEntry(
      app: app,
      displayName: displayName,
      sortKey: sortKey,
      letter: LabelNormalizer.letterOf(sortKey),
      notificationCount: notificationCounts[app.packageName] ?? 0,
      isFavorite: customization.isFavorite(app.packageName),
      isHidden: customization.isHidden(app.packageName),
    );
  }

  int _compareEntries(LauncherEntry left, LauncherEntry right) {
    final bool leftIsOther = left.letter == LabelNormalizer.otherLetter;
    final bool rightIsOther = right.letter == LabelNormalizer.otherLetter;
    if (leftIsOther != rightIsOther) {
      return leftIsOther ? 1 : -1;
    }
    return left.sortKey.compareTo(right.sortKey);
  }

  Map<String, int> _indexLetters(List<LauncherEntry> visible) {
    final Map<String, int> index = <String, int>{};
    for (int position = 0; position < visible.length; position++) {
      index.putIfAbsent(visible[position].letter, () => position);
    }
    return Map<String, int>.unmodifiable(index);
  }
}
