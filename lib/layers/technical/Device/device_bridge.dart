import 'package:flutter/services.dart';

sealed class DeviceEvent {
  const DeviceEvent();
}

final class HomePressedEvent extends DeviceEvent {
  const HomePressedEvent();
}

final class PackagesChangedEvent extends DeviceEvent {
  const PackagesChangedEvent();
}

final class NotificationCountsEvent extends DeviceEvent {
  const NotificationCountsEvent(this.counts);

  final Map<String, int> counts;
}

final class UnknownDeviceEvent extends DeviceEvent {
  const UnknownDeviceEvent();
}

class DeviceBridge {
  DeviceBridge({
    this._methods = const MethodChannel('ripple/device'),
    this._events = const EventChannel('ripple/device_events'),
  });

  final MethodChannel _methods;
  final EventChannel _events;

  late final Stream<DeviceEvent> events = _events.receiveBroadcastStream().map(_parseEvent).asBroadcastStream();

  Future<List<Map<Object?, Object?>>> getApps({required int iconSize}) async {
    final List<Object?>? raw = await _methods.invokeListMethod<Object?>('getApps', <String, Object>{'iconSize': iconSize});
    return (raw ?? <Object?>[]).whereType<Map<Object?, Object?>>().toList(growable: false);
  }

  Future<bool> launch(String packageName) async {
    return await _methods.invokeMethod<bool>('launch', <String, Object>{'package': packageName}) ?? false;
  }

  Future<void> openAppInfo(String packageName) {
    return _methods.invokeMethod<void>('openAppInfo', <String, Object>{'package': packageName});
  }

  Future<void> uninstall(String packageName) {
    return _methods.invokeMethod<void>('uninstall', <String, Object>{'package': packageName});
  }

  Future<bool> isDefaultLauncher() async => await _methods.invokeMethod<bool>('isDefaultLauncher') ?? false;

  Future<void> requestDefaultLauncher() => _methods.invokeMethod<void>('requestDefaultLauncher');

  Future<bool> hasNotificationAccess() async => await _methods.invokeMethod<bool>('hasNotificationAccess') ?? false;

  Future<void> openNotificationAccess() => _methods.invokeMethod<void>('openNotificationAccess');

  Future<void> expandNotifications() => _methods.invokeMethod<void>('expandNotifications');

  Future<void> openWallpaperPicker() => _methods.invokeMethod<void>('openWallpaperPicker');

  DeviceEvent _parseEvent(Object? raw) {
    if (raw is! Map<Object?, Object?>) {
      return const UnknownDeviceEvent();
    }
    return switch (raw['type']) {
      'home' => const HomePressedEvent(),
      'packagesChanged' => const PackagesChangedEvent(),
      'notifications' => NotificationCountsEvent(_parseCounts(raw['counts'])),
      _ => const UnknownDeviceEvent(),
    };
  }

  Map<String, int> _parseCounts(Object? raw) {
    if (raw is! Map<Object?, Object?>) {
      return const <String, int>{};
    }
    return <String, int>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        if (entry.key is String && entry.value is int) entry.key! as String: entry.value! as int,
    };
  }
}
