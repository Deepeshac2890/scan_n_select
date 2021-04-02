import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scanner extends StatefulWidget {
  static String id = 'Scanner_Screen';
  @override
  _ScannerState createState() => _ScannerState();
}

bool backCamera = true;

class _ScannerState extends State<Scanner> {
  String qrResult;
  String itemType;
  String color;
  String materialType;

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
              'Item Type -> ',
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

  void getData() {
    print(qrResult.indexOf('_'));
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => () {
            print(barcode);
            if (!barcode.contains('null')) {
              this.qrResult = barcode;
            }
          });
      getData();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.qrResult = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.qrResult = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.qrResult =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.qrResult = 'Unknown error: $e');
    }
  }
}
