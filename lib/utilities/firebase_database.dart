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
      "imgURL": imgURL
    };
    ref_event_nr
        .set(event)
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

  static Future<List<dynamic>> getClubIds() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('clubs');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    List<dynamic> Email =
        querySnapshot.docs.map((doc) => doc['email']).toList();
    return Email;
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
}
