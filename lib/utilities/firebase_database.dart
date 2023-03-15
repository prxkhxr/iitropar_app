import 'package:cloud_firestore/cloud_firestore.dart';

class firebaseDatabase {
  static void addEventFB(
      String eventTitle,
      String eventType,
      String eventDesc,
      String eventVenue,
      String date,
      String startTime,
      String endTime,
      String? imgURL) {
    CollectionReference ref_event_nr =
        FirebaseFirestore.instance.collection("Event.nonrecurring");
    Map<String, dynamic> event = {
      "eventTitle": eventTitle,
      "eventType": eventType,
      "eventDesc": eventDesc,
      "eventVenue": eventVenue,
      "eventDate": date,
      "startTime": startTime,
      "endTime": endTime,
      "imgURL": imgURL
    };
    ref_event_nr
        .add(event)
        .then((value) => print("event added"))
        .catchError((error) => print("failed to add event: $error"));
  }
}
