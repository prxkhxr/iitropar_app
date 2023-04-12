import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/frequently_used.dart';
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
  return Padding(
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
        const SizedBox(height: 10),
        Text(
          item,
          style: TextStyle(fontSize: 14, color: Color(primaryLight)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget divider() {
  return const Divider(
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
  double maxBfTime = toDouble(const TimeOfDay(hour: 9, minute: 30));
  double maxLunchTime = toDouble(const TimeOfDay(hour: 14, minute: 30));
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
        padding: const EdgeInsets.all(5.0),
        child: Text('Hungry ? ',
            style: TextStyle(
              color: Color(primaryLight), // Set text color to blue
              fontSize: 22, // Set text size to 24
              fontWeight: FontWeight.bold, // Set text font to bold
            )),
      ),
      Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'See what is there for $currentMeal',
            style: const TextStyle(
              color: Color(0xff333333), // Set text color to blue
              fontSize: 18, // Set text size to 24// Set text font to bold
            ),
          )),
      SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: items.map(buildItems).toList(),
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
    classes = await EventDB().fetchOf('admin');
    print(classes);
    return true;
  }

  Widget classWidget(Event myEvents) {
    const width = 500;
    const textsize = (8 / 10) * width;
    const iconsize = (1 / 10) * width;
    return Column(
      children: [
        ListTile(
          horizontalTitleGap: 0,
          leading: SizedBox(
            width: iconsize,
            child: Icon(
              Icons.book,
              color: Color(primaryLight),
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
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget todayClasses() {
    return Column(
      children: [getSchedule()],
    );
  }

  Widget getSchedule() {
    return FutureBuilder(
        future: loadClasses(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Text('Loading today\'s Classes ...');
          } else {
            if (classes.isEmpty) {
              return const Text('No classes today');
            }
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff555555),
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                      color: Color(primaryLight),
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Classes",
                    style: TextStyle(
                        color: Color(primaryLight),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: classes.map(classWidget).toList(),
                    ),
                  ),
                ],
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
            return const Text('Loading today\'s Events ...');
          } else {
            if (classes.isEmpty) {
              return const Text('No Events today');
            }
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff555555),
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                      color: Color(primaryLight),
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Events",
                    style: TextStyle(
                        color: Color(primaryLight),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: events.map(classWidget).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget todayEvents() {
    return Column(
      children: [getEvents()],
    );
  }

  Widget intermediateText() {
    return Column(
      // kuch dikkat aa sakti hai, start nahi chal raha :(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "What's happening next?",
          style: TextStyle(
              color: Color(primaryLight),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(todayMenu());
    l.add(intermediateText());
    l.add(todayClasses());
    l.add(const SizedBox(
      height: 20,
    ));
    l.add(todayEvents());
    l.add(const SizedBox(
      height: 20,
    ));
    return l;
  }
}
