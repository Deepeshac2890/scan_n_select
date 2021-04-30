import 'package:flutter/material.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';

class SavedTickets extends StatefulWidget {
  @override
  _SavedTicketsState createState() => _SavedTicketsState();
}

class _SavedTicketsState extends State<SavedTickets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tickets"),
      ),
      drawer: NavDrawer(),
      body: Column(
        children: [
          NavigationToolbar(),
        ],
      ),
    );
  }
}
