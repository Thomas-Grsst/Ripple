import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/weather_report.dart';

enum WeatherStatus { disabled, loading, ready, unavailable }

class WeatherState extends Equatable {
  const WeatherState({this.status = WeatherStatus.disabled, this.city = '', this.report});

  final WeatherStatus status;
  final String city;
  final WeatherReport? report;

  @override
  List<Object?> get props => <Object?>[status, city, report];
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._fetchCurrentWeather, {this.refreshInterval = const Duration(minutes: 30)}) : super(const WeatherState());

  final FetchCurrentWeather _fetchCurrentWeather;
  final Duration refreshInterval;
  Timer? _refreshTimer;

  Future<void> watchCity(String city) async {
    _refreshTimer?.cancel();
    final String trimmed = city.trim();
    if (trimmed.isEmpty) {
      emit(const WeatherState());
      return;
    }
    emit(WeatherState(status: WeatherStatus.loading, city: trimmed, report: state.city == trimmed ? state.report : null));
    _refreshTimer = Timer.periodic(refreshInterval, (_) => refresh());
    await refresh();
  }

  Future<void> refresh() async {
    final String city = state.city;
    if (city.isEmpty) {
      return;
    }
    try {
      final WeatherReport report = await _fetchCurrentWeather(city);
      if (state.city == city) {
        emit(WeatherState(status: WeatherStatus.ready, city: city, report: report));
      }
    } on WeatherUnavailableException {
      emit(WeatherState(status: WeatherStatus.unavailable, city: city, report: state.report));
    } on SocketException {
      emit(WeatherState(status: WeatherStatus.unavailable, city: city, report: state.report));
    } on TimeoutException {
      emit(WeatherState(status: WeatherStatus.unavailable, city: city, report: state.report));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
