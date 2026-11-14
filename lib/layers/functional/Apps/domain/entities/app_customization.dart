import 'package:equatable/equatable.dart';

class AppCustomization extends Equatable {
  const AppCustomization({
    this.favorites = const <String>[],
    this.hidden = const <String>{},
    this.renames = const <String, String>{},
  });

  final List<String> favorites;
  final Set<String> hidden;
  final Map<String, String> renames;

  bool isFavorite(String packageName) => favorites.contains(packageName);

  bool isHidden(String packageName) => hidden.contains(packageName);

  AppCustomization toggleFavorite(String packageName) {
    final List<String> next = List<String>.of(favorites);
    if (!next.remove(packageName)) {
      next.add(packageName);
    }
    return copyWith(favorites: List<String>.unmodifiable(next));
  }

  AppCustomization moveFavorite(int oldIndex, int newIndex) {
    final List<String> next = List<String>.of(favorites);
    final String moved = next.removeAt(oldIndex);
    next.insert(newIndex.clamp(0, next.length), moved);
    return copyWith(favorites: List<String>.unmodifiable(next));
  }

  AppCustomization hide(String packageName) {
    return copyWith(
      hidden: Set<String>.unmodifiable(<String>{...hidden, packageName}),
      favorites: List<String>.unmodifiable(favorites.where((String favorite) => favorite != packageName)),
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

  AppCustomization copyWith({List<String>? favorites, Set<String>? hidden, Map<String, String>? renames}) {
    return AppCustomization(
      favorites: favorites ?? this.favorites,
      hidden: hidden ?? this.hidden,
      renames: renames ?? this.renames,
    );
  }

  @override
  List<Object?> get props => <Object?>[favorites, hidden, renames];
}
