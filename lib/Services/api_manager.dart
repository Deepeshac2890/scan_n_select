import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scan_n_select/Constants.dart';
import 'package:scan_n_select/Keys.dart';
import 'package:scan_n_select/models/newsInfo.dart';

// ignore: camel_case_types
class API_Manager {
  Future<NewsModel> getNews(String cityName) async {
    var newsModel;

    try {
      var response;
      String url = newsApiStart + cityName + newsApiMiddle + newsApiKey;
      response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        newsModel = NewsModel.fromJson(jsonMap);
      }
    } catch (Exception) {
      return newsModel;
    }

    return newsModel;
  }
}
