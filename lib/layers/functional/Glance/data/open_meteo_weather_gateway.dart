import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/weather_report.dart';

class OpenMeteoWeatherGateway implements WeatherGateway {
  OpenMeteoWeatherGateway(this._client);

  final http.Client _client;
  final Map<String, ({double latitude, double longitude, String name})> _geocodeCache =
      <String, ({double latitude, double longitude, String name})>{};

  @override
  Future<WeatherReport> fetchCurrent(String city) async {
    final ({double latitude, double longitude, String name}) place = await _geocode(city);
    final Uri uri = Uri.https('api.open-meteo.com', '/v1/forecast', <String, String>{
      'latitude': '${place.latitude}',
      'longitude': '${place.longitude}',
      'current': 'temperature_2m,weather_code',
      'timezone': 'auto',
    });
    final Map<String, Object?> body = await _getJson(uri);
    final Object? current = body['current'];
    if (current is! Map<String, Object?>) {
      throw const WeatherUnavailableException('missing current weather');
    }
    final Object? temperature = current['temperature_2m'];
    final Object? code = current['weather_code'];
    if (temperature is! num || code is! num) {
      throw const WeatherUnavailableException('malformed current weather');
    }
    return WeatherReport(
      city: place.name,
      temperature: temperature.toDouble(),
      condition: WeatherReport.conditionFromWmoCode(code.toInt()),
    );
  }

  Future<({double latitude, double longitude, String name})> _geocode(String city) async {
    final String key = city.trim().toLowerCase();
    final ({double latitude, double longitude, String name})? cached = _geocodeCache[key];
    if (cached != null) {
      return cached;
    }
    final Uri uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', <String, String>{
      'name': city.trim(),
      'count': '1',
      'language': 'fr',
      'format': 'json',
    });
    final Map<String, Object?> body = await _getJson(uri);
    final Object? results = body['results'];
    if (results is! List<Object?> || results.isEmpty || results.first is! Map<String, Object?>) {
      throw WeatherUnavailableException('unknown city $city');
    }
    final Map<String, Object?> first = results.first! as Map<String, Object?>;
    final Object? latitude = first['latitude'];
    final Object? longitude = first['longitude'];
    final Object? name = first['name'];
    if (latitude is! num || longitude is! num) {
      throw WeatherUnavailableException('no coordinates for $city');
    }
    final ({double latitude, double longitude, String name}) place = (
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      name: name is String ? name : city,
    );
    _geocodeCache[key] = place;
    return place;
  }

  Future<Map<String, Object?>> _getJson(Uri uri) async {
    final http.Response response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw WeatherUnavailableException('HTTP ${response.statusCode}');
    }
    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const WeatherUnavailableException('unexpected payload');
    }
    return decoded;
  }
}
