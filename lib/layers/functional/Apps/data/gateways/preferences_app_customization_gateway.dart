import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_customization.dart';
import '../../domain/gateways/app_customization_gateway.dart';

class PreferencesAppCustomizationGateway implements AppCustomizationGateway {
  const PreferencesAppCustomizationGateway(this._preferences);

  static const String _favoritesKey = 'apps.favorites';
  static const String _hiddenKey = 'apps.hidden';
  static const String _renamesKey = 'apps.renames';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppCustomization> load() async {
    final List<String> favorites = await _preferences.getStringList(_favoritesKey) ?? const <String>[];
    final List<String> hidden = await _preferences.getStringList(_hiddenKey) ?? const <String>[];
    final String? renamesJson = await _preferences.getString(_renamesKey);
    return AppCustomization(
      favorites: List<String>.unmodifiable(favorites),
      hidden: Set<String>.unmodifiable(hidden),
      renames: Map<String, String>.unmodifiable(_decodeRenames(renamesJson)),
    );
  }

  @override
  Future<void> save(AppCustomization customization) async {
    await _preferences.setStringList(_favoritesKey, customization.favorites);
    await _preferences.setStringList(_hiddenKey, customization.hidden.toList());
    await _preferences.setString(_renamesKey, jsonEncode(customization.renames));
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
