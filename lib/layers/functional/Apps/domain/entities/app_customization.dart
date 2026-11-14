import 'package:equatable/equatable.dart';

import 'app_group.dart';

class AppCustomization extends Equatable {
  const AppCustomization({
    this.favorites = const <String>[],
    this.hidden = const <String>{},
    this.renames = const <String, String>{},
    this.groups = const <AppGroup>[],
    this.homeApps = const <String>{},
  });

  final Set<String> homeApps;
  final List<String> favorites;
  final Set<String> hidden;
  final Map<String, String> renames;
  final List<AppGroup> groups;

  bool isFavorite(String packageName) => favorites.contains(packageName);

  bool isHidden(String packageName) => hidden.contains(packageName);

  bool isOnHome(String packageName) => homeApps.contains(packageName);

  AppCustomization toggleHome(String packageName) {
    final Set<String> next = Set<String>.of(homeApps);
    if (!next.remove(packageName)) {
      next.add(packageName);
    }
    return copyWith(homeApps: Set<String>.unmodifiable(next));
  }

  AppCustomization toggleFavorite(String packageName) {
    final List<String> next = List<String>.of(favorites);
    if (!next.remove(packageName)) {
      next.add(packageName);
    }
    return copyWith(favorites: List<String>.unmodifiable(next));
  }

  AppCustomization moveFavorite(int oldIndex, int newIndex) {
    return copyWith(favorites: _move(favorites, oldIndex, newIndex));
  }

  AppCustomization hide(String packageName) {
    return copyWith(
      hidden: Set<String>.unmodifiable(<String>{...hidden, packageName}),
      favorites: List<String>.unmodifiable(favorites.where((String favorite) => favorite != packageName)),
      homeApps: Set<String>.unmodifiable(homeApps.where((String item) => item != packageName).toSet()),
      groups: List<AppGroup>.unmodifiable(
        groups.map((AppGroup group) => group.contains(packageName) ? group.toggleMember(packageName) : group),
      ),
    );
  }

  AppCustomization unhide(String packageName) {
    return copyWith(hidden: Set<String>.unmodifiable(hidden.where((String item) => item != packageName).toSet()));
  }

  AppCustomization rename(String packageName, String name) {
    final Map<String, String> next = Map<String, String>.of(renames);
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      next.remove(packageName);
    } else {
      next[packageName] = trimmed;
    }
    return copyWith(renames: Map<String, String>.unmodifiable(next));
  }

  AppCustomization createGroup({required String id, required String name, List<String> packages = const <String>[]}) {
    final AppGroup group = AppGroup(id: id, name: name.trim(), packages: List<String>.unmodifiable(packages));
    return copyWith(groups: List<AppGroup>.unmodifiable(<AppGroup>[...groups, group]));
  }

  AppCustomization renameGroup(String groupId, String name) {
    return _updateGroup(groupId, (AppGroup group) => group.copyWith(name: name.trim()));
  }

  AppCustomization deleteGroup(String groupId) {
    return copyWith(groups: List<AppGroup>.unmodifiable(groups.where((AppGroup group) => group.id != groupId)));
  }

  AppCustomization toggleGroupMember(String groupId, String packageName) {
    return _updateGroup(groupId, (AppGroup group) => group.toggleMember(packageName));
  }

  AppCustomization toggleGroupExpanded(String groupId) {
    return _updateGroup(groupId, (AppGroup group) => group.copyWith(isExpanded: !group.isExpanded));
  }

  AppCustomization moveGroup(int oldIndex, int newIndex) => copyWith(groups: _move(groups, oldIndex, newIndex));

  AppCustomization copyWith({
    List<String>? favorites,
    Set<String>? hidden,
    Map<String, String>? renames,
    List<AppGroup>? groups,
    Set<String>? homeApps,
  }) {
    return AppCustomization(
      favorites: favorites ?? this.favorites,
      hidden: hidden ?? this.hidden,
      renames: renames ?? this.renames,
      groups: groups ?? this.groups,
      homeApps: homeApps ?? this.homeApps,
    );
  }

  AppCustomization _updateGroup(String groupId, AppGroup Function(AppGroup group) update) {
    return copyWith(
      groups: List<AppGroup>.unmodifiable(groups.map((AppGroup group) => group.id == groupId ? update(group) : group)),
    );
  }

  static List<T> _move<T>(List<T> items, int oldIndex, int newIndex) {
    final List<T> next = List<T>.of(items);
    final T moved = next.removeAt(oldIndex);
    next.insert(newIndex.clamp(0, next.length), moved);
    return List<T>.unmodifiable(next);
  }

  @override
  List<Object?> get props => <Object?>[favorites, hidden, renames, groups, homeApps];
}
