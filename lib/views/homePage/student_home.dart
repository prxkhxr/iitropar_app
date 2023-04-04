import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/database/event.dart';

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

Widget divider() {
  return Divider(
    color: Colors.black,
    height: 30,
    thickness: 1,
    indent: 30,
    endIndent: 30,
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
  bool isClassLoad = false;
  List<Event> classes = [];
  List<Event> events = [];
  Future<bool> loadClasses() async {
    classes = await EventDB().fetchRecurringEvents(DateTime.now());
    return true;
  }

  Widget classWidget(Event myEvents) {
    final width = 500;
    final textsize = (8 / 10) * width;
    final buttonsize = (1 / 10) * width;
    final iconsize = (1 / 10) * width;
    return ListTile(
      horizontalTitleGap: 0,
      leading: SizedBox(
        width: iconsize,
        child: const Icon(
          Icons.done,
          color: Colors.indigo,
        ),
      ),
      title: SizedBox(
        width: textsize,
        child: Text(
          myEvents.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description: ${myEvents.description}"),
          const SizedBox(
            width: 5,
          ),
          Text('Time: ${myEvents.stime} - ${myEvents.etime}'),
        ],
      ),
    );
  }

  Widget todayClasses() {
    return Column(
      children: [
        Text('See your class schedule \n and personal events'),
        SizedBox(height: 15),
        getSchedule()
      ],
    );
  }

  Widget getSchedule() {
    return FutureBuilder(
        future: loadClasses(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Text('No classes Today');
          } else {
            return SizedBox(
              height: 100,
              child: ListView(
                children: classes.map(classWidget).toList(),
                scrollDirection: Axis.vertical,
              ),
            );
          }
        });
  }

  Future<bool> loadEvents() async {
    events = await firebaseDatabase.getEvents(DateTime.now());
    return true;
  }

  Widget getEvents() {
    return FutureBuilder(
        future: loadEvents(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Text('No Events Today');
          } else {
            return SizedBox(
              height: 100,
              child: ListView(
                children: events.map(classWidget).toList(),
                scrollDirection: Axis.vertical,
              ),
            );
          }
        });
  }

  Widget todayEvents() {
    return Column(
      children: [
        Text('See Events happening today'),
        SizedBox(height: 15),
        getEvents()
      ],
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(todayMenu());
    l.add(Divider());
    l.add(todayClasses());
    l.add(Divider());
    l.add(todayEvents());
    return l;
  }
}
