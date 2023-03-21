import 'dart:ffi';

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

  static void addCourseFB(String entryNumber, List<dynamic> Courses) {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("courses").doc("$entryNumber");
    Map<String, dynamic> courses = {"courses": Courses};
    ref_event_nr
        .set(courses)
        .then((value) => print("courses added"))
        .catchError((error) => print("failed to add courses: $error"));
  }

  static void registerClubFB(String clubTitle, String clubDesc, String email) {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("clubs").doc("$clubTitle");
    Map<String, dynamic> clubs = {
      "clubTitle": clubTitle,
      "clubDesc": clubDesc,
      "email": email,
    };
    ref_event_nr
        .set(clubs)
        .then((value) => print("Club added"))
        .catchError((error) => print("failed to add clubs: $error"));
  }

  static Future<List<dynamic>> getCourses(String entryNumber) async {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("courses").doc("$entryNumber");
    DocumentSnapshot snapshot = await ref_event_nr.get();
    List<dynamic> courses = List.from(snapshot['courses']);
    return courses;
  }
}
