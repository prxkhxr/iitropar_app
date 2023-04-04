import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
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
            trailing: const Icon(Icons.favorite_outline),
          ),
          Center(
              child: img_url == null
                  ? const SizedBox(height: 20)
                  : Image.network(img_url,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(height: 20))),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Venue : $eventVenue'),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Desc : $eventDesc'),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Date : $date'),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
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
        // drawer: const NavDrawer(),
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
                            String _doc_eventDate = doc["eventDate"];
                            List<String> date_split = _doc_eventDate.split('/');
                            DateTime doc_eventDate = DateTime(
                              int.parse(date_split[2]),
                              int.parse(date_split[1]),
                              int.parse(date_split[0]),
                            );
                            print(doc_eventDate);
                            print(doc["eventDate"]);
                            if (doc_eventDate.year == _selectedDate!.year &&
                                doc_eventDate.month == _selectedDate!.month &&
                                doc_eventDate.day == _selectedDate!.day) {
                              return eventWidget(
                                  doc["eventTitle"],
                                  doc["eventType"],
                                  doc["eventDesc"],
                                  doc["eventVenue"],
                                  doc["eventDate"],
                                  doc["startTime"],
                                  doc["endTime"],
                                  doc["imgURL"]);
                            } else {
                              return Container();
                            }
                          });
                    } else {
                      return Container();
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
                  if (date == null) return;
                  setState(() {
                    _selectedDate = date;
                  });
                });
              },
              child: const Text("Select Date"),
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
