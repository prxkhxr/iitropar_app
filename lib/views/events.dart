// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:intl/intl.dart';

//to do build a function to access all the events
class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

Widget EventCard(
    BuildContext context,
    String eventTitle,
    String eventType,
    String eventDesc,
    String eventVenue,
    String date,
    String startTime,
    String endTime,
    String? img_url) {
  double swidth = MediaQuery.of(context).size.width;
  swidth /= 410;
  print(startTime);
  print(endTime);
  return Container(
    padding: EdgeInsets.all(10 * swidth),
    margin: EdgeInsets.all(15 * swidth),
    decoration: BoxDecoration(
        color: Colors.blueGrey[100], borderRadius: BorderRadius.circular(10)),
    child: InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Column(
                  children: [
                    img_url == null
                        ? const SizedBox(height: 5)
                        : Image.network(img_url,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(height: 20)),
                    Text(
                      eventTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                    Text(
                      "Event Type : $eventType",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.all(20),
                children: [
                  const Text("Description",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(eventDesc),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Venue",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(eventVenue),
                ],
              );
            });
      },
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(5 * swidth),
          decoration: BoxDecoration(
            color: Colors.amberAccent[100],
            borderRadius: BorderRadius.circular(10),
          ),
          height: 70 * swidth,
          width: 70 * swidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 15,
                child: FittedBox(
                  child: Text(
                    date,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 26,
                child: FittedBox(
                  child: Text(
                    startTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: 10 * swidth,
        ),
        SizedBox(
          height: 70 * swidth,
          width: 200 * swidth,
          // color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 26,
                child: FittedBox(
                  child: Text(
                    eventTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 3.69,
              ),
              Flexible(
                  child: Text(
                eventDesc,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )),
            ],
          ),
        ),
        SizedBox(
          width: 10 * swidth,
        ),
        Container(
          padding: EdgeInsets.all(5 * swidth),
          decoration: BoxDecoration(
            color: Colors.greenAccent[100],
            borderRadius: BorderRadius.circular(10),
          ),
          height: 70 * swidth,
          width: 70 * swidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 15, child: FittedBox(child: Text(eventType))),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 26,
                child: FittedBox(
                    child: Text(
                  endTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              )
            ],
          ),
        ),
      ]),
    ),
  );
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
            child: Text(
              'Venue : $eventVenue',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Desc : $eventDesc',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Date : $date',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Timing : $startTime - $endTime',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ButtonBar(
          //   children: [
          //     TextButton(
          //       child: const Text('SET Alert'),
          //       onPressed: () {/* ... */},
          //     ),
          //   ],
          // )
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
          toolbarHeight: 50,
          title: buildTitleBar("EVENTS", context),
          elevation: 0,
          backgroundColor: Color(secondaryLight),
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
                            String doc_eventDate0 = doc["eventDate"];
                            List<String> date_split = doc_eventDate0.split('/');
                            DateTime doc_eventDate = DateTime(
                              int.parse(date_split[2]),
                              int.parse(date_split[1]),
                              int.parse(date_split[0]),
                            );
                            if (doc_eventDate.year == _selectedDate!.year &&
                                doc_eventDate.month == _selectedDate!.month &&
                                doc_eventDate.day == _selectedDate!.day) {
                              return EventCard(
                                  context,
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
        backgroundColor: Colors.blueGrey[50],
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Color(primaryLight)),
              ),
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
