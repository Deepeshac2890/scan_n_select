import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:scan_n_select/Components/CheckListItem.dart';

List<List<String>> ls = [];
List<Widget> listToShow = [];
List<String> itemsChecked = [];

// TODO: Add List of Item and checklist when the scan is complete
// TODO: Add option to edit the list of Items

class Scanner extends StatefulWidget {
  static String id = 'Scanner_Screen';
  Scanner(List<List<String>> lsi) {
    ls = lsi;
  }

  @override
  _ScannerState createState() => _ScannerState();
}

bool backCamera = true;

class _ScannerState extends State<Scanner> {
  String qrResult;
  String itemType = '';
  String color = '';
  String materialType = '';

  @override
  void initState() {
    createList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // ignore: deprecated_member_use
        leading: FlatButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: () async {
                await scan();
              },
              child: Icon(Icons.qr_code_scanner_rounded)),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Item Checklist',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: ListView(
                children: listToShow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createList() {
    listToShow = [];
    for (var li in ls) {
      print(li[0]);
      print(itemsChecked);
      if (itemsChecked.contains(li[0])) {
        CheckListItem rw = CheckListItem(li, Icons.check_box);
        listToShow.add(rw);
      } else {
        CheckListItem rw = CheckListItem(li, Icons.check_box_outline_blank);
        listToShow.add(rw);
      }
    }
    setState(() {});
  }

  void checkListUpdate(String qrResult) {
    itemsChecked.add(qrResult);
    createList();
  }

  Future scan() async {
    try {
      String barcode = await scanner.scan();
      qrResult = barcode;
      if (!qrResult.contains('null')) {
        checkListUpdate(qrResult);
      }
    } catch (e) {
      print(e);
    }
  }
}
