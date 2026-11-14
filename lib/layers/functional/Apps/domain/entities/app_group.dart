import 'package:equatable/equatable.dart';

class AppGroup extends Equatable {
  const AppGroup({
    required this.id,
    required this.name,
    this.packages = const <String>[],
    this.isExpanded = true,
  });

  final String id;
  final String name;
  final List<String> packages;
  final bool isExpanded;

  bool contains(String packageName) => packages.contains(packageName);

  AppGroup toggleMember(String packageName) {
    final List<String> next = List<String>.of(packages);
    if (!next.remove(packageName)) {
      next.add(packageName);
    }
    return copyWith(packages: List<String>.unmodifiable(next));
  }

  AppGroup copyWith({String? name, List<String>? packages, bool? isExpanded}) {
    return AppGroup(
      id: id,
      name: name ?? this.name,
      packages: packages ?? this.packages,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, packages, isExpanded];
}
