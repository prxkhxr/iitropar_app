import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:iitropar/utilities/firebase_database.dart';

//to do build a function to access all the events
class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

// bool checkIfImage(String param) {
//   if (param == 'image/jpeg' || param == 'image/png' || param == 'image/gif') {
//     return true;
//   }
//   return false;
// }

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
            subtitle: Text(eventDesc),
            trailing: Icon(Icons.favorite_outline),
          ),
          Center(
              child: Image.network(
            img_url!,
            errorBuilder: (context, error, stackTrace) =>
                Image.asset("assets/user.jpg"),
          )),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text('Venue : $eventVenue'),
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
                            return eventWidget(
                                doc["eventTitle"],
                                doc["eventType"],
                                doc["eventDesc"],
                                doc["eventVenue"],
                                doc["eventDate"],
                                doc["startTime"],
                                doc["endTime"],
                                doc["imgURL"]);
                          });
                    } else {
                      return Text('No Event');
                    }
                  }),
            ),
          ],
        )); // Generated code for this Row Widget...
  }
}
