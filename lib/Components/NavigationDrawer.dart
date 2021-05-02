import 'package:flutter/material.dart';
import 'package:scan_n_select/Screens/Dashboard.dart';
import 'package:scan_n_select/Screens/GeneratorInfoCollector.dart';
import 'package:scan_n_select/Screens/MyProfile.dart';
import 'package:scan_n_select/Screens/SavedTickets.dart';
import 'package:scan_n_select/Screens/SuggestorInfoCollector.dart';
import 'package:scan_n_select/Screens/WeatherScreen.dart';
import 'package:scan_n_select/Screens/WelcomeScreen.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Image.asset('assets/logo.gif'),
            decoration: BoxDecoration(
              color: Color.fromRGBO(239, 231, 187, 1),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, Dashboard.id);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              // TODO: Take the Profile created for BuyCycle and use it here with improvements
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Profile();
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.wb_cloudy),
            title: Text('Weather'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WeatherScreen(null);
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.flight_land),
            title: Text('Saved Tickets'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SavedTickets();
              }));
            },
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Cloth Selector',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.qr_code),
            title: Text('QR Generator'),
            onTap: () {
              Navigator.pushNamed(context, GeneratorInfoCollector.id);
            },
          ),
          ListTile(
            leading: Icon(Icons.stream),
            title: Text('Cloth Picker'),
            onTap: () {
              Navigator.pushNamed(context, SuggestorInfoCollector.id);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(WelcomeScreen.id));
            },
          ),
        ],
      ),
    );
  }
}

class Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      color: Colors.black26,
      width: double.infinity,
      height: 1,
    );
  }
}
