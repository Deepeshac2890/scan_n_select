import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

String itemColor;
String itemType;
String materialType;
String labelData;
Image img = Image.asset('assets/default.png');

class Generator extends StatefulWidget {
  static String id = 'Generator_Screen';

  Generator(mType, type, color) {
    itemColor = color;
    itemType = type;
    materialType = mType;
    labelData = itemType + '_' + itemColor + '_' + materialType;
  }

  @override
  _GeneratorState createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Generator'),
        automaticallyImplyLeading: false,
        leading: FlatButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImage(data: labelData),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
        ],
      ),
    );
  }

  void addToPDF() {
    // Will try to use fire store
  }

  void printQR() async {
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
                style: pw.TextStyle(fontSize: 20),
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
