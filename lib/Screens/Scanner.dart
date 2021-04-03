import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class Scanner extends StatefulWidget {
  static String id = 'Scanner_Screen';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: FlatButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Item Scanner'),
        actions: [
          FlatButton(
              onPressed: () async {
                await scan();
              },
              child: Icon(Icons.qr_code_scanner_rounded)),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getWidget(),
          ],
        ),
      ),
    );
  }

  Widget getWidget() {
    // scan();
    if (qrResult == null) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            scan();
          },
          child: Container(
              color: Color(0xff2aaae3),
              child: Image(image: AssetImage('assets/scanQR.jpg'))),
        ),
      );
    } else if (qrResult.contains('null')) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            scan();
          },
          child: Container(
              color: Color(0xff2aaae3),
              child: Image(image: AssetImage('assets/scanQR.jpg'))),
        ),
      );
    } else {
      print(qrResult + 'On Success');
      return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage('assets/default.png')),
            SizedBox(
              height: 10,
            ),
            Text(
              'Item Type -> ' + itemType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Color -> ' + color,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Material Type -> ' + materialType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    }
  }

  void getData(String qrData) {
    itemType = qrData.substring(0, qrData.indexOf('_'));
    String rest = qrData.substring(qrData.indexOf('_') + 1, qrData.length);
    color = rest.substring(0, rest.indexOf('_'));
    rest = rest.substring(rest.indexOf('_') + 1, rest.length);
    materialType = rest;
    setState(() {});
  }

  Future scan() async {
    try {
      String barcode = await scanner.scan();
      qrResult = barcode;
      getData(barcode);
      setState(() {
        qrResult = barcode;
      });
    } catch (e) {
      print(e);
    }
  }
}
