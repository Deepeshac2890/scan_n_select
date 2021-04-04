import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scan_n_select/Keys.dart';
import 'package:scan_n_select/Screens/Scanner.dart';
import 'package:scan_n_select/Screens/WelcomeScreen.dart';

// Keys have been moved to a Local File to protect them.
class SuggestorInfoCollector extends StatefulWidget {
  static String id = 'Suggestor_Info_Collector_Screen';
  @override
  _SuggestorInfoCollectorState createState() => _SuggestorInfoCollectorState();
}

FirebaseAuth fa = FirebaseAuth.instance;
final homeScaffoldKey = GlobalKey<ScaffoldState>();
TextEditingController ted = TextEditingController();
FirebaseStorage fbs = FirebaseStorage.instance;
Firestore fs = Firestore.instance;

class _SuggestorInfoCollectorState extends State<SuggestorInfoCollector> {
  bool isSpinning = false;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String desc = 'Click Here to Enter Destination City';
  String lat;
  String long;
  List<Widget> itemList = <Widget>[];
  List<String> itemTypes = [];
  List<int> itemQuant = [];
  var loggedInUser;
  var cPdf = pw.Document();
  List<List<String>> ls = [];
  bool showBottomButton = false;

  bool _decideWhichDayToEnableStart(DateTime day) {
    if (day.isAfter(DateTime.now().subtract(
      Duration(days: 1),
    ))) {
      return true;
    }
    return false;
  }

