import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scan_n_select/Components/NavigationDrawer.dart';

String url;

class TicketViewer extends StatefulWidget {
  @override
  _TicketViewerState createState() => _TicketViewerState();
  TicketViewer(String pdf) {
    url = pdf;
  }
}

class _TicketViewerState extends State<TicketViewer> {
  PDFDocument doc;
  bool isLoading = true;
  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  void loadDocument() async {
    try {
      doc = await PDFDocument.fromURL(url);
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
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: PDFViewer(
            document: doc,
            zoomSteps: 1,
          ),
        ),
      ),
    );
  }
}
