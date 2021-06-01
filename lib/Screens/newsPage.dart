import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String gUrl;

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
  NewsPage(String url) {
    gUrl = url;
  }
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Card(
        child: WebView(
          initialUrl: gUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
