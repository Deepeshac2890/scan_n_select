import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime_type/mime_type.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Constants.dart';
import 'package:scan_n_select/Screens/Generator.dart';
import 'package:scan_n_select/Screens/TicketViewer.dart';

List<String> mot = ['Bus', 'Train', 'Flight'];
const List<Choice> choices = [
  Choice('Flight', Icons.flight),
  Choice('Train', Icons.train),
  Choice('Bus', Icons.card_travel),
];
String date = '';
String source = '';
String destination = '';
TextEditingController tedSource = TextEditingController();
TextEditingController tedDestination = TextEditingController();
TextEditingController tedDate = TextEditingController();
String selectedMode = 'Bus';
List<TicketInfo> tickets = [];
BuildContext ctx;

class TicketInfo {
  final String source;
  final String destination;
  final String date;
  final String downloadURL;
  final String ticketType;
  final String documentID;
  final String mot;

  TicketInfo(
      {@required this.downloadURL,
      @required this.date,
      @required this.destination,
      @required this.source,
      this.ticketType,
      this.documentID,
      this.mot});
}

class SavedTickets extends StatefulWidget {
  @override
  _SavedTicketsState createState() => _SavedTicketsState();
}

FirebaseUser currentUserName;

class _SavedTicketsState extends State<SavedTickets> {
  FirebaseStorage fbs = FirebaseStorage.instance;
  FirebaseAuth fa = FirebaseAuth.instance;
  Firestore fs = Firestore.instance;

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  void currentUser() async {
    currentUserName = await fa.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return MaterialApp(
      home: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            title: Center(child: Text('Saved Tickets')),
            bottom: TabBar(
              isScrollable: true,
              tabs: choices.map<Widget>(
                (Choice choice) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Tab(
                      text: choice.title,
                      icon: Icon(choice.icon),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          drawer: NavDrawer(),
          body: TabBarView(
              children: choices.map<Widget>((Choice choice) {
            return Padding(
              padding: EdgeInsets.all(10),
              child: ChoicePage(
                choice: choice,
              ),
            );
          }).toList()),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              tedSource.clear();
              tedDestination.clear();
              tedDate.clear();
              source = '';
              destination = '';
              date = '';
              await Alert(
                      context: context,
                      title: 'Upload Ticket',
                      buttons: [
                        DialogButton(
                          child: Text('Select and Upload'),
                          onPressed: () async {
                            if (source != '' &&
                                destination != '' &&
                                date != '') {
                              File file = await FilePicker.getFile();
                              var docSnap = await fs
                                  .collection('Misc Data')
                                  .document(currentUserName.uid)
                                  .get();
                              var data = docSnap.data;
                              var counter = await data['Image Counter'];
                              counter++;
                              await fs
                                  .collection('Misc Data')
                                  .document(currentUserName.uid)
                                  .setData({
                                'Image Counter': counter,
                              });
                              if (file != null) {
                                final mimeType =
                                    mime(file.path.split('/').last);
                                var upload = await fbs
                                    .ref()
                                    .child(currentUserName.email)
                                    .child('Tickets')
                                    .child(selectedMode)
                                    .child(counter.toString())
                                    .putFile(file)
                                    .onComplete;
                                if (upload.error == null) {
                                  var downloadURL =
                                      await upload.ref.getDownloadURL();
                                  String dUrl = downloadURL.toString();
                                  // Here we save the URL of Ticket on FireStore
                                  try {
                                    var snap = fs
                                        .collection('Tickets')
                                        .document(currentUserName.uid)
                                        .collection(selectedMode);
                                    await snap.add({
                                      'url': dUrl,
                                      'Source': source,
                                      'Destination': destination,
                                      'Date': date,
                                      'Type': mimeType
                                    });
                                    Navigator.pop(context);
                                    Alert(
                                        context: context,
                                        title: 'Upload Complete',
                                        buttons: [
                                          DialogButton(
                                              child: Text('Okay'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              })
                                        ]).show();
                                  } catch (e) {
                                    print(e + 'Error');
                                  }
                                }
                              } else {
                                Navigator.pop(context);
                                Alert(
                                    context: context,
                                    title: 'Error Occurred',
                                    buttons: [
                                      DialogButton(
                                          child: Text('Try Again'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })
                                    ]).show();
                              }
                            } else {
                              if (source == '')
                                tedSource.text = 'Select Source !!';
                              if (destination == '')
                                tedDestination.text = 'Select Destination !!';
                              if (date == '')
                                tedDate.text = 'Select Travel Date !!';
                            }
                          },
                        ),
                        DialogButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                      content: UploadWidget())
                  .show();
            },
          ),
        ),
      ),
    );
  }
}

