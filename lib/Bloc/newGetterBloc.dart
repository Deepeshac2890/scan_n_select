import 'dart:async';

import 'package:scan_n_select/Services/api_manager.dart';
import 'package:scan_n_select/models/newsInfo.dart';

class NewsGetter {
  var eventStreamController = StreamController<String>();
  StreamSink<String> get eventSink => eventStreamController.sink;
  Stream<String> get eventStream => eventStreamController.stream;

  var newsStreamController = StreamController<List<Article>>();
  // This is sink which is receiving end of StreamController i.e Input
  StreamSink<List<Article>> get newsSink => newsStreamController.sink;
  // This is stream which is output end of StreamController
  Stream<List<Article>> get newsStream => newsStreamController.stream;
  var apiManager = API_Manager();
  NewsGetter() {
    eventStream.listen((event) async {
      // Here we listen for any changes.
      var news = await apiManager.getNews(event);
      newsSink.add(news.articles);
    });
  }

  void dispose() {
    eventStreamController.close();
    newsStreamController.close();
  }
}
