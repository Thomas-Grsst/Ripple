enum RippleWallpaper {
  black('black', 'Noir intégral'),
  system('system', 'Fond du téléphone'),
  ripple('ripple', 'Onde'),
  aurora('aurora', 'Aurore'),
  dunes('dunes', 'Dunes'),
  tide('tide', 'Marée'),
  dusk('dusk', 'Crépuscule'),
  constellation('constellation', 'Constellation');

  const RippleWallpaper(this.id, this.label);

  final String id;
  final String label;

  bool get usesSystemWallpaper => this == RippleWallpaper.system;

  static RippleWallpaper fromId(String? id) {
    return RippleWallpaper.values.firstWhere(
      (RippleWallpaper wallpaper) => wallpaper.id == id,
      orElse: () => RippleWallpaper.black,
    );
  }
}
