sealed class LauncherDeviceEvent {
  const LauncherDeviceEvent();
}

final class HomeRequested extends LauncherDeviceEvent {
  const HomeRequested();
}

final class InstalledAppsChanged extends LauncherDeviceEvent {
  const InstalledAppsChanged();
}

final class NotificationCountsUpdated extends LauncherDeviceEvent {
  const NotificationCountsUpdated(this.counts);

  final Map<String, int> counts;
}
