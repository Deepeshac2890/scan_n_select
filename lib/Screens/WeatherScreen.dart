import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Keys.dart';

class WeatherScreen extends StatefulWidget {
  static String id = 'Weather_Screen';
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

// TODO: Change the gifs with something better
final homeScaffoldKey = GlobalKey<ScaffoldState>();
Position position;
String lat;
String long;
String tempo = "";
String tempMino = "";
String tempMaxo = "";
String cityName = "";
Image img = Image(
  image: AssetImage('assets/Weather/Cloudy.gif'),
);

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Text('Weather'),
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () async {
              // This button is for current location weather
              await getLocation();
            },
            child: Icon(Icons.location_pin),
          ),
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () {
              // This button is for city location weather
              _handlePressButton();
            },
            child: Icon(Icons.location_city),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: img.image, fit: BoxFit.fill),
        ),
        padding: EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            cityName,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            getNameOfDay(DateTime.now().weekday) +
                ', ' +
                DateTime.now().toString().substring(
                      0,
                      DateTime.now().toString().indexOf(' '),
                    ),
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            tempo + ' °C',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 80),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width * 0.8,
            color: Colors.blueAccent,
          ),
          Text(
            tempMino + ' °C ' + ' : ' + tempMaxo + ' °C',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30),
          ),
        ]),
      ),
    );
  }

  String getNameOfDay(int wd) {
    print(wd);
    switch (wd) {
      case 1:
        return 'Monday';
        break;
      case 2:
        return 'Tuesday';
        break;
      case 3:
        return 'Wednesday';
        break;
      case 4:
        return 'Thursday';
        break;
      case 5:
        return 'Friday';
        break;
      case 6:
        return 'Saturday';
        break;
      case 7:
        return 'Sunday';
        break;
    }
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "en",
    );

    displayPrediction(p, homeScaffoldKey.currentState);
  }

  Future<void> getLocation() async {
    try {
      position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      lat = position.latitude.toString();
      long = position.longitude.toString();
      final coordinates =
          await Coordinates(position.latitude, position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses[3];
      setState(() {
        cityName = first.featureName;
      });
      getWeather();
    } catch (e) {
      print(e);
    }
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final late = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      lat = late.toString();
      long = lng.toString();
      setState(() {
        cityName = p.description.substring(0, p.description.indexOf(','));
      });

      getWeather();
    }
  }

  Future<void> getWeather() async {
    String date = DateTime.now().toString().split(' ')[0];
    print(lat);
    print(long);
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$lat%2C$long/$date?unitGroup=metric&key=$weatherKey';
    http.Response repo = await http.get(url);
    var decodedData = jsonDecode(repo.body);
    if (repo.statusCode == 200) {
      // Everything went well
      if (decodedData != null) {
        var tempMax = decodedData['days'][0]['tempmax'];
        var tempMin = decodedData['days'][0]['tempmin'];
        var temp = decodedData['days'][0]['temp'];
        String conditions = decodedData['days'][0]['conditions'];
        String icon = decodedData['days'][0]['icon'];
        print(icon);
        if (icon.toLowerCase().contains('cloud')) {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Cloudy.gif'),
            );
          });
        } else if (icon.toLowerCase().contains('wind')) {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Windy.gif'),
            );
          });
        } else if (icon.toLowerCase().contains('sunny')) {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Sunny.jpg'),
            );
          });
        } else if (icon.toLowerCase().contains('snow')) {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Snow.gif'),
            );
          });
        } else if (icon.toLowerCase().contains('rain')) {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Rain.gif'),
            );
          });
        } else {
          setState(() {
            img = Image(
              image: AssetImage('assets/Weather/Sunny.jpg'),
            );
          });
        }
        setState(() {
          tempo = temp.toString();
          print(tempMin);
          print(tempMax);
          tempMino = tempMin.toString();
          tempMaxo = tempMax.toString();
        });
      }
    } else {
      Alert(context: context, title: 'Error Occurred While Fetching Data')
          .show();
    }
  }
}
