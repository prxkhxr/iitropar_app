// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:intl/intl.dart';

import 'database/local_db.dart';

DateTime getTodayDateTime() {
  return DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
}

String TimeString(TimeOfDay t) {
  return "${t.hour}:${t.minute}";
}

TimeOfDay StringTime(String t) {
  List<String> t_split = t.split(':');
  return TimeOfDay(hour: int.parse(t_split[0]), minute: int.parse(t_split[1]));
}

List<String> allCourses = [
  'CE403',
  'CE302',
  'CE405',
  'CE406',
  'CE407',
  'CP301',
  'CP302',
  'NO103',
  'CE602',
  'CE552',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CH304',
  'CH305',
  'CH331',
  'CH420',
  'CP301',
  'CP302',
  'NO103',
  'CH507',
  'CH506',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'PH451',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CS304',
  'CS201',
  'CS305',
  'CS301',
  'CS306',
  'CS101',
  'CP301',
  'CP302',
  'NO103',
  'CS616',
  'CS517',
  'CS535',
  'CS539',
  'CS604',
  'CS503',
  'CS201',
  'CS533',
  'MA102',
  'CS543',
  'MA102',
  'CS546',
  'CS201',
  'CS550',
  'CS531',
  'CS204',
  'CS712',
  'CS603',
  'CS302',
  'CS536',
  'CS549',
  'CS521',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA517',
  'MA421',
  'PH457',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CP301',
  'EE309',
  'EE307',
  'EE306',
  'EE304',
  'EE308',
  'EE310',
  'HS104',
  'GE111',
  'CP302',
  'NO103',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA517',
  'MA302',
  'MA421',
  'PH457',
  'PH451',
  'PH612',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'EE639',
  'EE628',
  'EE647',
  'EE536',
  'EE646',
  'EE661',
  'EE531',
  'CP301',
  'MA302',
  'MA303',
  'CS503',
  'CS201',
  'CP302',
  'NO103',
  'MA703',
  'MA628',
  'MA605',
  'MA516',
  'MA629',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'ME304',
  'ME201',
  'ME305',
  'GE102',
  'ME306',
  'ME301',
  'ME307',
  'ME303',
  'ME308',
  'GE201',
  'CP301',
  'GE111',
  'HS104',
  'CP302',
  'NO103',
  'ME472',
  'ME504',
  'ME512',
  'ME515',
  'ME542',
  'ME576',
  'ME580',
  'ME505',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA302',
  'MA424',
  'PH457',
  'PH451',
  'PH612',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'MM306',
  'MM307',
  'MM308',
  'MM309',
  'MM310',
  'MM311',
  'CP301',
  'GE111',
  'HS104',
  'CP302',
  'NO103',
  'MM431',
  'GE201',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516'
];
List<DropdownMenuItem<String>> departments = [
  const DropdownMenuItem(
      value: "BioMedical Engineering", child: Text("BioMedical Engineering")),
  const DropdownMenuItem(
      value: "Chemical Engineering", child: Text("Chemical Engineering")),
  const DropdownMenuItem(
      value: "Civil Engineering", child: Text("Civil Engineering")),
  const DropdownMenuItem(
      value: "Electrical Engineering", child: Text("Electrical Engineering")),
  const DropdownMenuItem(
      value: "Computer Science & Engineering",
      child: Text("Computer Science & Engineering")),
  const DropdownMenuItem(
      value: "Metallurgical and Materials Engineering",
      child: Text("Metallurgical and Materials Engineering")),
  const DropdownMenuItem(value: "Chemistry", child: Text("Chemistry")),
  const DropdownMenuItem(value: "Physics", child: Text("Physics")),
  const DropdownMenuItem(value: "Mathematics", child: Text("Mathematics")),
  const DropdownMenuItem(
      value: "Humanities and Social Sciences",
      child: Text("Humanities and Social Sciences")),
];
String dateString(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(d);
}

DateTime stringDate(String d) {
  int year = int.parse(d.substring(0, 4));
  int month = int.parse(d.substring(5, 7));
  int day = int.parse(d.substring(8, 10));
  return DateTime(year, month, day);
}

class holidays {
  late DateTime date;
  late String desc;
  holidays(date, this.desc) {
    this.date = DateFormat('yyyy-MM-dd').parse(date);
  }
}

class changedDay {
  late DateTime date;
  late String day_to_followed;
  changedDay(date, this.day_to_followed) {
    this.date = DateFormat('yyyy-MM-dd').parse(date);
  }
}

class faculty {
  late String name;
  late String department;
  late String email;
  late Set<dynamic> courses;
  faculty(name, dep, email, courses) {
    this.name = name;
    this.department = dep;
    this.email = email;
    this.courses = courses;
  }
}

class Ids {
  static List<String> admins = [
    "taklubalm@gmail.com",
    "2020csb1086@iitrpr.ac.in",
    // "jugalchap123@gmail.com",
    "2020csb1073@iitrpr.ac.in",
    "2020csb1111@iitrpr.ac.in",
    "guptajatin918@gmail.com"
  ];
  static Future<List<dynamic>> fclub = firebaseDatabase.getClubIds();
  static Future<List<dynamic>> faculty = firebaseDatabase.getFacultyIDs();

  static String role = "guest";
  static bool assigned = false;
  static String name = ""; //only for faculty
  static String dep = ""; //only for faculty

  static Future<String> resolveUser() async {
    if (assigned == true) return role;
    String user;
    if (FirebaseAuth.instance.currentUser == null) {
      user = "guest";
      role = user;
      assigned = true;
      return role;
    }
    return _emailCheck(FirebaseAuth.instance.currentUser!.email!);
  }