class UploadWidget extends StatefulWidget {
  @override
  _UploadWidgetState createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    dragDownRegister();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          GestureDetector(
            onHorizontalDragDown: (dragDownDetails) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: TextField(
              controller: tedSource,
              onChanged: (value) {
                setState(() {
                  source = value;
                });
              },
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Enter Source City'),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onHorizontalDragDown: (dragDownDetails) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: TextField(
              controller: tedDestination,
              onChanged: (value) {
                setState(() {
                  destination = value;
                });
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter Destination City'),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              selectDate(context);
            },
            child: TextField(
              controller: tedDate,
              enabled: false,
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Travel Date'),
              keyboardType: TextInputType.number,
            ),
          ),
          ListTile(
            leading: Text('Mode : '),
            trailing: getPicker(),
          ),
        ],
      ),
    );
  }

  void selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        tedDate.text = selectedDate.toString().substring(0, 11);
        date = selectedDate.toString();
      });
  }

  void dragDownRegister() {
    ls = [];
    for (String mOT in mot) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(mOT),
        value: mOT,
      );
      ls.add(dm);
    }
  }

  DropdownButton<String> getAndroidPicker() {
    return DropdownButton<String>(
      value: selectedMode,
      onChanged: (value) {
        setState(() {
          selectedMode = value;
        });
      },
      items: ls,
    );
  }

  CupertinoPicker getIOSPicker() {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMode = mot[value];
        });
      },
      children: ls,
    );
  }

  Widget getPicker() {
    if (Platform.isIOS)
      return getIOSPicker();
    else
      return getAndroidPicker();
  }
}

class Choice {
  final String title;
  final IconData icon;
  const Choice(this.title, this.icon);
}

class ChoicePage extends StatefulWidget {
  final Choice choice;
  const ChoicePage({Key key, this.choice}) : super(key: key);

  @override
  _ChoicePageState createState() => _ChoicePageState(choice);
}

class _ChoicePageState extends State<ChoicePage> {
  final Choice choice;
  List<Widget> ls = [];
  String mot = '';

  _ChoicePageState(this.choice);
  @override
  void initState() {
    ls.clear();
    tickets.clear();
    parseDatabase(choice.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        child: ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ti = tickets[index];
              if (ti.mot == mot) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // Delete the Ticket
                    setState(() async {
                      tickets.remove(index);
                      await fs
                          .collection('Tickets')
                          .document(currentUserName.uid)
                          .collection(mot)
                          .document(ti.documentID)
                          .delete();
                      await fbs
                          .ref()
                          .child(currentUserName.email)
                          .child('Tickets')
                          .child(mot)
                          .child(
                              ti.source + '_' + ti.destination + '_' + ti.date)
                          .delete();
                    });
                  },
                  background: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerRight,
                    color: Colors.redAccent,
                    child: Icon(Icons.delete),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (ctx) {
                            return TicketViewer(ti.downloadURL, ti.ticketType);
                          },
                        ),
                      );
                    },
                    child: Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: 200,
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1,
                            top: 30),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: Image.asset('assets/Ticket.jpg').image),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                mot + ' Ticket',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Source City : ' + ti.source,
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Destination City : ' + ti.destination,
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Travel Date : ' + ti.date,
                                style: TextStyle(
                                    color: Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }));
  }

  void parseDatabase(String mot) async {
    var snap = await fs
        .collection('Tickets')
        .document(currentUserName.uid)
        .collection(mot)
        .getDocuments();
    int i = 0;
    snap.documents.forEach((dSnap) async {
      i++;
      var data = dSnap.data;
      String url = await data['url'];
      TicketInfo ti = TicketInfo(
          downloadURL: url,
          date: await data['Date'],
          source: await data['Source'],
          ticketType: await data['Type'],
          destination: await data['Destination'],
          documentID: dSnap.documentID,
          mot: mot);
      tickets.add(ti);
      if (i == snap.documents.length) {
        // To check if widget is mounted before calling setState
        if (mounted) {
          setState(() {
            this.mot = mot;
          });
        }
      }
    });
  }
}
