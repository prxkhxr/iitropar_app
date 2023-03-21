import 'dart:async';
import 'package:iitropar/database/Event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/database/Event.dart';

import 'package:iitropar/database/local_db.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, List<Event>> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};

  Future<EventDB> fldb = openEventDB();
  EventDB? ldb;

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final typeController = TextEditingController();
  final venueController = TextEditingController();

  String _dateString(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }

  @override
  void initState() {
    super.initState();

    mySelectedEvents = {};
    loadLocalDB();
  }

  loadLocalDB() async {
    ldb = await fldb;
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
      l = await ldb!.fetchEvents(d1);
      setState(() {
        mySelectedEvents[DateFormat('yyyy-MM-dd').format(d1)] = l;
      });
      d1 = d1.add(const Duration(days: 1));
    }
  }

  _insertREvent(RecurringEvent r) async {
    await fldb;
    setState(() {
      ldb!.addRecurringEvent(r);
      loadEvents(_selectedDate);
    });
  }

  _insertSEvent(SingularEvent s) async {
    await fldb;
    setState(() {
      ldb!.addSingularEvent(s);
      loadEvents(_selectedDate);
    });
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
      return l;
    }
    return List.empty();
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
              TextField(
                controller: typeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
              ),
              TextField(
                controller: venueController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue',
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
                      typeController.text.isEmpty ||
                      venueController.text.isEmpty ||
                      toDouble(endTime) < toDouble(startTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Required title, description, type and venue. Times must be entered properly."),
                      duration: Duration(seconds: 5),
                    ));
                    return;
                  } else {
                    print("Adding Singular Event");
                    SingularEvent s = SingularEvent(
                      title: titleController.text,
                      description: descpController.text,
                      date: _dateString(_selectedDate),
                      stime: formatTimeOfDay(startTime),
                      etime: formatTimeOfDay(endTime),
                      creator: 'user',
                    );
                    _insertSEvent(s);

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    venueController.clear();
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
                        startDate = _selectedDate;
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
                        startDate = _selectedDate;
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
              TextField(
                controller: typeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
              ),
              TextField(
                controller: venueController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue',
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
                        startDate = _selectedDate;
                        setState(() {
                          endDate = newDate;
                        });
                      }
                    },
                    child: Text(
                      "End Date : ${DateFormat('dd-MM-yyyy').format(endDate)}",
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
                      typeController.text.isEmpty ||
                      venueController.text.isEmpty ||
                      startDate.compareTo(endDate) > 0 ||
                      toDouble(endTime) < toDouble(startTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Required title, description, type and venue. Times must be entered properly."),
                      duration: Duration(seconds: 5),
                    ));
                    return;
                  } else {
                    print("Adding Recurring Event");
                    print(
"${DateFormat('dd-MM-yyyy').format(startDate)} ::: ${DateFormat('dd-MM-yyyy').format(endDate)}");
                    RecurringEvent r = RecurringEvent(
                      title: titleController.text,
                      description: descpController.text,
                      stime: formatTimeOfDay(startTime),
                      etime: formatTimeOfDay(endTime),
                      startDate: _dateString(DateTime.now()),
                      endDate: _dateString(
                          DateTime.now().subtract(const Duration(days: -50))),
                      mask: ~0,
                      creator: 'user',
                    );
                    _insertREvent(r);

                    titleController.clear();
                    descpController.clear();
                    typeController.clear();
                    venueController.clear();
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Event Calendar"),
        ),
        drawer: const NavDrawer(),
        body: Column(
          children: [
            TableCalendar(
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
                _focused = focusedDay;
                loadEvents(focusedDay);
              },
              eventLoader: _listOfDayEvents,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              currentDay: DateTime(2023, DateTime.february),
            ),
            ..._listOfDayEvents(_selectedDate).map((myEvents) => ListTile(
                  leading: const Icon(
                    Icons.done,
                    color: Colors.indigo,
                  ),
                  title: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("Event Title: ${myEvents.title}"),
                      ),
                      const SizedBox(width: 10,),
                      IconButton(
                        onPressed: (){

                        },
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
                  subtitle: Text("Description: ${myEvents.description}"),
                ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 120.0,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.event),
                        title: Text('Add Event'),
                        onTap: () {
                          Navigator.pop(context);
                          _showSingleAddEventDialog();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.repeat),
                        title: Text('Add Recurring Event'),
                        onTap: () {
                          Navigator.pop(context);
                          _showRecurringAddEventDialog();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
