import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class InstalledApp extends Equatable {
  const InstalledApp({required this.packageName, required this.label, required this.icon, this.monochromeIcon});

  final String packageName;
  final String label;
  final Uint8List icon;
  final Uint8List? monochromeIcon;

  @override
  List<Object?> get props => <Object?>[packageName, label];
}
