import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';

import '../database/loader.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, List<Event>> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};
  List<holidays> listofHolidays = [];
  Map<String, String> mapofHolidays = {};
  bool holidaysLoaded = false;
  List<changedDay> listofCD = [];
  Map<String, int> mapofCD = {};
  bool CDLoaded = false;
  EventDB edb = EventDB();

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getHols();
    getCD();
    mySelectedEvents = {};
    loadEvents(_selectedDate);
  }

  Future<bool> getHols() async {
    listofHolidays = await firebaseDatabase.getHolidayFB();

    for (int i = 0; i < listofHolidays.length; i++) {
      mapofHolidays[DateFormat('yyyy-MM-dd').format(listofHolidays[i].date)] =
          listofHolidays[i].desc;
    }

    print(mapofHolidays);
    setState(() {
      holidaysLoaded = true;
    });
    return true;
  }

  Widget getDeleteButton(Event m) {
    print(m.creator);
    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.email == m.creator) {
        return IconButton(
          onPressed: () => _deleteEntireEvent(m),
          icon: const Icon(Icons.delete),
          color: Color(primaryLight).withOpacity(0.8),
        );
      }
    }
    return Container();
  }

  Future<bool> getCD() async {
    listofCD = await firebaseDatabase.getChangedDays();
    print(listofCD[0].day_to_followed);
    for (int i = 0; i < listofCD.length; i++) {
      switch (listofCD[i].day_to_followed) {
        case "Monday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 0;
          break;
        case "Tuesday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 1;
          break;
        case "Wednesday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 2;
          break;
        case "Thursday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 3;
          break;
        case "Friday":
          mapofCD[DateFormat('yyyy-MM-dd').format(listofCD[i].date)] = 4;
          break;
        default:
      }
    }
    setState(() {
      CDLoaded = true;
    });
    print(mapofCD);
    return true;
  }

  loadLocalDB() async {
    await loadEvents(_selectedDate);
  }

  loadEvents(DateTime d) async {
    var d1 = DateTime(d.year, d.month);
    DateTime d2;
    if (d.month == 12) {
      d2 = DateTime(d.year + 1, 1);
    } else {
      d2 = DateTime(d.year, d.month + 1);
    }
    List<Event> l = List.empty(growable: true);
    while (d1.compareTo(d2) < 0) {
      l = await edb.fetchEvents(d1);
      mySelectedEvents[DateFormat('yyyy-MM-dd').format(d1)] = l;
      d1 = d1.add(const Duration(days: 1));
    }
    setState(() {
      mySelectedEvents;
    });
  }

  updateEvents(DateTime d) async {
    var l = await edb.fetchEvents(d);
    setState(() {
      mySelectedEvents[dateString(d)] = l;
    });
  }

  updateEventsRecurring(DateTime d) async {
    DateTime s = DateTime(d.year, d.month);
    s = s.add(Duration(
        days: (d.weekday >= s.weekday)
            ? (d.weekday - s.weekday)
            : (d.weekday - s.weekday + 7)));
    while (s.month == d.month) {
      updateEvents(s);
      s = s.add(const Duration(days: 7));
    }
  }

  void _insertSingularEvent(Event e, DateTime date) async {
    await edb.addSingularEvent(e, date);
    updateEvents(date);
  }

  void _insertRecurringEvent(
      Event r, DateTime start, DateTime end, DateTime current, int mask) async {
    await edb.addRecurringEvent(r, start, end, mask);
    updateEventsRecurring(_selectedDate);
  }

  void _deleteEntireEvent(Event e) async {
    await edb.delete(e);
    loadEvents(_selectedDate);
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  List<Event> _listOfDayEvents(DateTime datetime) {
    var l = mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)];
    if (l != null) {
      l.sort((a, b) => a.compareTo(b));
      return l;
    }
    return List.empty();
  }

  bool isHoliday(DateTime day) {
    if (day.weekday >= 6) {
      return true;
    }

    if (holidaysLoaded == true) {
      String cmp = DateFormat('yyyy-MM-dd').format(day);
      if (mapofHolidays[cmp] != null) {
        return true;
      }
    }

    return false;
  }

  DateTime whatDatetocall(DateTime datetime) {
    if (CDLoaded) {
      if (mapofCD[DateFormat("yyyy-MM-dd").format(datetime)] != null) {
        int wkday = datetime.weekday - 1;
        int dtf = mapofCD[DateFormat("yyyy-MM-dd").format(datetime)]!;
        if (dtf > wkday) {
          return datetime.add(Duration(days: dtf - wkday));
        } else {
          return datetime.subtract(Duration(days: wkday - dtf));
        }
      }
    }
    if (holidaysLoaded) {
      if (mapofHolidays[dateString(datetime)] != null) {
        return datetime.add(const Duration(days: 1000));
      }
    }
    return datetime;
  }

  String? holidayScript(DateTime date) {
    if (holidaysLoaded) {
      return mapofHolidays[dateString(date)];
    }
    return null;
  }

  _showSingleAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            "Add New Event",
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                );
              }),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descpController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (newTime != null) {
                        setState(() {
                          startTime = newTime;
                        });
                      }
                    },
                    child: Text(
                      "Start Time : ${formatTimeOfDay(startTime)}",
                      style: const TextStyle(fontSize: 18),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (newTime != null) {
                        setState(() {
                          endTime = newTime;
                        });
                      }
                    },
                    child: Text(
                      "End Time : ${formatTimeOfDay(endTime)}",
                      style: const TextStyle(fontSize: 18),
                    ));
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  titleController.clear();
                  descpController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descpController.text.isEmpty ||
                      toDouble(endTime) < toDouble(startTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Required title and description. Times must be entered properly."),
                      duration: Duration(seconds: 5),
                    ));
                    return;
                  } else {
                    print("Adding Singular Event");
                    Event s = Event(
                      title: titleController.text,
                      desc: descpController.text,
                      stime: startTime,
                      etime: endTime,
                      creator: FirebaseAuth.instance.currentUser!.email!,
                    );
                    _insertSingularEvent(s, _selectedDate);

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    Navigator.pop(context);
                    return;
                  }
                },
                child: const Text("Add Event")),
          ],
        ),
      ),
    );
  }

  _showRecurringAddEventDialog() async {
    endDate = _selectedDate;
    await showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text(
            "Add New Recurring Event",
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                );
              }),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descpController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (newTime != null) {
                        setState(() {
                          startTime = newTime;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "Start Time : ${formatTimeOfDay(startTime)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (newTime != null) {
                        setState(() {
                          endTime = newTime;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "End Time : ${formatTimeOfDay(endTime)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return TextButton(
                    onPressed: () async {
                      DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));

                      if (newDate != null) {
                        setState(() {
                          endDate = newDate;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        child: Text(
                          "End Date : ${DateFormat('dd-MM-yyyy').format(endDate)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ));
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  titleController.clear();
                  descpController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  startDate = _selectedDate;
                  if (titleController.text.isEmpty ||
                      descpController.text.isEmpty ||
                      startDate.compareTo(endDate) > 0 ||
                      toDouble(endTime) < toDouble(startTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Required title and description. Times must be entered properly."),
                      duration: Duration(seconds: 5),
                    ));
                    return;
                  } else {
                    print("Adding Recurring Event");
                    Event r = Event(
                      title: titleController.text,
                      desc: descpController.text,
                      stime: startTime,
                      etime: endTime,
                      creator: 'user',
                    );
                    _insertRecurringEvent(r, startDate, endDate, _selectedDate,
                        ((1 << (startDate.weekday - 1))));

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    Navigator.pop(context);
                    return;
                  }
                },
                child: const Text("Add Event")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? holidayResaon = holidayScript(_selectedDate);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          title: buildTitleBar("EVENT CALENDAR", context),
          backgroundColor: Color(secondaryLight),
          elevation: 0,
        ),
        // drawer: const NavDrawer(),
        backgroundColor: Color(secondaryLight),
        body: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height - 80) / 2,
              child: TableCalendar(
                shouldFillViewport: true,
                focusedDay: _focused,
                firstDay: DateTime(2023),
                lastDay: DateTime(2024).subtract(const Duration(days: 1)),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDate, selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focused = focusedDay;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                enabledDayPredicate: (day) {
                  return _focused.month == day.month;
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focused = focusedDay;
                  });
                  loadEvents(focusedDay);
                },
                eventLoader: (datetime) {
                  return _listOfDayEvents(whatDatetocall(datetime));
                },
                holidayPredicate: (day) {
                  return isHoliday(day);
                },
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                currentDay: DateTime.now(),
                calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                        color: Color(primaryLight), shape: BoxShape.circle),
                    todayDecoration: const BoxDecoration(
                        color: Color(0xffAAAAAA), shape: BoxShape.circle)),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) {
                      return Container();
                    }

                    return Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.orangeAccent),
                    );
                  },
                  holidayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Text("${day.day}",
                          style: TextStyle(color: Color(holidayColor))),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            Divider(
              height: 5,
              thickness: 1,
              color: Color(primaryLight).withOpacity(0.05),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._listOfDayEvents(whatDatetocall(_selectedDate))
                      .map((myEvents) {
                    final width = MediaQuery.of(context).size.width;
                    return Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 1.25 / 5.5 * width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(myEvents.startTime(),
                                        style: TextStyle(
                                          color: Color(primaryLight),
                                          fontSize: 14,
                                        )),
                                    Text(
                                      myEvents.endTime(),
                                      style: TextStyle(
                                          color: Color(primaryLight)
                                              .withOpacity(0.6),
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                thickness: 3.5,
                                width: 0,
                                color: Colors.green /* Colors.green*/,
                              ),
                              SizedBox(
                                width: 0.5 / 5.5 * width,
                              ),
                              SizedBox(
                                width: 3 / 5.5 * width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      myEvents.title,
                                      style: TextStyle(
                                          color: Color(primaryLight),
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(myEvents.desc,
                                        style: TextStyle(
                                            color: Color(primaryLight)
                                                .withOpacity(0.6)),
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              getDeleteButton(myEvents),
                            ],
                          ),
                        ),
                        Divider(
                          height: 2,
                          thickness: 1,
                          color: Color(primaryLight).withOpacity(0.05),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    holidayResaon ?? '',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 120.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: const Text('Add Event'),
                          onTap: () {
                            Navigator.pop(context);
                            _showSingleAddEventDialog();
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.repeat),
                          title: const Text('Add Recurring Event'),
                          onTap: () {
                            Navigator.pop(context);
                            _showRecurringAddEventDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          backgroundColor: Color(primaryLight),
          child: const Icon(Icons.add),
        ));
  }

  Widget themeButtonWidget() {
  return IconButton(
    onPressed: () async {
        if ((await Ids.resolveUser()).compareTo('student') == 0) {
          var cl = await firebaseDatabase.getCourses(
              FirebaseAuth.instance.currentUser!.email!.split('@')[0]);
          await Loader.saveCourses(cl);
          await Loader.loadMidSem(
            DateTime(2023, 2, 27),
            const TimeOfDay(hour: 9, minute: 30),
            const TimeOfDay(hour: 12, minute: 30),
            const TimeOfDay(hour: 14, minute: 30),
            const TimeOfDay(hour: 16, minute: 30),
            cl,
          );
        } else if ((await Ids.resolveUser()).compareTo('faculty') == 0) {
          var fd = await firebaseDatabase
              .getFacultyDetail(FirebaseAuth.instance.currentUser!.email!);
          List<String> cl = List.from(fd.courses);
          await Loader.saveCourses(cl);
        }
        
        // setState(() {

        // });
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(builder:((context) => const EventCalendarScreen())));
    },
    icon: const Icon(
      Icons.sync_rounded,
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
}
