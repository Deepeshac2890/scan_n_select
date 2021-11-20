import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:scan_n_select/Components/CustomTicketListItem.dart';
import 'package:scan_n_select/Services/DateTimeServices.dart';

class CreateTrip extends StatefulWidget {
  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  CustomDateTime cdt = CustomDateTime();
  List<Widget> cityList = [];
  int cityCounter = 0;
  int ticketCounter = 0;
  List<Widget> ticketList = [];
  ScrollController ticketListViewController = ScrollController();
  ScrollController cityListViewController = ScrollController();
  List<TextEditingController> cityControllers = [];
  List<TextEditingController> sourceCityTicketControllers = [];
  List<TextEditingController> destinationCityTicketControllers = [];
  List<TextEditingController> dateTicketControllers = [];

  @override
  void initState() {
    startDate = DateTime.now();
    endDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Add Trip'),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Card(
          elevation: 20,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  var startingDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2021),
                      lastDate: DateTime(2023),
                      helpText: 'Start Date',
                      selectableDayPredicate: cdt.decideWhichDayToEnableStart);
                  if (startingDate != null) {
                    setState(() {
                      startDate = startingDate;
                      cdt.setStartDate(startDate);
                      if (startDate.isAfter(endDate)) endDate = startingDate;
                    });
                  }
                },
                child: ListTile(
                  trailing: Text('${startDate.toLocal()}'.split(' ')[0]),
                  leading: Icon(Icons.date_range),
                  title: Text('Start Date'),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  var endingDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      helpText: 'End Date',
                      firstDate: DateTime(2021),
                      lastDate: DateTime(2023),
                      selectableDayPredicate: cdt.decideWhichDayToEnableEnd);
                  if (endingDate != null) {
                    setState(() {
                      endDate = endingDate;
                    });
                  }
                },
                child: ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text('End Date'),
                  trailing: Text('${endDate.toLocal()}'.split(' ')[0]),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: Text('Cities : '),
                trailing: TextButton(
                    onPressed: () {
                      addCityListRow();
                    },
                    child: Icon(Icons.add)),
              ),
              Flexible(
                child: ListView.builder(
                    controller: cityListViewController,
                    itemCount: cityList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        background: Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerRight,
                          color: Colors.redAccent,
                          child: Icon(Icons.delete),
                        ),
                        key: UniqueKey(),
                        child: cityList[index],
                        onDismissed: (direction) {
                          setState(() {
                            cityList.removeAt(index);
                          });
                        },
                        direction: DismissDirection.endToStart,
                      );
                    }),
              ),
              ListTile(
                leading: Icon(Icons.article),
                title: Text('Tickets : '),
                trailing: TextButton(
                    onPressed: () {
                      addTicketListRow();
                    },
                    child: Icon(Icons.add)),
              ),
              Flexible(
                child: ListView.builder(
                    controller: ticketListViewController,
                    itemCount: ticketList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        background: Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerRight,
                          color: Colors.redAccent,
                          child: Icon(Icons.delete),
                        ),
                        key: UniqueKey(),
                        child: ticketList[index],
                        onDismissed: (direction) {
                          setState(
                            () {
                              ticketList.removeAt(index);
                            },
                          );
                        },
                        direction: DismissDirection.endToStart,
                      );
                    }),
              ),
              Center(
                child: TextButton(
                  child: Text('Submit'),
                  onPressed: () {
                    addTrip();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTrip() async {
    // TODO: Implement this
  }

  void addCityListRow() async {
    TextEditingController cn = TextEditingController();
    Widget wd = ListTile(
      key: UniqueKey(),
      leading: Icon(Icons.circle),
      title: TextField(
        controller: cn,
        onChanged: (value) {
          print(value);
        },
      ),
    );
    setState(() {
      cityList.add(wd);
      cityControllers.add(cn);
    });
    cityCounter++;
    await cityListViewController.animateTo(
        cityListViewController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  void addTicketListRow() async {
    File file = await FilePicker.getFile();
    final mimeType = mime(file.path.split('/').last);
    List<String> mot = ['Bus', 'Train', 'Flight'];
    String selectedMode = 'Bus';
    String source = "";
    String destination = "";
    DateTime travelDate = DateTime.now();
    List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];
    CustomDateTime cdt = CustomDateTime();
    String ticketType;
    Widget wd = new CustomTicketListItem();
    setState(() {
      ticketList.add(wd);
    });
    await ticketListViewController.animateTo(
        ticketListViewController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
    ticketCounter++;
  }
}
