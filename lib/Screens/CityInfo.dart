import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Screens/MapInfo.dart';
import 'package:scan_n_select/Screens/NewsPaper.dart';
import 'package:scan_n_select/Screens/WeatherScreen.dart';

// TODO: Add the images in firebase storage for each PTV of city and display it here.

String cityName;

class CityInfo extends StatefulWidget {
  @override
  _CityInfoState createState() => _CityInfoState();
  CityInfo(String city) {
    cityName = city;
  }
}

class _CityInfoState extends State<CityInfo> {
  String et, lt, ptv, info, thr;
  List<TitleAndData> dataList = [];

  @override
  void initState() {
    getCityData();
    super.initState();
  }

  void getCityData() async {
    Firestore fs = Firestore.instance;
    var snaps = await fs.collection('Cities').document(cityName).get();
    var data = snaps.data;
    SplayTreeMap<String, dynamic> ordered = new SplayTreeMap();
    List<TitleAndData> dataLists = [];
    data.forEach((key, value) {
      ordered[key] = value;
    });
    ordered.forEach((key, value) {
      if (key == 'ET') {
        TitleAndData td = TitleAndData(
          title: 'How to Reach ? ',
          data: value,
        );
        dataLists.add(td);
      } else if (key == 'LT') {
        TitleAndData td = TitleAndData(
          title: 'Transports Available',
          data: value,
        );
        dataLists.add(td);
      } else if (key == 'THR') {
        TitleAndData td = TitleAndData(
          title: 'Famous Restaurants',
          data: value,
        );
        dataLists.add(td);
      } else if (key == 'About') {
        TitleAndData td = TitleAndData(
          title: 'About',
          data: value,
        );
        dataLists.add(td);
      }
    });
    setState(() {
      dataList = dataLists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'City Information',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageSlider(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cityName,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: Icon(Icons.map),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MapInfo(cityName);
                        }));
                      },
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return WeatherScreen(cityName);
                        }));
                      },
                      child: Icon(Icons.wb_cloudy),
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return NewsPaper(cityName);
                        }));
                      },
                      child: Icon(Icons.article),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 3,
              width: MediaQuery.of(context).size.width,
              color: Colors.blueAccent,
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: dataList,
              ),
            )
          ],
        ),
      ),
    );
  }

  Swiper imageSlider(context) {
    return new Swiper(
      autoplay: true,
      loop: true,
      itemBuilder: (BuildContext context, int index) {
        // if (urlList.length != 0) {
        //   return new Image.network(
        //     urlList[index],
        //     fit: BoxFit.fitHeight,
        //   );
        // } else {
        // TODO: Have to automate it Image.asset here just for trial
        return new Image.asset('assets/Background/Delhi.jpg');
      },
      itemCount: 5,
      viewportFraction: 0.9,
      scale: 0.9,
    );
  }
}

class TitleAndData extends StatelessWidget {
  final String title;
  final String data;
  TitleAndData({this.title, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          data,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
