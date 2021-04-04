import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'WelcomeScreen.dart';

String itemColor;
String itemType;
String materialType;
String labelData;
File imgFile;
String index;
Image img = Image.asset('assets/default.png');
FirebaseAuth fa = FirebaseAuth.instance;
FirebaseStorage fbs = FirebaseStorage.instance;
Firestore fs = Firestore.instance;

class Generator extends StatefulWidget {
  static String id = 'Generator_Screen';

  Generator(mType, type, color, imgF, indexs) {
    itemColor = color;
    itemType = type;
    materialType = mType;
    imgFile = imgF;
    index = indexs;
    labelData = itemType + '_' + itemColor + '_' + materialType;
  }

  @override
  _GeneratorState createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator> {
  var loggedInUser;
  bool isSpinning = false;
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Generator'),
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
              onPressed: () {
                fa.signOut();
                Navigator.popUntil(
                    context, ModalRoute.withName(WelcomeScreen.id));
              },
              child: Icon(Icons.logout))
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: QrImage(data: labelData)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  minWidth: MediaQuery.of(context).size.width * 0.3,
                  onPressed: () async {
                    addToPDF();
                  },
                  child: Text('Add to PDF'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueAccent,
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  minWidth: MediaQuery.of(context).size.width * 0.3,
                  onPressed: () async {
                    printQR();
                  },
                  child: Text('Print QR'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueAccent,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  minWidth: MediaQuery.of(context).size.width * 0.3,
                  onPressed: () async {
                    // Here we should go to GeneratorInfoCollector
                    Navigator.pop(context);
                  },
                  child: Text('Regenerate'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueAccent,
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  minWidth: MediaQuery.of(context).size.width * 0.3,
                  onPressed: () async {
                    // Do Something here
                    // Here when we create a Dashboard we should go there
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blueAccent,
                ),
              ],
            ),
            // ignore: deprecated_member_use
            FlatButton(
              minWidth: MediaQuery.of(context).size.width * 0.3,
              onPressed: () async {
                // Do Something here
                // Here when we create a Dashboard we should go there
                printCompletePDF();
              },
              child: Text('Print Complete PDF'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  void printCompletePDF() async {
    setState(() {
      isSpinning = true;
    });
    try {
      final cPdf = pw.Document();
      var docs = await fs
          .collection('Wardrobe')
          .document(loggedInUser.uid)
          .collection('Items')
          .getDocuments();
      var docsSnap = await docs.documents;
      for (var doc in docsSnap) {
        String qrLabel = await doc.data['Data'];
        final image = pw.MemoryImage(
          await toQrImageData(qrLabel),
        );

        cPdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(image),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      qrLabel,
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ); // Center
            },
          ),
        );
      }
      // This is for printing the PDF
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => cPdf.save());
    } catch (e) {
      Alert(context: context, title: 'Something Bad Happened').show();
      print(e);
    }
    setState(() {
      isSpinning = false;
    });
  }

  void addToPDF() async {
    if (!isAdded) {
      await addToFS();
      isAdded = true;
    }
  }

  Future<void> addToFS() async {
    setState(() {
      isSpinning = true;
    });

    try {
      var url = '';
      if (index == null) index = '1';
      if (imgFile != null) {
        var imgName =
            itemType + '_' + itemColor + '_' + materialType + '_' + index;
        var dataUp = await fbs
            .ref()
            .child(loggedInUser.email)
            .child(imgName)
            .putFile(imgFile)
            .onComplete;
        url = await dataUp.ref.getDownloadURL();
      }
      var snap = await fs
          .collection('Wardrobe')
          .document(loggedInUser.uid)
          .collection('Items');
      await snap.add({
        'url': url,
        'ItemType': itemType,
        'Color': itemColor,
        'Data': itemType + '_' + itemColor + '_' + materialType,
        'MaterialType': materialType,
        'Index': index,
      });
    } catch (e) {
      Alert(context: context, title: 'Cannot Connect to Database').show();
    }
    setState(() {
      isSpinning = false;
    });
  }

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  void currentUser() async {
    loggedInUser = await fa.currentUser();
    var email = loggedInUser.email;
  }

  void printQR() async {
    if (!isAdded) {
      await addToFS();
      isAdded = true;
    }

    final pdf = pw.Document();
    final image = pw.MemoryImage(
      await toQrImageData(labelData),
    );

    pdf.addPage(
      pw.Page(build: (pw.Context context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Image(image),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                labelData,
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ); // Center
      }),
    );

    // This is for printing the PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<Uint8List> toQrImageData(String text) async {
    try {
      final image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);
      return a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }
  }
}
