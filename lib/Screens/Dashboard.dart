import 'package:flutter/material.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Constants.dart';

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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // ignore: deprecated_member_use
        actions: [
          TextButton(
            child: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(right: 5),
              child: TextField(
                onChanged: (value) {
                  // Add search functionality.
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Search Away!'),
              ),
            ),
          ),
        ],
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
      onTap: () {},
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
