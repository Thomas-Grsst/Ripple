import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/launcher_settings.dart';

class LocalWallpaperPhotoGateway implements WallpaperPhotoGateway {
  const LocalWallpaperPhotoGateway();

  static const String _filePrefix = 'wallpaper_';

  @override
  Future<String?> pickAndStore() async {
    final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 3200, imageQuality: 92);
    if (picked == null) {
      return null;
    }
    final Directory directory = await getApplicationDocumentsDirectory();
    await _deletePreviousWallpapers(directory);
    final String extension = picked.path.contains('.') ? picked.path.substring(picked.path.lastIndexOf('.')) : '.jpg';
    final String target = '${directory.path}${Platform.pathSeparator}$_filePrefix${DateTime.now().millisecondsSinceEpoch}$extension';
    await File(picked.path).copy(target);
    return target;
  }

  Future<void> _deletePreviousWallpapers(Directory directory) async {
    await for (final FileSystemEntity entity in directory.list()) {
      final String name = entity.uri.pathSegments.isEmpty ? '' : entity.uri.pathSegments.last;
      if (entity is File && name.startsWith(_filePrefix)) {
        await entity.delete();
      }
    }
  }
}
