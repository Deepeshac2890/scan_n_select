import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  Completer<GoogleMapController> controllers = Completer();
  static LatLng center = LatLng(71.521563, 30.677433);
  final Set<Marker> markers = {};
  LatLng lastMapPosition = center;
  MapType currentMapType = MapType.normal;
  Firestore fs = Firestore.instance;
  bool markersVisible = false;

  _onMapCreated(GoogleMapController controller) async {
    // This is done to set the view to Destination City
    getCityLati();
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
          infoWindow:
              InfoWindow(title: area, snippet: 'This is a Place to Visit'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  _onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  Widget button(Function fn, IconData icon) {
    return FloatingActionButton(
      onPressed: fn,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.lightBlue,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(center.longitude);
    print(center.latitude);
    return Scaffold(
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
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            compassEnabled: true,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  button(_onMapTypeButtonPressed, Icons.map),
                  SizedBox(
                    height: 16,
                  ),
                  button(cityViewer, Icons.location_city),
                  SizedBox(
                    height: 16,
                  ),
                  button(myLocation, Icons.my_location),
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
                  button(dirBetween, Icons.directions),
                  SizedBox(
                    height: 16,
                  ),
                  button(setMarkers, Icons.pin_drop),
                  SizedBox(
                    height: 16,
                  ),
                  button(fromCurrent, Icons.directions_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fromCurrent() async {}

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
      List<String> place = [];
      int l = ptv.length;
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
      markersVisible = true;
    }
  }

  void dirBetween() async {}

  void cityViewer() async {
    var control = await controllers.future;
    await control.moveCamera((CameraUpdate.newLatLng(center)));
  }

  void myLocation() async {
    var control = await controllers.future;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng cp = LatLng(position.latitude, position.longitude);
    await control.moveCamera((CameraUpdate.newLatLng(cp)));
  }

  _onMapTypeButtonPressed() {
    setState(() {
      currentMapType =
          currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(lastMapPosition.toString()),
          position: lastMapPosition,
          infoWindow:
              InfoWindow(title: 'This is Title', snippet: 'This is snippet'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getCityLati();
    super.initState();
  }

  void getCityLati() async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(cityName);
    center =
        LatLng(placemark[0].position.latitude, placemark[0].position.longitude);
  }
}
