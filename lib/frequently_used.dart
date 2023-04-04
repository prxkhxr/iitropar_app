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
      MenuItem('Breakfast', 'Aloo pyaz paratha, Sprouts, Milk'),
      MenuItem('Lunch', 'Veg Biryani, Dal tadka, Mix-Raita'),
      MenuItem('Dinner', 'Clear soup, Lauki chana ki sabzi, Arhar Dal, Roti')
    ],
    'Tuesday': [
      MenuItem('Breakfast', 'Uttapam Sambar, Bread, Butter, Jam'),
      MenuItem('Lunch', 'Cabbage and Beans ki sabzi, Dal makhani with Curd'),
      MenuItem('Dinner', 'Ajwain Paratha, Chole, Palak arhar dal, Rice')
    ],
    'Wednesday': [
      MenuItem('Breakfast',
          'Methi puri, Aloo-Gobhi, Sweet Corn rice and naan bread'),
      MenuItem('Lunch', 'Rajma Chawal, Curd with Chapati'),
      MenuItem('Dinner', 'Mix-Veg-Paneer Biryani, Dal tadka, Mix-Raita')
    ],
    'Thursday': [
      MenuItem('Breakfast', 'Upma, Bread-Pakoda with Fruits'),
      MenuItem('Lunch', 'Kadi-Pakoda, Alu methi, Jeera rice with Papad'),
      MenuItem('Dinner', 'Hot-n-Sour Soup, Baingan bharta, Masoor dal')
    ],
    'Friday': [
      MenuItem(
          'Breakfast', 'Poha, Medu Wada(2Pc), Sprouts and Bread, Butter, Jam'),
      MenuItem('Lunch', 'Palak Paneer, Arhar Dal, Curd with Chapati '),
      MenuItem('Dinner',
          'Sev-Tamatar, Matar Pulao, Green Sabut Moong dal with Ladoo')
    ],
    'Saturday': [
      MenuItem('Breakfast', 'Pav Bhaji, Sprouts, boiled-egg with Bournvita'),
      MenuItem(
          'Lunch', 'Vegetable Khichdi, Alu-pyaz ka bharta, Papad with Curd'),
      MenuItem('Dinner', 'Tomato Soup, Gajar Matar Sabzi, Moth dal, Rice')
    ],
    'Sunday': [
      MenuItem('Breakfast', 'Besan Chilla, Dalia(Sweet) omelette and Milk'),
      MenuItem('Lunch',
          'Masala-puri, Chana masala, Tomato rice bread with Boondi-Raita'),
      MenuItem('Dinner', 'Butter Chicken, Arhar dal, Rice, Tandoori Roti')
    ],
  };
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
