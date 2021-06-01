import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Keys.dart';

class WeatherService {
  Future<dynamic> getWeather(String lat, String long) async {
    String date = DateTime.now().toString().split(' ')[0];
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$lat%2C$long/$date?unitGroup=metric&key=$weatherKey';
    http.Response repo = await http.get(url);
    return jsonDecode(repo.body);
  }
}
