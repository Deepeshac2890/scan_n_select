import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:scan_n_select/Keys.dart';
import 'package:scan_n_select/Services/location_service.dart';
import 'package:scan_n_select/Services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  static String id = 'Weather_Screen';
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
  WeatherScreen(String name) {
    city = name;
  }
}

// TODO: Change the gifs with something better
final homeScaffoldKey = GlobalKey<ScaffoldState>();
String lat;
String long;
String tempo = "";
String tempMino = "";
String tempMaxo = "";
String cityName = "";
String condition = "";
String city;
LocationService locationService = LocationService();
WeatherService ws = WeatherService();
var color = Colors.deepPurple;
Image img = Image(
  image: AssetImage('assets/Weather/Cloudy.png'),
);

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    if (city != null)
      getCityWeather();
    else
      getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Center(child: Text('Weather')),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blueGrey),
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
        color: color,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Center(
                child: Text(
                  cityName,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                DateTime.now().toLocal().toString().split(' ')[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: img,
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Text(
                                  '$tempo°',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'max: $tempMaxo°',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'min: $tempMino°',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        condition,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      var ps = await locationService.getCurrentLocation();
      lat = ps.latitude.toString();
      long = ps.longitude.toString();
      final coordinates = Coordinates(ps.latitude, ps.longitude);
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

  void getCityWeather() async {
    var ps = await locationService.getCityLatLng(city);
    lat = ps.latitude.toString();
    long = ps.longitude.toString();
    setState(() {
      cityName = city;
    });
    getWeather();
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
    var decodedData = await ws.getWeather(lat, long);
    if (decodedData != null) {
      var tempMax = decodedData['days'][0]['tempmax'];
      var tempMin = decodedData['days'][0]['tempmin'];
      var temp = decodedData['days'][0]['temp'];
      String conditions = decodedData['days'][0]['conditions'];
      String icon = decodedData['days'][0]['icon'];
      if (icon.toLowerCase().contains('cloud')) {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Cloudy.png'),
          );
          color = Colors.deepPurple;
        });
      } else if (icon.toLowerCase().contains('wind')) {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Windy.gif'),
          );
          color = Colors.lightBlue;
        });
      } else if (icon.toLowerCase().contains('sunny')) {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Sunny.png'),
          );
          color = Colors.orange;
        });
      } else if (icon.toLowerCase().contains('snow')) {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Snow.png'),
          );
          color = Colors.deepOrange;
        });
      } else if (icon.toLowerCase().contains('rain')) {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Rainy.png'),
          );
          color = Colors.blue;
        });
      } else {
        setState(() {
          img = Image(
            image: AssetImage('assets/Weather/Sunny.png'),
          );
          color = Colors.orange;
        });
      }
      setState(() {
        tempo = temp.toString();
        tempMino = tempMin.toString();
        tempMaxo = tempMax.toString();
        condition = conditions;
      });
    }
  }
}
