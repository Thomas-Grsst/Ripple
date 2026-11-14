import 'package:equatable/equatable.dart';

enum GlanceItem {
  date('date'),
  battery('battery'),
  weather('weather');

  const GlanceItem(this.id);

  final String id;

  static GlanceItem? fromId(String id) {
    for (final GlanceItem item in GlanceItem.values) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}

class GlanceLayout extends Equatable {
  const GlanceLayout({required this.order, this.hidden = const <GlanceItem>{}});

  factory GlanceLayout.decode(String encoded) {
    final List<GlanceItem> order = <GlanceItem>[];
    final Set<GlanceItem> hidden = <GlanceItem>{};
    for (final String token in encoded.split(_separator)) {
      final bool isHidden = token.startsWith(_hiddenMarker);
      final GlanceItem? item = GlanceItem.fromId(isHidden ? token.substring(1) : token);
      if (item == null || order.contains(item)) {
        continue;
      }
      order.add(item);
      if (isHidden) {
        hidden.add(item);
      }
    }
    for (final GlanceItem item in GlanceItem.values) {
      if (!order.contains(item)) {
        order.add(item);
      }
    }
    return GlanceLayout(order: List<GlanceItem>.unmodifiable(order), hidden: Set<GlanceItem>.unmodifiable(hidden));
  }

  static const String defaultEncoded = 'date,battery,weather';
  static const String _separator = ',';
  static const String _hiddenMarker = '-';

  final List<GlanceItem> order;
  final Set<GlanceItem> hidden;

  List<GlanceItem> get visible => order.where((GlanceItem item) => !hidden.contains(item)).toList(growable: false);

  bool isVisible(GlanceItem item) => !hidden.contains(item);

  String encode() {
    return order.map((GlanceItem item) => hidden.contains(item) ? '$_hiddenMarker${item.id}' : item.id).join(_separator);
  }

  GlanceLayout move(int oldIndex, int newIndex) {
    final List<GlanceItem> reordered = List<GlanceItem>.of(order);
    final GlanceItem item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex.clamp(0, reordered.length), item);
    return GlanceLayout(order: List<GlanceItem>.unmodifiable(reordered), hidden: hidden);
  }

  GlanceLayout toggle(GlanceItem item) {
    final Set<GlanceItem> nextHidden = Set<GlanceItem>.of(hidden);
    if (!nextHidden.remove(item)) {
      nextHidden.add(item);
    }
    return GlanceLayout(order: order, hidden: Set<GlanceItem>.unmodifiable(nextHidden));
  }

  @override
  List<Object?> get props => <Object?>[order, hidden];
}
