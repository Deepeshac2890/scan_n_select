import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_n_select/Class/TripDetails.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Screens/CreateTrip.dart';

class MyTripDashboard extends StatefulWidget {
  @override
  _MyTripDashboardState createState() => _MyTripDashboardState();
}

class _MyTripDashboardState extends State<MyTripDashboard> {
  Firestore fs = Firestore.instance;
  List<TripDetails> tripList = [];
  FirebaseAuth fa = FirebaseAuth.instance;
  String currentUserId;

  @override
  void initState() {
    getTrips();
    super.initState();
  }

  void getTrips() async {
    var user = await fa.currentUser();
    currentUserId = user.uid;
    var documentSnap = await fs
        .collection('Trip')
        .document('uid') // currentUserId
        .collection('MyTrips')
        .getDocuments();
    var documents = documentSnap.documents;
    print(documents.length);
    for (var document in documents) {
      var data = document.data;
      TripDetails td = TripDetails(await data['Start Date'],
          await data['End Date'], await data['Cities'], document.documentID);
      setState(() {
        tripList.add(td);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('My Trips'),
        ),
      ),
      drawer: NavDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to Create Trip Page
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CreateTrip();
          }));
        },
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: tripList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to Trip Details Screen where Tickets, Remarks and Reminders can be set
              },
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('Start Date : '),
                      trailing: Text(tripList[index].startDate),
                    ),
                    ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('End Date : '),
                      trailing: Text(tripList[index].endDate),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text('Cities Covered : '),
                      trailing: Text(tripList[index].citiesCovered.toString()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