  static Future<String> _emailCheck(String email) async {
    String check1 = await firebaseDatabase.emailCheck(email);
    if (check1 != "") {
      role = check1;
      assigned = true;
      return check1;
    }

    if (email.endsWith("iitrpr.ac.in")) {
      role = "student";
      assigned = true;
      return "student";
    }

    assigned = true;
    return "guest";
  }
}

class MenuItem {
  String name;
  String description;

  MenuItem(this.name, this.description);
}

class Menu {
  static Map<String, List<MenuItem>> menu = {
    'Monday': [
      MenuItem('Breakfast',
          'Aloo Sabji, Paratha, Sprouts, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem('Lunch', 'Veg Biryani, Chana Masala, Chapati, Salad'),
      MenuItem('Dinner',
          'Seasonal Vegetable Curry, Chana Dal, Rice-Chapati, Salad, Rasmalai')
    ],
    'Tuesday': [
      MenuItem('Breakfast',
          'Uttapam, Sambar, Coconut Chutney, Cornflakes, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem(
          'Lunch', 'Aloo Gobi, Dal makhani, Jeera Rice, Chapati, Curd, Salad'),
      MenuItem('Dinner', 'Besan Gatte, Dal Tadka, Rice-Chapati, Salad, Jalebi')
    ],
    'Wednesday': [
      MenuItem('Breakfast',
          'Mix Parantha, Fruit/Boiled Eggs, Green Chutney, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem(
          'Lunch', 'Black Chana, Puri, Mix Dal, Curd,  Rice-Chapati, Salad'),
      MenuItem('Dinner',
          'Kadai Chicken/Matar Paneer, Green Moong Dal, Rice-Chapati, Salad, Laddu')
    ],
    'Thursday': [
      MenuItem('Breakfast',
          'Puri, White Chole, Dalia(Sweet), Sprouts, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem(
          'Lunch', 'Kadi-Pakoda, Alu Jeera, Jeera rice, Papad, Chapati, Salad'),
      MenuItem('Dinner',
          'Ajwain Parantha, Chole, Cabbage Peas, Rice, Salad, Ice-Cream')
    ],
    'Friday': [
      MenuItem('Breakfast',
          'Seviyan, Upma, Sweet Corn, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem('Lunch', 'Mix Veg, Masoor Dal, Curd, Rice-Chapati, Salad'),
      MenuItem('Dinner',
          'Chole Paneer, Chicken do pyaza, Chana Dal, Rice-Chapati, Salad, Gulab Jamun')
    ],
    'Saturday': [
      MenuItem('Breakfast',
          'Ajwain Parantha, Black Chana, Fruit/boiled-egg, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem('Lunch',
          'Chole Bhature, Aloo Capsicum, Jeera Rice, Boondi-Raita, Chapati, Salad, Chutney'),
      MenuItem('Dinner', 'Lauki Sabji, Dal Tadka, Rice, Salad, Suji Halwa')
    ],
    'Sunday': [
      MenuItem('Breakfast',
          'Dosa, Sambhar, Coconut Chutney, Fruit/boiled-egg, Bread-Butter-Jam, Milk-Tea-Coffee'),
      MenuItem('Lunch', 'Rajma, Aloo Sabji, Rice-Chapati, Papad, Curd, Salad'),
      MenuItem('Dinner',
          'Butter Chicken, Paneer Butter Masala, Black Urad Dal, Rice-Chapati, Tandoori Roti, Salad, Ice Cream')
    ],
  };
}

Widget AdminCard(BuildContext context, Widget route, String text) {
  return CupertinoButton(
    child: Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(primaryLight),
            // Colors.amber,
            Colors.black.withOpacity(0.69)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
  );
}

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //const CircularProgressIndicator(),
                    Image.asset('assets/iitropar_logo.png',
                    height: 200,
                    ),
                    const SizedBox(
                      height: 5,
                      width: 100,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                      ),
                    ),
                    Text((_msg != null) ? _msg! : 'Loading...'),
                  ],
                ),
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

Future<bool> _signout() async {
  if (Ids.role == 'student') {
    await EventDB().deleteOf('course');
    await EventDB().deleteOf('exam');
  }
  await FirebaseServices().signOut();
  return true;
}

Widget signoutButtonWidget(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.logout_rounded),
    color: Color(primaryLight),
    iconSize: 28,
    onPressed: () {
      LoadingScreen.setTask(_signout);
      LoadingScreen.setPrompt('Signing Out');
      LoadingScreen.setBuilder((context) => const RootPage());
      RootPage.signin(true);

      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
              builder: LoadingScreen.build,
              settings: const RouteSettings(name: '/')));
    },
  );
}

Widget themeButtonWidget() {
  return IconButton(
    onPressed: () {},
    icon: const Icon(
      Icons.wb_sunny_rounded,
    ),
    color: Color(primaryLight),
    iconSize: 28,
  );
}

TextStyle appbarTitleStyle() {
  return TextStyle(
      color: Color(primaryLight),
      // fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5);
}

Row buildTitleBar(String text, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      themeButtonWidget(),
      Flexible(
        child: SizedBox(
          height: 30,
          child: FittedBox(
            child: Text(
              text,
              style: appbarTitleStyle(),
            ),
          ),
        ),
      ),
      signoutButtonWidget(context),
    ],
  );
}

class ExtraClass {
  String venue;
  String description;
  String courseID;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  ExtraClass(
      {required this.courseID,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.description,
      required this.venue});
}
