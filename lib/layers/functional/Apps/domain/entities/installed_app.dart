import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class InstalledApp extends Equatable {
  const InstalledApp({required this.packageName, required this.label, required this.icon});

  final String packageName;
  final String label;
  final Uint8List icon;

  @override
  List<Object?> get props => <Object?>[packageName, label];
}
