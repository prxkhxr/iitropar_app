// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/frequently_used.dart';

class firebaseDatabase {
  static void addEventFB(
      String eventTitle,
      String eventType,
      String eventDesc,
      String eventVenue,
      String date,
      String startTime,
      String endTime,
      String? imgURL,
      String creator) {
    String docName = eventTitle + date.replaceAll('/', '-');
    DocumentReference ref_event_nr = FirebaseFirestore.instance
        .collection("Event.nonrecurring")
        .doc(docName);
    Map<String, dynamic> event = {
      "eventTitle": eventTitle,
      "eventType": eventType,
      "eventDesc": eventDesc,
      "eventVenue": eventVenue,
      "eventDate": date,
      "startTime": startTime,
      "endTime": endTime,
      "imgURL": imgURL,
      "creator": creator
    };
    ref_event_nr
        .set(event)
        .then((value) => print("event added"))
        .catchError((error) => print("failed to add event.\n ERROR =  $error"));
  }

  static Future<List<dynamic>> getStudents(String courseID) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('courses');
    QuerySnapshot querySnapshot = await collectionRef.get();
    int len = querySnapshot.docs.length;
    List<dynamic> students = [];
    for (int i = 0; i < len; i++) {
      List<dynamic> courses = querySnapshot.docs[i]['courses'];
      if (courses.contains(courseID)) {
        students.add(querySnapshot.docs[i].id);
      }
    }
    return students;
  }

  static void updateFaculty(faculty f) {
    DocumentReference ref_f =
        FirebaseFirestore.instance.collection("faculty").doc(f.name);
    ref_f.update({'courses': f.courses}).then((value) {
      print("faculty courses of ${f.name} updated");
    });
  }

  static void addHolidayFB(String date, String desc) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
        FirebaseFirestore.instance.collection('holidays').doc(docName);
    Map<String, String> holiday = {"date": date, "desc": desc};
    doc_ref
        .set(holiday)
        .then((value) => print("holiday added successfully"))
        .catchError(
            (error) => print("failed to add holiday.\n ERROR = $error "));
  }

  static Future<List<holidays>> getHolidayFB() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('holidays');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<holidays> hols = [];
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      hols.add(holidays(
          querySnapshot.docs[i]['date'], querySnapshot.docs[i]['desc']));
    }
    return hols;
  }

  static void switchTimetableFB(String date, String day) {
    String docName = date.replaceAll('/', '-');
    DocumentReference doc_ref =
        FirebaseFirestore.instance.collection('switchTimetable').doc(docName);
    Map<String, String> switchTimetable = {
      "date": date,
      "day_to_be_followed": day
    };
    doc_ref
        .set(switchTimetable)
        .then((value) => print("added successfully"))
        .catchError((error) => print("failed to add data.\n ERROR = $error "));
  }

  static Future<List<changedDay>> getChangedDays() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('switchTimetable');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<changedDay> changedDays = [];
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      changedDays.add(changedDay(querySnapshot.docs[i]['date'],
          querySnapshot.docs[i]['day_to_be_followed']));
    }
    return changedDays;
  }

  static void addCourseFB(String entryNumber, List<dynamic> courses) {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("courses").doc(entryNumber);
    Map<String, dynamic> crs = {"courses": courses};
    ref_event_nr
        .set(crs)
        .then((value) => print("courses added"))
        .catchError((error) => print("failed to add courses: $error"));
  }

  static void registerFacultyFB(faculty f) {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("faculty").doc(f.name);
    Map<String, dynamic> faculty = {
      "name": f.name,
      "dep": f.department,
      "email": f.email,
      "courses": f.courses
    };
    ref_event_nr
        .set(faculty)
        .then((value) => print("Faculty added"))
        .catchError((error) => print("failed to add faculty: $error"));
  }

  static void registerClubFB(String clubTitle, String clubDesc, String email) {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("clubs").doc(clubTitle);
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

  static Future<List<dynamic>> getClubIds() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<dynamic> emails =
        querySnapshot.docs.map((doc) => doc['email']).toList();
    return emails;
  }

  static Future<List<dynamic>> getFacultyIDs() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    List<dynamic> emails =
        querySnapshot.docs.map((doc) => doc['email']).toList();
    return emails;
  }

  static Future<String> getClubName(String clubEmail) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Get data from docs and convert map to List
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      if (querySnapshot.docs[i]['email'] == clubEmail) {
        return querySnapshot.docs[i]['clubTitle'];
      }
    }
    return "noclub";
  }

  static Future<faculty> getFacultyDetail(String email) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();
    List<String> details = [];
    // Get data from docs and convert map to List
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      if (querySnapshot.docs[i]['email'] == email) {
        faculty f = faculty(
            querySnapshot.docs[i]['name'],
            querySnapshot.docs[i]['dep'],
            querySnapshot.docs[i]['email'],
            Set.from(querySnapshot.docs[i]['courses']));
        return f;
      }
    }
    faculty f = faculty("", "", "", Set());
    return f;
  }

  static Future<List<faculty>> getFaculty() async {
    List<faculty> fc = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('faculty');
    QuerySnapshot querySnapshot = await collectionRef.get();
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      faculty fc_member = faculty(
          querySnapshot.docs[i]['name'],
          querySnapshot.docs[i]['dep'],
          querySnapshot.docs[i]['email'],
          Set.from(querySnapshot.docs[i]['courses']));
      fc.add(fc_member);
    }
    return fc;
  }

  static Future<List<String>> getCourses(String entryNumber) async {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("courses").doc(entryNumber);
    bool hasCourses = await checkIfDocExists("courses", entryNumber);
    if (!hasCourses) {
      return [];
    }
    DocumentSnapshot snapshot = await ref_event_nr.get();
    List<String> courses = List.from(snapshot['courses']);
    return courses;
  }

  static Future<List<Event>> getEvents(DateTime date) async {
    List<Event> events = [];
    var snapshots =
        await FirebaseFirestore.instance.collection('Event.nonrecurring').get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      var doc = snapshots.docs[i];
      String doc_eventDate0 = doc["eventDate"];
      List<String> date_split = doc_eventDate0.split('/');
      DateTime doc_eventDate = DateTime(
        int.parse(date_split[2]),
        int.parse(date_split[1]),
        int.parse(date_split[0]),
      );
      if (doc_eventDate.year == date.year &&
          doc_eventDate.month == date.month &&
          doc_eventDate.day == date.day) {
        Event e = Event(
            title: doc['eventTitle'],
            desc: doc['eventDesc'],
            stime: str2tod(doc['startTime']),
            etime: str2tod(doc['endTime']),
            // displayDate: doc['eventDate'],
            creator: doc['creator']); //TODO : add image as well to Event
        events.add(e);
      }
    }
    return events;
  }

  static Future<String> emailCheck(String email) async {
    var fsnapshots =
        await FirebaseFirestore.instance.collection("faculty").get();
    var csnapshots = await FirebaseFirestore.instance.collection("clubs").get();
    for (int i = 0; i < fsnapshots.docs.length; i++) {
      var doc = fsnapshots.docs[i];
      if (doc['email'] == email) return "faculty";
    }
    for (int i = 0; i < csnapshots.docs.length; i++) {
      var doc = csnapshots.docs[i];
      if (doc['email'] == email) return "club";
    }
    return "";
  }

  static Future<bool> checkIfDocExists(
      String collectionName, String docId) async {
    try {
      // Get reference to Firestore collection
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection(collectionName)
          .doc(docId)
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> addExtraClass(ExtraClass c) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(c.courseID)
        .doc(
            '${c.courseID}-${dateString(c.date).replaceAll('/', '-')}-${TimeString(c.startTime)}-${TimeString(c.endTime)}');
    Map<String, dynamic> exClass = {
      "courseID": c.courseID,
      "date": dateString(c.date),
      "startTime": TimeString(c.startTime),
      "endTime": TimeString(c.endTime),
      "venue": c.venue,
      "desc": c.description
    };
    docRef.set(exClass);
    return true;
  }

  static Future<List<ExtraClass>> getExtraClass(String courseID) async {
    List<ExtraClass> ec = [];

    var snapshots = await FirebaseFirestore.instance.collection(courseID).get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      var doc = snapshots.docs[i];

      DateTime date = stringDate(doc["date"]);
      TimeOfDay startTime = StringTime(doc["startTime"]);
      TimeOfDay endTime = StringTime(doc["endTime"]);
      String description = doc["desc"];
      String venue = doc["venue"];
      ExtraClass new_c = ExtraClass(
          courseID: courseID,
          date: date,
          startTime: startTime,
          endTime: endTime,
          description: description,
          venue: venue);
      ec.add(new_c);
    }
    return ec;
  }

  static void deleteClass(ExtraClass c) {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(c.courseID)
        .doc(
            '${c.courseID}-${dateString(c.date).replaceAll('/', '-')}-${TimeString(c.startTime)}-${TimeString(c.endTime)}');
    docRef.delete().then((value) {
      print('Document deleted successfully.');
    }).catchError((error) {
      print('Error deleting document: $error');
    });
  }
}
