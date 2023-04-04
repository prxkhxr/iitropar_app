import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';

String dateString(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(d);
}

DateTime stringDate(String d) {
  int year = int.parse(d.substring(0, 4));
  int month = int.parse(d.substring(5, 7));
  int day = int.parse(d.substring(8, 10));
  return DateTime(year, month, day);
}

class Ids {
  static List<String> admins = [
    "2020csb1082@iitrpr.ac.in",
    "2020csb1086@iitrpr.ac.in"
  ];
  static Future<List<dynamic>> fclub = firebaseDatabase.getClubIds();
  static String role = "guest";
  static bool assigned = false;

  static Future<String> resolveUser() async {
    if (assigned == true) return role;
    String user;
    var clubEmails = await Ids.fclub;
    if (FirebaseAuth.instance.currentUser != null &&
        admins.contains(FirebaseAuth.instance.currentUser!.email)) {
      user = "admin";
    } else if (FirebaseAuth.instance.currentUser != null &&
        clubEmails.contains(FirebaseAuth.instance.currentUser!.email)) {
      user = "club";
    } else if (FirebaseAuth.instance.currentUser != null) {
      user = "student";
    } else {
      user = "guest";
    }
    role = user;
    assigned = true;
    return role;
  }
}

// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});

//   @override
//   State<LoadingScreen> createState() => _LoadingScreenState();
// }

// class _LoadingScreenState extends State<LoadingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

class LoadingScreen {
  static Future<bool> Function()? _task;
  static String? _msg;
  static Widget Function(BuildContext) _builder =
      (context) => const Placeholder();

  LoadingScreen._privatConstructor();

  static void setPrompt(String message) {
    _msg = message;
  }

  static void setTask(Future<bool> Function() task) {
    _task = task;
  }

  static void setBuilder(Widget Function(BuildContext context) builder) {
    _builder = builder;
  }

  static bool isLoaded = false;

  static Widget build(BuildContext context) {
    return FutureBuilder(
      future: _task!(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Expanded(
            child: Scaffold(
              body: Center(
                child: Column(children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 15,
                  ),
                  Text((_msg != null) ? _msg! : 'Loading...'),
                ]),
              ),
            ),
          );
        } else {
          return _builder(context);
        }
      },
    );
  }
}
