import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scan_n_select/Bloc/newGetterBloc.dart';
import 'package:scan_n_select/Screens/newsPage.dart';

String cityName;

class NewsPaper extends StatefulWidget {
  NewsPaper(String cn) {
    cityName = cn;
  }

  @override
  _NewsPaperState createState() => _NewsPaperState();
}

class _NewsPaperState extends State<NewsPaper> {
  var ng = NewsGetter();
  @override
  void initState() {
    ng.eventSink.add(cityName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('City News'),
        ),
      ),
      body: StreamBuilder(
          stream: ng.newsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString() + ' Occurred'),
              );
            }
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var article = snapshot.data[index];
                    var formattedTime = DateFormat('dd MMM - HH:mm')
                        .format(article.publishedAt);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NewsPage(article.url);
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
                        margin: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  article.urlToImage != null
                                      ? article.urlToImage
                                      : 'https://discountseries.com/wp-content/uploads/2017/09/default.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(formattedTime),
                                  Text(
                                    article.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    article.description != null
                                        ? article.description
                                        : 'N.A',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            } else
              return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
