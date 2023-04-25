// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
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
  'CS301',
  'CS304',
  'CS306',
  'HS301',
  'CS305',
  'CS306',
  'CP301',
  'CS503',
  'CS535'
];
List<DropdownMenuItem<String>> departments = [
  const DropdownMenuItem(
      child: Text("BioMedical Engineering"), value: "BioMedical Engineering"),
  const DropdownMenuItem(
      child: Text("Chemical Engineering"), value: "Chemical Engineering"),
  const DropdownMenuItem(
      child: Text("Civil Engineering"), value: "Civil Engineering"),
  const DropdownMenuItem(
      child: Text("Electrical Engineering"), value: "Electrical Engineering"),
  const DropdownMenuItem(
      child: Text("Computer Science & Engineering"),
      value: "Computer Science & Engineering"),
  const DropdownMenuItem(
      child: Text("Metallurgical and Materials Engineering"),
      value: "Metallurgical and Materials Engineering"),
  const DropdownMenuItem(child: Text("Chemistry"), value: "Chemistry"),
  const DropdownMenuItem(child: Text("Physics"), value: "Physics"),
  const DropdownMenuItem(child: Text("Mathematics"), value: "Mathematics"),
  const DropdownMenuItem(
      child: Text("Humanities and Social Sciences"),
      value: "Humanities and Social Sciences"),
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
    "2020csb1086@iitrpr.ac.in",
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
    String email_check = await firebaseDatabase
        .emailCheck(FirebaseAuth.instance.currentUser!.email!);
    if (admins.contains(FirebaseAuth.instance.currentUser!.email)) {
      user = "admin";
    } else if (email_check == "club") {
      user = "club";
    } else if (email_check == "faculty") {
      user = "faculty";
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
