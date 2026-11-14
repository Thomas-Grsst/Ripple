import 'package:equatable/equatable.dart';

enum WeatherCondition { clear, partlyCloudy, cloudy, fog, drizzle, rain, snow, showers, storm }

class WeatherReport extends Equatable {
  const WeatherReport({required this.city, required this.temperature, required this.condition});

  final String city;
  final double temperature;
  final WeatherCondition condition;

  static WeatherCondition conditionFromWmoCode(int code) {
    return switch (code) {
      0 => WeatherCondition.clear,
      1 || 2 => WeatherCondition.partlyCloudy,
      3 => WeatherCondition.cloudy,
      45 || 48 => WeatherCondition.fog,
      >= 51 && <= 57 => WeatherCondition.drizzle,
      >= 61 && <= 67 => WeatherCondition.rain,
      >= 71 && <= 77 => WeatherCondition.snow,
      >= 80 && <= 86 => WeatherCondition.showers,
      >= 95 => WeatherCondition.storm,
      _ => WeatherCondition.cloudy,
    };
  }

  @override
  List<Object?> get props => <Object?>[city, temperature, condition];
}

class WeatherUnavailableException implements Exception {
  const WeatherUnavailableException(this.reason);

  final String reason;

  @override
  String toString() => 'WeatherUnavailableException: $reason';
}

abstract interface class WeatherGateway {
  Future<WeatherReport> fetchCurrent(String city);
}

class FetchCurrentWeather {
  const FetchCurrentWeather(this._gateway);

  final WeatherGateway _gateway;

  Future<WeatherReport> call(String city) => _gateway.fetchCurrent(city);
}
