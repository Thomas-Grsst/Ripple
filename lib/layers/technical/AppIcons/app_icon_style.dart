enum AppIconStyle {
  monochrome('monochrome', 'Pictogrammes blancs'),
  accent('accent', 'Pictogrammes turquoise'),
  original('original', 'Icônes d\'origine'),
  none('none', 'Sans icône');

  const AppIconStyle(this.id, this.label);

  final String id;
  final String label;

  static AppIconStyle fromId(String? id) {
    return AppIconStyle.values.firstWhere(
      (AppIconStyle style) => style.id == id,
      orElse: () => AppIconStyle.monochrome,
    );
  }
}
