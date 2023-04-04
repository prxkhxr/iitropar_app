import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitropar/database/event.dart';

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
    String docName = "$eventTitle" + date.replaceAll('/', '-');
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
        .catchError((error) => print("failed to add event: $error"));
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
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    List<dynamic> emails =
        querySnapshot.docs.map((doc) => doc['email']).toList();
    return emails;
  }

  static Future<String> getClubName(String clubEmail) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    var len = querySnapshot.docs.length;
    for (int i = 0; i < len; i++) {
      if (querySnapshot.docs[i]['email'] == clubEmail) {
        return querySnapshot.docs[i]['clubTitle'];
      }
    }
    return "noclub";
  }

  static Future<List<String>> getCourses(String entryNumber) async {
    DocumentReference ref_event_nr =
        FirebaseFirestore.instance.collection("courses").doc(entryNumber);
    DocumentSnapshot snapshot = await ref_event_nr.get();
    List<String> courses = List.from(snapshot['courses']);
    return courses;
  }

  static Future<List<Event>> getEvents(DateTime date) async {
    List<Event> events = [];
    var snapshots =
        await FirebaseFirestore.instance.collection('Event.nonrecurring').get();
    for (int i = 0; i < snapshots.docs.length; i++) {
      var doc = snapshots.docs[0];
      String _doc_eventDate = doc["eventDate"];
      List<String> date_split = _doc_eventDate.split('/');
      DateTime doc_eventDate = DateTime(
        int.parse(date_split[2]),
        int.parse(date_split[1]),
        int.parse(date_split[0]),
      );
      if (doc_eventDate.year == date.year &&
          doc_eventDate.month == date.month &&
          doc_eventDate.day == date.day) {
        Event e = Event.singular(
            title: doc['eventTitle'],
            description: doc['eventDesc'],
            stime: doc['startTime'],
            etime: doc['endTime'],
            displayDate: doc['eventDate'],
            creator: doc['creator']); //TODO : add image as well to Event
        events.add(e);
      }
    }
    return events;
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
      throw e;
    }
  }
}
