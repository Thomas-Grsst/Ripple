enum RippleWallpaper {
  peaks('peaks', 'Sommets'),
  milkyWay('milkyway', 'Voie lactée'),
  ocean('ocean', 'Océan'),
  northernLights('northern', 'Aurore boréale'),
  dusk('dusk', 'Crépuscule'),
  ripple('ripple', 'Onde'),
  photo('photo', 'Ta photo'),
  system('system', 'Fond du téléphone'),
  black('black', 'Noir intégral');

  const RippleWallpaper(this.id, this.label);

  final String id;
  final String label;

  bool get usesSystemWallpaper => this == RippleWallpaper.system;

  bool get usesPhoto => this == RippleWallpaper.photo;

  static RippleWallpaper fromId(String? id) {
    return RippleWallpaper.values.firstWhere(
      (RippleWallpaper wallpaper) => wallpaper.id == id,
      orElse: () => RippleWallpaper.black,
    );
  }
}
