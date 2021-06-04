import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';

String url;
String type;

class TicketViewer extends StatefulWidget {
  @override
  _TicketViewerState createState() => _TicketViewerState();
  TicketViewer(String pdf, String typ) {
    url = pdf;
    type = typ;
  }
}

class _TicketViewerState extends State<TicketViewer> {
  PDFDocument doc;
  bool isLoading = true;
  Image img;
  int supportLevel = 3;
  Widget showTicket;
  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  void loadDocument() async {
    try {
      if (type == null) {
        supportLevel = 3;
        showTicket = Center(
          child: Text('Error Occurred !! Ticket Type Not Supported.'),
        );
      } else if (type.contains('pdf')) {
        supportLevel = 1;
        doc = await PDFDocument.fromURL(url);
        showTicket = PDFViewer(
          document: doc,
          zoomSteps: 1,
        );
      } else if (type.contains('image')) {
        // It is an image else not supported
        supportLevel = 2;
        img = Image.network(url);
        img.image
            .resolve(ImageConfiguration())
            .addListener(ImageStreamListener((_, __) {
          showTicket = Center(
            child: Image(
              image: img.image,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
            ),
          );
          setState(() {
            isLoading = false;
          });
        }));
      } else {
        supportLevel = 3;
        showTicket = Center(
          child: Text('Error Occurred !! Ticket Type Not Supported.'),
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Viewer'),
      ),
      drawer: NavDrawer(),
      body: Card(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : showTicket),
    );
  }
}
