import 'package:flutter/material.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

class StudentHome extends AbstractHome {
  const StudentHome({super.key});

  @override
  State<AbstractHome> createState() => _StudentHomeState();
}

String getDay() {
  return DateFormat('EEEE').format(DateTime.now());
}

Widget buildItems(String item) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: Image.asset(
              'assets/foodItem.jfif',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            item,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget todayMenu() {
  String currentMeal = "Dinner";
  int idx = 0;
  double maxBfTime = toDouble(TimeOfDay(hour: 9, minute: 30));
  double maxLunchTime = toDouble(TimeOfDay(hour: 14, minute: 30));
  double curTime = toDouble(TimeOfDay.now());
  if (curTime < maxBfTime) {
    idx = 0;
    currentMeal = "Breakfast";
  } else if (curTime < maxLunchTime) {
    idx = 1;
    currentMeal = "Lunch";
  } else {
    idx = 2;
    currentMeal = "Dinner";
  }
  List<String> items = Menu.menu[getDay()]![idx].description.split(',');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('Hungry ? ',
            style: TextStyle(
              color: Colors.black, // Set text color to blue
              fontSize: 24, // Set text size to 24
              fontWeight: FontWeight.bold, // Set text font to bold
            )),
      ),
      Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'See what is there for $currentMeal',
            style: TextStyle(
              color: Colors.black, // Set text color to blue
              fontSize: 24, // Set text size to 24// Set text font to bold
            ),
          )),
      SizedBox(
        height: 150,
        child: ListView(
          children: items.map(buildItems).toList(),
          scrollDirection: Axis.horizontal,
        ),
      )
    ],
  );
}

class _StudentHomeState extends AbstractHomeState {
  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(todayMenu());
    return l;
  }
}
