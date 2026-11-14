import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_customization.dart';
import '../../domain/entities/app_group.dart';
import '../../domain/gateways/app_customization_gateway.dart';

class PreferencesAppCustomizationGateway implements AppCustomizationGateway {
  const PreferencesAppCustomizationGateway(this._preferences);

  static const String _favoritesKey = 'apps.favorites';
  static const String _hiddenKey = 'apps.hidden';
  static const String _renamesKey = 'apps.renames';
  static const String _groupsKey = 'apps.groups';
  static const String _homeKey = 'apps.home';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppCustomization> load() async {
    final List<String> favorites = await _preferences.getStringList(_favoritesKey) ?? const <String>[];
    final List<String> hidden = await _preferences.getStringList(_hiddenKey) ?? const <String>[];
    final String? renamesJson = await _preferences.getString(_renamesKey);
    final String? groupsJson = await _preferences.getString(_groupsKey);
    return AppCustomization(
      favorites: List<String>.unmodifiable(favorites),
      hidden: Set<String>.unmodifiable(hidden),
      renames: Map<String, String>.unmodifiable(_decodeRenames(renamesJson)),
      groups: List<AppGroup>.unmodifiable(_decodeGroups(groupsJson)),
      homeApps: Set<String>.unmodifiable(await _preferences.getStringList(_homeKey) ?? const <String>[]),
    );
  }

  @override
  Future<void> save(AppCustomization customization) async {
    await _preferences.setStringList(_favoritesKey, customization.favorites);
    await _preferences.setStringList(_hiddenKey, customization.hidden.toList());
    await _preferences.setString(_renamesKey, jsonEncode(customization.renames));
    await _preferences.setString(_groupsKey, jsonEncode(customization.groups.map(_encodeGroup).toList()));
    await _preferences.setStringList(_homeKey, customization.homeApps.toList());
  }

  Map<String, Object?> _encodeGroup(AppGroup group) {
    return <String, Object?>{
      'id': group.id,
      'name': group.name,
      'packages': group.packages,
      'expanded': group.isExpanded,
    };
  }

  List<AppGroup> _decodeGroups(String? json) {
    if (json == null || json.isEmpty) {
      return const <AppGroup>[];
    }
    final Object? decoded = jsonDecode(json);
    if (decoded is! List<Object?>) {
      return const <AppGroup>[];
    }
    return <AppGroup>[
      for (final Object? item in decoded)
        if (item is Map<String, Object?> && item['id'] is String && item['name'] is String)
          AppGroup(
            id: item['id']! as String,
            name: item['name']! as String,
            packages: List<String>.unmodifiable(
              (item['packages'] is List<Object?> ? item['packages']! as List<Object?> : const <Object?>[]).whereType<String>(),
            ),
            isExpanded: item['expanded'] is bool ? item['expanded']! as bool : true,
          ),
    ];
  }

  Map<String, String> _decodeRenames(String? json) {
    if (json == null || json.isEmpty) {
      return const <String, String>{};
    }
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      return const <String, String>{};
    }
    return <String, String>{
      for (final MapEntry<String, Object?> entry in decoded.entries)
        if (entry.value is String) entry.key: entry.value! as String,
    };
  }
}
