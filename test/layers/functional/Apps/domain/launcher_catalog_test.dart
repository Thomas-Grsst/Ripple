import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/app_customization.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/app_group.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/installed_app.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/launcher_catalog.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/launcher_entry.dart';
import 'package:ripple/layers/functional/Apps/domain/use_cases/build_launcher_catalog.dart';
import 'package:ripple/layers/functional/Apps/domain/use_cases/search_launcher_entries.dart';

InstalledApp app(String packageName, String label) {
  return InstalledApp(packageName: packageName, label: label, icon: Uint8List(0));
}

void main() {
  final List<InstalledApp> apps = <InstalledApp>[
    app('com.music', 'Musique'),
    app('com.agenda', 'Agenda'),
    app('com.ecole', 'École directe'),
    app('com.nine', '9GAG'),
    app('com.messages', 'messages'),
    app('com.maps', 'Plans'),
  ];

  group('BuildLauncherCatalog', () {
    test('sorts apps alphabetically ignoring accents and case, digits last', () {
      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: const AppCustomization(),
        notificationCounts: const <String, int>{},
      );

      expect(
        catalog.visible.map((LauncherEntry entry) => entry.displayName),
        <String>['Agenda', 'École directe', 'messages', 'Musique', 'Plans', '9GAG'],
      );
      expect(catalog.letters, <String>['A', 'E', 'M', 'P', '#']);
      expect(catalog.letterIndex['M'], 2);
    });

    test('keeps favorites in the saved order and excludes hidden apps', () {
      final AppCustomization customization = const AppCustomization()
          .toggleFavorite('com.maps')
          .toggleFavorite('com.agenda')
          .toggleFavorite('com.music')
          .hide('com.music');

      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: customization,
        notificationCounts: const <String, int>{'com.agenda': 3},
      );

      expect(catalog.favorites.map((LauncherEntry entry) => entry.packageName), <String>['com.maps', 'com.agenda']);
      expect(catalog.favorites.last.notificationCount, 3);
      expect(catalog.visible.any((LauncherEntry entry) => entry.packageName == 'com.music'), isFalse);
      expect(catalog.hidden.single.packageName, 'com.music');
    });

    test('uses the custom name for sorting and display', () {
      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: const AppCustomization().rename('com.maps', 'Carte'),
        notificationCounts: const <String, int>{},
      );

      final LauncherEntry maps = catalog.visible.firstWhere((LauncherEntry entry) => entry.packageName == 'com.maps');
      expect(maps.displayName, 'Carte');
      expect(maps.letter, 'C');
    });
  });

  group('SearchLauncherEntries', () {
    final List<LauncherEntry> entries = const BuildLauncherCatalog()(
      apps: apps,
      customization: const AppCustomization(),
      notificationCounts: const <String, int>{},
    ).visible;

    test('ranks prefix matches before word and substring matches', () {
      final List<LauncherEntry> results = const SearchLauncherEntries()(entries, 'd');
      expect(results.map((LauncherEntry entry) => entry.displayName), <String>['École directe', 'Agenda']);
    });

    test('matches without accents', () {
      final List<LauncherEntry> results = const SearchLauncherEntries()(entries, 'ecol');
      expect(results.single.packageName, 'com.ecole');
    });

    test('returns nothing for a blank query', () {
      expect(const SearchLauncherEntries()(entries, '   '), isEmpty);
    });
  });

  group('Groups', () {
    test('groups list their visible apps in the saved order and skip hidden ones', () {
      final AppCustomization customization = const AppCustomization()
          .createGroup(id: 'xefi', name: ' XEFI ', packages: <String>['com.maps', 'com.agenda', 'com.music'])
          .hide('com.music');

      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: customization,
        notificationCounts: const <String, int>{},
      );

      final LauncherGroup xefi = catalog.groups.single;
      expect(xefi.group.name, 'XEFI');
      expect(xefi.entries.map((LauncherEntry entry) => entry.packageName), <String>['com.maps', 'com.agenda']);
      expect(customization.groups.single.contains('com.music'), isFalse);
    });

    test('an app can belong to several groups and be toggled out of one', () {
      final AppCustomization customization = const AppCustomization()
          .createGroup(id: 'a', name: 'Travail')
          .createGroup(id: 'b', name: 'XEFI')
          .toggleGroupMember('a', 'com.maps')
          .toggleGroupMember('b', 'com.maps')
          .toggleGroupMember('a', 'com.maps');

      expect(customization.groups[0].packages, isEmpty);
      expect(customization.groups[1].packages, <String>['com.maps']);
    });

    test('groups can be renamed, collapsed, reordered and deleted', () {
      final AppCustomization customization = const AppCustomization()
          .createGroup(id: 'a', name: 'Un')
          .createGroup(id: 'b', name: 'Deux')
          .renameGroup('a', 'Perso')
          .toggleGroupExpanded('b')
          .moveGroup(1, 0);

      expect(customization.groups.map((AppGroup group) => group.name), <String>['Deux', 'Perso']);
      expect(customization.groups.first.isExpanded, isFalse);
      expect(customization.deleteGroup('a').groups.single.id, 'b');
    });

    test('entriesForLetter returns only the visible apps of that letter', () {
      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: const AppCustomization().hide('com.music'),
        notificationCounts: const <String, int>{},
      );

      expect(catalog.entriesForLetter('M').map((LauncherEntry entry) => entry.packageName), <String>['com.messages']);
      expect(catalog.entriesForLetter('#').single.packageName, 'com.nine');
      expect(catalog.entriesForLetter('Z'), isEmpty);
    });

    test('the home is empty without favorites or groups', () {
      final LauncherCatalog catalog = const BuildLauncherCatalog()(
        apps: apps,
        customization: const AppCustomization(),
        notificationCounts: const <String, int>{},
      );
      expect(catalog.isHomeEmpty, isTrue);
    });
  });

  group('AppCustomization', () {
    test('moves a favorite to a new position', () {
      final AppCustomization customization = const AppCustomization(favorites: <String>['a', 'b', 'c']).moveFavorite(0, 2);
      expect(customization.favorites, <String>['b', 'c', 'a']);
    });

    test('renaming with a blank name restores the original label', () {
      final AppCustomization customization = const AppCustomization().rename('a', 'Custom').rename('a', '  ');
      expect(customization.renames, isEmpty);
    });

    test('unhide makes the app visible again', () {
      final AppCustomization customization = const AppCustomization().hide('a').unhide('a');
      expect(customization.isHidden('a'), isFalse);
    });
  });
}
