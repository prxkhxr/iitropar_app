import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';

//to do build a function to access all the events
class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

Card eventWidget(
    String eventTitle,
    String eventType,
    String eventDesc,
    String eventVenue,
    String date,
    String startTime,
    String endTime,
    String? img_url) {
  return Card(
      elevation: 4.0,
      child: Column(
        children: [
          ListTile(
            title: Text(eventTitle),
            subtitle: Text(eventType),
            trailing: Icon(Icons.favorite_outline),
          ),
          Center(
              child: Image.network(img_url!,
                  errorBuilder: (context, error, stackTrace) =>
                      SizedBox(height: 20))),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Venue : $eventVenue'),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Desc : $eventDesc'),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Date : $date'),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Timing : $startTime - $endTime'),
          ),
          ButtonBar(
            children: [
              TextButton(
                child: const Text('SET Alert'),
                onPressed: () {/* ... */},
              ),
            ],
          )
        ],
      ));
}

class _EventsState extends State<Events> {
  DateTime? _selectedDate;

  _EventsState() {
    _selectedDate = DateTime.now();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Events"),
        ),
        drawer: const NavDrawer(),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Event.nonrecurring")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            String eventDate =
                                "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
                            print(eventDate);
                            print(doc["eventDate"]);
                            if (eventDate == doc["eventDate"])
                              return eventWidget(
                                  doc["eventTitle"],
                                  doc["eventType"],
                                  doc["eventDesc"],
                                  doc["eventVenue"],
                                  doc["eventDate"],
                                  doc["startTime"],
                                  doc["endTime"],
                                  doc["imgURL"]);
                            else {
                              return Container();
                            }
                          });
                    } else {
                      return Text('No Event');
                    }
                  }),
            ),
          ],
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100))
                    .then((date) {
                  setState(() {
                    _selectedDate = date!;
                  });
                });
              },
              child: Text("Select Date"),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selectedDate != null) {
                    _selectedDate =
                        _selectedDate!.subtract(const Duration(days: 1));
                  }
                });
              },
              icon: const Icon(Icons.arrow_left),
            ),
            Text(DateFormat('dd-MM-yyyy').format(_selectedDate!)),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selectedDate != null) {
                    _selectedDate = _selectedDate!.add(const Duration(days: 1));
                  }
                });
              },
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        )); // Generated code for this Row Widget...
  }
}
