import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Constants.dart';
import 'package:scan_n_select/Screens/CityInfo.dart';

class Dashboard extends StatefulWidget {
  static String id = 'Dashboard_Screen';
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        // ignore: deprecated_member_use
        title: GestureDetector(
          onHorizontalDragDown: (values) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: Container(
            padding: EdgeInsets.only(right: 5),
            child: TextField(
              onChanged: (value) {
                // Add search functionality.
              },
              decoration: kSearchFieldDecoration,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.black38,
        child: ListView(
          children: [
            DashboardCity(
              cityName: 'Goa',
            ),
            DashboardCity(
              cityName: 'Bangalore',
            ),
            DashboardCity(
              cityName: 'Delhi',
            ),
            DashboardCity(
              cityName: 'Shimla',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCity extends StatelessWidget {
  final cityName;
  DashboardCity({this.cityName});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CityInfo(cityName);
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/Background/$cityName.jpg'),
          ),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.all(10),
          child: Text(
            cityName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
