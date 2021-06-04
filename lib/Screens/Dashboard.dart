import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';
import 'package:scan_n_select/Screens/CityInfo.dart';

// TODO: Add Trip Add Page where users can add the trip link it with Ticket Save and Item Suggester.

List<String> cityNames = [];

class Dashboard extends StatefulWidget {
  static String id = 'Dashboard_Screen';
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<DashboardCity> cityTiles = [];
  List<bool> lb = [];
  bool loading = true;
  @override
  void initState() {
    getData().whenComplete(() => null);
    super.initState();
  }

  Future<void> getData() async {
    var fs = Firestore.instance;
    var fSnap = await fs.collection('Data').getDocuments();
    var fo = await fs.collection('Data').document('City Count').get();
    var countData = fo.data;
    var count = await countData['Count'];
    for (var documents in fSnap.documents) {
      if (documents.documentID != 'City Count') {
        var data = documents.data;
        var name = await data['Name'];
        cityNames.add(name);
        String imageUrl = await data['url'];
        Image img = Image.network(imageUrl);
        // This can be done to wait for Image to be loaded
        img.image.resolve(new ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, call) {
              lb.add(true);
              print('Image is Loaded');
              Widget cityTile = DashboardCity(cityName: name, cityImage: img);
              cityTiles.add(cityTile);
              if (lb.length.toString() == count) {
                setState(() {
                  loading = false;
                });
              }
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blueGrey),
        foregroundColor: Colors.blueGrey,
        title: Center(
          child: Text(
            'Travel Buddy',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.blueGrey,
              ),
              onPressed: () async {
                if (!loading) {
                  var result = await showSearch(
                      context: context, delegate: CustomDelegate());
                  if (result != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CityInfo(result);
                        },
                      ),
                    );
                  }
                }
              })
        ],
      ),
      body: Container(
        color: Colors.black38,
        // Here use builder to list all the cities
        child: loading == true
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: cityTiles,
              ),
      ),
    );
  }
}

class DashboardCity extends StatelessWidget {
  final cityName;
  final Image cityImage;
  DashboardCity({this.cityName, this.cityImage});

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
            image: cityImage.image,
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

class CustomDelegate<T> extends SearchDelegate<T> {
  List<String> data = cityNames;

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.chevron_left), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    var listToShow;
    if (query.isNotEmpty)
      listToShow =
          data.where((e) => e.contains(query) && e.startsWith(query)).toList();
    else
      listToShow = data;

    return ListView.builder(
      itemCount: listToShow.length,
      itemBuilder: (_, i) {
        var noun = listToShow[i];
        return ListTile(
          title: Text(noun),
          onTap: () => close(context, noun),
        );
      },
    );
  }
}
