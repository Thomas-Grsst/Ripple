enum ClockStyle {
  stacked('stacked', 'Empilé'),
  outline('outline', 'Contour'),
  column('column', 'Colonne'),
  classic('classic', 'Classique');

  const ClockStyle(this.id, this.label);

  final String id;
  final String label;

  static ClockStyle fromId(String? id) {
    return ClockStyle.values.firstWhere((ClockStyle style) => style.id == id, orElse: () => ClockStyle.stacked);
  }
}
