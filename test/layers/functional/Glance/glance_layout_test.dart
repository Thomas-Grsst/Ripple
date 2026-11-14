import 'package:flutter_test/flutter_test.dart';
import 'package:ripple/layers/functional/Glance/domain/glance_layout.dart';

void main() {
  test('default layout shows date, battery then weather', () {
    final GlanceLayout layout = GlanceLayout.decode(GlanceLayout.defaultEncoded);
    expect(layout.visible, <GlanceItem>[GlanceItem.date, GlanceItem.battery, GlanceItem.weather]);
  });

  test('moving and hiding items survives an encode round trip', () {
    final GlanceLayout layout = GlanceLayout.decode(GlanceLayout.defaultEncoded).move(2, 0).toggle(GlanceItem.battery);
    expect(layout.encode(), 'weather,date,-battery');
    final GlanceLayout restored = GlanceLayout.decode(layout.encode());
    expect(restored, layout);
    expect(restored.visible, <GlanceItem>[GlanceItem.weather, GlanceItem.date]);
  });

  test('unknown or missing ids are ignored and completed', () {
    final GlanceLayout layout = GlanceLayout.decode('battery,bogus,battery');
    expect(layout.order, <GlanceItem>[GlanceItem.battery, GlanceItem.date, GlanceItem.weather]);
  });
}
