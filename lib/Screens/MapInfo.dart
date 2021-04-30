import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as lc;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Keys.dart';

// TODO: Add Information for PTV when clicked on marker.
// TODO: Create an local Notification for location reach.

String cityName = '';

class MapInfo extends StatefulWidget {
  static String id = 'CityInfo_Screen';

  MapInfo(String city) {
    cityName = city;
  }

  @override
  _MapInfoState createState() => _MapInfoState();
}

class _MapInfoState extends State<MapInfo> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> controllers = Completer();
  static LatLng center = LatLng(71.521563, 30.677433);
  final Set<Marker> markers = {};
  LatLng source = center;
  LatLng lastMapPosition = center;
  MapType currentMapType = MapType.normal;
  Firestore fs = Firestore.instance;
  bool markersVisible = false;
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;
  BuildContext ctx;
  List<String> place = [];
  List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];
  String selectedSource = '';
  int dirType = 0;
  String selectedDestination = '';
  LatLng sourceLatLng;
  StreamSubscription<lc.LocationData> lco;
  final player = AudioCache();

  @override
  void initState() {
    getCityLatitude();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Center(child: Text(cityName)),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: center, zoom: 11),
            mapType: currentMapType,
            markers: markers,
            polylines: polyLines,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            compassEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  button(_onMapTypeButtonPressed, Icons.map, 'Map Type'),
                  SizedBox(
                    height: 16,
                  ),
                  button(
                      cityViewer, Icons.location_city, 'Destination City View'),
                  SizedBox(
                    height: 16,
                  ),
                  button(myLocation, Icons.my_location, 'Current Location'),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  button(
                      dirBetween, Icons.directions, 'Direction Between Places'),
                  SizedBox(
                    height: 16,
                  ),
                  button(
                      setMarkers, Icons.pin_drop, 'Show/Hide Places to Visit'),
                  SizedBox(
                    height: 16,
                  ),
                  button(fromCurrent, Icons.directions_outlined,
                      'Direction from Current Location'),
                  SizedBox(
                    height: 16,
                  ),
                  button(reminder, Icons.alarm, 'Remind Me at Location'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void dragDownRegister() {
    ls = [];
    for (String locationName in place) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(locationName),
        value: locationName,
      );
      ls.add(dm);
    }
  }

  DropdownButton<String> getAndroidPickerSource() {
    return DropdownButton<String>(
      value: selectedSource,
      onChanged: (value) {
        setState(() {
          selectedSource = value;
        });
        Navigator.pop(ctx);
        selectSource();
      },
      items: ls,
    );
  }

  CupertinoPicker getIOSPickerSource() {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedSource = place[value];
        });
      },
      children: ls,
    );
  }

  Widget getPickerSource() {
    if (Platform.isIOS)
      return getIOSPickerSource();
    else
      return getAndroidPickerSource();
  }

  DropdownButton<String> getAndroidPickerDestination() {
    return DropdownButton<String>(
      value: selectedDestination,
      onChanged: (value) {
        setState(() {
          selectedDestination = value;
        });
        Navigator.pop(ctx);
        selectDestination();
      },
      items: ls,
    );
  }

  CupertinoPicker getIOSPickerDestination() {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedDestination = place[value];
        });
      },
      children: ls,
    );
  }

  Widget getPickerDestination() {
    if (Platform.isIOS)
      return getIOSPickerDestination();
    else
      return getAndroidPickerDestination();
  }

  Widget button(Function fn, IconData icon, String message) {
    return Tooltip(
      message: message,
      child: FloatingActionButton(
        onPressed: fn,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.lightBlue,
        child: Icon(icon),
      ),
    );
  }

  _onMapCreated(GoogleMapController controller) async {
    // This is done to set the view to Destination City
    getCityLatitude();
    await controller.moveCamera(CameraUpdate.newLatLng(center));
    controllers.complete(controller);
    cityViewer();
  }

  void setPlacesMarker(String area) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(area + ',' + cityName);
    LatLng mSet =
        LatLng(placemark[0].position.latitude, placemark[0].position.longitude);
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(placemark[0].position.toString()),
          position: mSet,
          infoWindow: InfoWindow(
            title: area,
            snippet: 'This is a Place to Visit',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    });
  }

  _onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  Future<void> selectSource() async {
    if (dirType == 0) {
      Alert(
          context: ctx,
          title: "Select Source",
          content: getPickerSource(),
          buttons: [
            DialogButton(
              onPressed: () async {
                List<Placemark> placemark = await Geolocator()
                    .placemarkFromAddress(selectedSource + ',' + cityName);
                LatLng mSet = LatLng(placemark[0].position.latitude,
                    placemark[0].position.longitude);
                sendRequest(await getCurrentLocation(), mSet);
                Navigator.pop(ctx);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    } else {
      Alert(
          context: ctx,
          title: "Select Source",
          content: getPickerSource(),
          buttons: [
            DialogButton(
              onPressed: () async {
                List<Placemark> placemark = await Geolocator()
                    .placemarkFromAddress(selectedSource + ',' + cityName);
                LatLng mSet = LatLng(placemark[0].position.latitude,
                    placemark[0].position.longitude);
                sourceLatLng = mSet;
                Navigator.pop(ctx);
                await selectDestination();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    }
  }

  Future<void> selectDestination() async {
    Alert(
        context: ctx,
        title: "Select Destination",
        content: getPickerDestination(),
        buttons: [
          DialogButton(
            onPressed: () async {
              List<Placemark> placemark = await Geolocator()
                  .placemarkFromAddress(selectedDestination + ',' + cityName);
              LatLng mSet = LatLng(placemark[0].position.latitude,
                  placemark[0].position.longitude);
              sendRequest(sourceLatLng, mSet);
              Navigator.pop(ctx);
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void setMarkers() async {
    if (markersVisible) {
      setState(() {
        markers.clear();
      });
      markersVisible = false;
    } else {
      var snaps = await fs.collection('Cities').document(cityName).get();
      var data = snaps.data;
      String ptv;
      data.forEach((key, value) {
        if (key == 'PTV') {
          ptv = value;
        }
      });
      place = [];
      while (ptv.isNotEmpty) {
        String temp = '';
        if (ptv.indexOf(',') != -1) {
          temp = ptv.substring(0, ptv.indexOf(','));
          ptv = ptv.substring(ptv.indexOf(',') + 1, ptv.length);
        } else {
          temp = ptv;
          ptv = '';
        }
        if (temp != '') {
          setPlacesMarker(temp);
          place.add(temp);
        }
      }
      selectedSource = place[0];
      selectedDestination = place[0];
      markersVisible = true;
    }
  }

  void fromCurrent() async {
    if (markersVisible) {
      dragDownRegister();
      dirType = 0;
      await selectSource();
    } else {
      setMarkers();
      await selectSource();
    }
  }

  void dirBetween() async {
    dirType = 1;
    dragDownRegister();
    if (!markersVisible) {
      setMarkers();
    }
    await selectSource();
  }

  void cityViewer() async {
    var control = await controllers.future;
    await control.moveCamera((CameraUpdate.newLatLng(center)));
  }

  void myLocation() async {
    var control = await controllers.future;
    await control
        .moveCamera((CameraUpdate.newLatLng(await getCurrentLocation())));
  }

  void reminder() async {
    await _handlePressButton();
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

    usePrediction(p, homeScaffoldKey.currentState);
  }

  Future<Null> usePrediction(Prediction p, ScaffoldState scaffold) async {
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
      cityName = p.description.substring(0, p.description.indexOf(','));
      // Start Stream which will read the Location in Background. This concept of stream has been
      // in Kafka earlier in Java.
      lco = lc.Location.instance.onLocationChanged
          .listen((currentLocation) async {
        if (calculateDistance(currentLocation.latitude,
                currentLocation.longitude, late, lng) <
            1) {
          // Here this will work in background but not sure needs testing
          // It will work in case if app is open and if it is opened after sometime.
          player.play('note1.wav');
          await lco.cancel();
        }
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng cp = LatLng(position.latitude, position.longitude);
    return cp;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      currentMapType =
          currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void getCityLatitude() async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(cityName);
    center =
        LatLng(placemark[0].position.latitude, placemark[0].position.longitude);
  }

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$kGoogleApiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    return values["routes"][0]["overview_polyline"]["points"];
  }

  void sendRequest(LatLng source, LatLng destination) async {
    String route = await getRouteCoordinates(source, destination);
    createRoute(route);
    setState(() {});
    //_addMarker(destination, "KTHM Collage");
  }

  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(center.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    // ignore: deprecated_member_use
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    return lList;
  }
}
