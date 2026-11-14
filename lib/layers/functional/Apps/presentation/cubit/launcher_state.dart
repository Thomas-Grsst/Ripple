import 'package:equatable/equatable.dart';

import '../../domain/entities/app_customization.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';

enum LauncherStatus { loading, ready, failure }

sealed class HomeFilter extends Equatable {
  const HomeFilter();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FavoritesFilter extends HomeFilter {
  const FavoritesFilter();
}

final class LetterFilter extends HomeFilter {
  const LetterFilter(this.letter);

  final String letter;

  @override
  List<Object?> get props => <Object?>[letter];
}

final class GroupFilter extends HomeFilter {
  const GroupFilter(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => <Object?>[groupId];
}

class LauncherState extends Equatable {
  const LauncherState({
    this.status = LauncherStatus.loading,
    this.apps = const <InstalledApp>[],
    this.customization = const AppCustomization(),
    this.notificationCounts = const <String, int>{},
    this.catalog = const LauncherCatalog(),
    this.query = '',
    this.searchResults = const <LauncherEntry>[],
    this.homeRequests = 0,
    this.launchFailures = 0,
    this.homeFilter = const FavoritesFilter(),
  });

  final LauncherStatus status;
  final List<InstalledApp> apps;
  final AppCustomization customization;
  final Map<String, int> notificationCounts;
  final LauncherCatalog catalog;
  final String query;
  final List<LauncherEntry> searchResults;
  final int homeRequests;
  final int launchFailures;
  final HomeFilter homeFilter;

  bool get isSearching => query.trim().isNotEmpty;

  LauncherState copyWith({
    LauncherStatus? status,
    List<InstalledApp>? apps,
    AppCustomization? customization,
    Map<String, int>? notificationCounts,
    LauncherCatalog? catalog,
    String? query,
    List<LauncherEntry>? searchResults,
    int? homeRequests,
    int? launchFailures,
    HomeFilter? homeFilter,
  }) {
    return LauncherState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      customization: customization ?? this.customization,
      notificationCounts: notificationCounts ?? this.notificationCounts,
      catalog: catalog ?? this.catalog,
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      homeRequests: homeRequests ?? this.homeRequests,
      launchFailures: launchFailures ?? this.launchFailures,
      homeFilter: homeFilter ?? this.homeFilter,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        apps,
        customization,
        notificationCounts,
        catalog,
        query,
        searchResults,
        homeRequests,
        launchFailures,
        homeFilter,
      ];
}
