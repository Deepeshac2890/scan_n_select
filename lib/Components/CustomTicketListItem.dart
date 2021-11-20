import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_n_select/Services/DateTimeServices.dart';

class CustomTicketListItem extends StatefulWidget {
  @override
  _CustomTicketListItemState createState() => _CustomTicketListItemState();
}

class _CustomTicketListItemState extends State<CustomTicketListItem> {
  File ticket;
  List<String> mot = ['Bus', 'Train', 'Flight'];
  String selectedMode = 'Bus';
  String source = "";
  String destination = "";
  DateTime travelDate = DateTime.now();
  List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];
  CustomDateTime cdt = CustomDateTime();
  String ticketType;

  void setTicket(File tc, String tType) {
    ticket = tc;
    ticketType = tType;
  }

  void getTicketType() {
    print(ticketType);
  }

  @override
  void initState() {
    dragDownRegister();
    travelDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.location_city),
            title: TextField(
              decoration: InputDecoration(hintText: 'Source City'),
              onChanged: (value) {
                source = value;
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: TextField(
              decoration: InputDecoration(hintText: 'Destination City'),
              onChanged: (value) {
                destination = value;
              },
            ),
          ),
          GestureDetector(
            onTap: () async {
              travelDate = await showDatePicker(
                  context: context,
                  initialDate: travelDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2023),
                  helpText: 'Travel Date',
                  selectableDayPredicate: cdt.decideWhichDayToEnableStart);
              setState(() {});
            },
            child: ListTile(
              leading: Icon(Icons.date_range),
              title: Text('Travel Date :'),
              trailing: Text('${travelDate.toLocal()}'.split(' ')[0]),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Mode :'),
            trailing: getPicker(),
          ),
        ],
      ),
    );
  }

  DropdownButton<String> getAndroidPicker() {
    return DropdownButton<String>(
      value: selectedMode,
      onChanged: (value) {
        setState(() {
          selectedMode = value;
        });
      },
      items: ls,
    );
  }

  CupertinoPicker getIOSPicker() {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMode = mot[value];
        });
      },
      children: ls,
    );
  }

  Widget getPicker() {
    if (Platform.isIOS)
      return getIOSPicker();
    else
      return getAndroidPicker();
  }

  void dragDownRegister() {
    ls = [];
    for (String mOT in mot) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(mOT),
        value: mOT,
      );
      ls.add(dm);
    }
  }
}
