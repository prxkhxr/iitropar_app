import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'database/event.dart';
import 'database/local_db.dart';

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
    // "2020csb1082@iitrpr.ac.in",
    "2020csb1086@iitrpr.ac.in",
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

Future<bool> _signout() async {
  if (Ids.role == 'student') {
    await EventDB().deleteOf('admin');
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
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5);
}
