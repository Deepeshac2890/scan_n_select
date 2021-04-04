import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:scan_n_select/Components/CheckListItem.dart';

List<List<String>> ls = [];
List<Widget> listToShow = [];
List<String> itemsChecked = [];

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
            )
          ],
        ),
      ),
    );
  }

  // Widget getWidget() {
  //   if (qrResult == null) {
  //     return Expanded(
  //       child: GestureDetector(
  //         onTap: () {
  //           scan();
  //         },
  //         child: Container(
  //             color: Color(0xff2aaae3),
  //             child: Image(image: AssetImage('assets/scanQR.jpg'))),
  //       ),
  //     );
  //   } else if (qrResult.contains('null')) {
  //     return Expanded(
  //       child: GestureDetector(
  //         onTap: () {
  //           scan();
  //         },
  //         child: Container(
  //             color: Color(0xff2aaae3),
  //             child: Image(image: AssetImage('assets/scanQR.jpg'))),
  //       ),
  //     );
  //   } else {
  //     print(qrResult + 'On Success');
  //     return Container(
  //       margin: EdgeInsets.all(10),
  //       padding: EdgeInsets.all(10),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Image(image: AssetImage('assets/default.png')),
  //           SizedBox(
  //             height: 10,
  //           ),
  //           Text(
  //             'Item Type -> ' + itemType,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20,
  //             ),
  //           ),
  //           Text(
  //             'Color -> ' + color,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20,
  //             ),
  //           ),
  //           Text(
  //             'Material Type -> ' + materialType,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // void getData(String qrData) {
  //   itemType = qrData.substring(0, qrData.indexOf('_'));
  //   String rest = qrData.substring(qrData.indexOf('_') + 1, qrData.length);
  //   color = rest.substring(0, rest.indexOf('_'));
  //   rest = rest.substring(rest.indexOf('_') + 1, rest.length);
  //   materialType = rest;
  //   setState(() {});
  // }

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