  bool _decideWhichDayToEnableEnd(DateTime day) {
    if (day.isAfter(startDate.subtract(Duration(days: 1)))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    startDate = DateTime.now();
    endDate = DateTime.now();
    currentUser();
    addFirstPage();
    setState(() {});
    super.initState();
  }

  void currentUser() async {
    loggedInUser = await FirebaseAuth.instance.currentUser();
  }

  void addFirstPage() {
    cPdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Text(
                  'List Of Items For Your Trip',
                  style: pw.TextStyle(
                      fontSize: 30, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ); // Center
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: FlatButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Travel Details'),
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () {
              fa.signOut();
              Navigator.popUntil(
                  context, ModalRoute.withName(WelcomeScreen.id));
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ignore: deprecated_member_use
              FlatButton(
                child: Text(
                  'Destination : ' + desc,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                onPressed: () {
                  _handlePressButton();
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Start Date : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.date_range),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var startiDate = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2023),
                          helpText: 'Start Date',
                          selectableDayPredicate: _decideWhichDayToEnableStart);
                      if (startiDate != null) {
                        setState(() {
                          startDate = startiDate;
                          if (startDate.isAfter(endDate)) endDate = startiDate;
                        });
                      }
                    },
                    child: Text('${startDate.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'End Date : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.date_range),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var endiDate = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          helpText: 'End Date',
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2023),
                          selectableDayPredicate: _decideWhichDayToEnableEnd);
                      if (endiDate != null) {
                        setState(() {
                          endDate = endiDate;
                        });
                      }
                    },
                    child: Text('${endDate.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    getWeather(0);
                  },
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(10.0),
                  children: itemList,
                ),
              ),
              // ignore: deprecated_member_use
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: showBottomButton,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () {
                        // Generate PDF
                        generatePDF();
                      },
                      child: Text(
                        'Generate PDF of List',
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.blueAccent,
                    ),
                  ),
                  Visibility(
                    visible: showBottomButton,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () {
                        // Start the Packing - Open Scanner with the List
                        // Edit the Scanner interface
                        startPacking();
                      },
                      child: Text(
                        'Start Packing',
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void startPacking() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scanner(ls);
    }));
  }

  void generatePDF() async {
    await getWeather(1);
    try {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => cPdf.save());
    } catch (e) {
      print(e);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    // ignore: deprecated_member_use
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "IN")],
    );

    displayPrediction(p, homeScaffoldKey.currentState);
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

      setState(() {
        desc = p.description;
        ted.text = desc;
        long = lng.toString();
        lat = late.toString();
      });
    }
  }

  Future<void> getTypes(double startTemp, double endTemp, int l) async {
    double avgTemp = (startTemp + endTemp) / 2;
    int numOfDays = endDate.difference(startDate).inDays;
    if (avgTemp > 30) {
      // Hot Weather
      itemTypes = [];
      itemQuant = [];
      itemTypes.add('T-Shirt');
      itemQuant.add(numOfDays);
      itemTypes.add('Short');
      itemQuant.add((numOfDays / 2).ceil());
      itemTypes.add('Sandals');
      itemQuant.add(1);
      itemTypes.add('Jean');
      itemQuant.add(numOfDays);
    } else if (avgTemp > 25) {
      // Pleasant Weather
      itemTypes = [];
      itemQuant = [];
      itemTypes.add('T-Shirt');
      itemQuant.add(numOfDays);
      itemTypes.add('Lower');
      itemQuant.add((numOfDays / 2).ceil());
      itemTypes.add('Sandals');
      itemQuant.add(1);
      itemTypes.add('Jean');
      itemQuant.add(numOfDays);
    } else if (avgTemp > 20) {
      itemTypes = [];
      itemQuant = [];
      itemTypes.add('Full Shirt');
      itemQuant.add(numOfDays);
      itemTypes.add('Lower');
      itemQuant.add((numOfDays / 2).ceil());
      itemTypes.add('Shoes');
      itemQuant.add(1);
      itemTypes.add('Jean');
      itemQuant.add(numOfDays);
      itemTypes.add('Socks');
      itemQuant.add(numOfDays);
    } else {
      // Cold Weather
      itemTypes = [];
      itemQuant = [];
      itemTypes.add('Full Shirt');
      itemQuant.add(numOfDays);
      itemTypes.add('Lower');
      itemQuant.add((numOfDays / 2).ceil());
      itemTypes.add('Shoes');
      itemQuant.add(1);
      itemTypes.add('Socks');
      itemQuant.add(numOfDays);
      itemTypes.add('Jean');
      itemQuant.add(numOfDays);
      itemTypes.add('Jacket');
      itemQuant.add(1);
      itemTypes.add('Sweater');
      itemQuant.add(1);
    }
    await getItems(itemTypes, itemQuant, l);
  }

  Future<void> getItems(
      List<String> itemTypes, List<int> itemQuant, int l) async {
    int i = 0;

    if (l == 0) {
      itemList = [];
    }

    if (l == 1) {
      cPdf = pw.Document();
      addFirstPage();
    }
    var snap = await fs
        .collection('Wardrobe')
        .document(loggedInUser.uid)
        .collection('Items')
        .getDocuments();

    var documents = snap.documents;

    for (var document in documents) {
      String type = await document['ItemType'];
      String color = await document['Color'];
      String data = await document['Data'];
      String index = await document['Index'];
      var url;
      try {
        url = await fbs
            .ref()
            .child(loggedInUser.email)
            .child(data + '_' + index)
            .getDownloadURL();
      } catch (e) {
        url = null;
      }
      if (itemTypes.contains(type)) {
        int quant = itemQuant.elementAt(itemTypes.indexOf(type));
        if (quant > 0) {
          i++;
          if (l == 0) {
            // This is to generate List of Items
            CustomItem cs = CustomItem(
              color: color,
              type: type,
              imgUrl: url,
            );
            itemList.add(cs);
            quant = quant - 1;
            itemQuant[itemTypes.indexOf(type)] = quant;
            ls.add([data, type, color, index, url]);
          } else if (l == 1) {
            // This is for Generation of PDF
            Uint8List byteImage = await networkImageToByte(url);
            final image = pw.MemoryImage(
              byteImage,
            );
            cPdf.addPage(
              pw.Page(
                build: (pw.Context context) {
                  return pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '$i . $color $type',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Center(
                        child: pw.Image(image),
                      ),
                    ],
                  ); // Center
                },
              ),
            );
          }
        }
      }
    }
    setState(() {
      isSpinning = false;
      showBottomButton = true;
    });
  }

  Future<void> getWeather(int l) async {
    setState(() {
      isSpinning = true;
    });
    String end = endDate.toString().split(' ')[0];
    String start = startDate.toString().split(' ')[0];
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$lat%2C$long/$start/$end?unitGroup=metric&key=$weatherKey';
    http.Response repo = await http.get(url);
    var decodedData = jsonDecode(repo.body);
    if (repo.statusCode == 200) {
      // Everything went well
      if (decodedData != null) {
        int days = endDate.difference(startDate).inDays;

        var iniTempMax = decodedData['days'][0]['tempmax'];
        var iniTempMin = decodedData['days'][0]['tempmin'];
        var endTempMax = decodedData['days'][days - 1]['tempmax'];
        var endTempMin = decodedData['days'][days - 1]['tempmin'];

        var iniAvgTemp = (iniTempMin + iniTempMax) / 2;
        var endAvgTemp = (endTempMin + endTempMax) / 2;

        await getTypes(iniAvgTemp, endAvgTemp, l);
      }
    } else {
      Alert(context: context, title: 'Error Occurred While Fetching Data')
          .show();
    }
  }
}

class CustomItem extends StatelessWidget {
  final color;
  final type;
  final imgUrl;

  CustomItem({
    this.color,
    this.type,
    this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: getImage(),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            color + ' ' + type,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Image getImage() {
    if (imgUrl != null) {
      return Image.network(imgUrl);
    } else
      return Image.asset('assets/default.png');
  }
}
