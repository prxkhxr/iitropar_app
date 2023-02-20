import 'dart:async';
import 'dart:convert';
import 'package:iitropar/database/Event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/database/localDB.dart';
import 'package:iitropar/database/Event.dart';

import 'package:iitropar/database/local_db.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _currentDay = DateTime.now();
  DateTime? _selectedDate;
  bool recurringEvent = false;
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  Map<String, List<Event>> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};

  Future<EventDB> fldb = openEventDB();
  EventDB? ldb;

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  String _dateString(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDay;
<<<<<<< HEAD
    openEventDB();
    
    loadprevEvents();
=======

    mySelectedEvents = {};
    loadLocalDB();
>>>>>>> 55ff93b1fffa8353bf0bee89d9af14a7ff551982
  }

  loadLocalDB() async {
    ldb = await fldb;
    await loadDaysEvents(DateTime.now());
    setState(() {});
  }

  loadDaysEvents(DateTime d) async {
    if (ldb == null) return;

    List<Event> l = await ldb!.fetchEvents(d);
    setState(() {
      mySelectedEvents[DateFormat('yyyy-MM-dd').format(d)] = l;
    });
  }

  _insertREvent(RecurringEvent r) async {
    await fldb;
    setState(() {
      ldb!.addRecurringEvent(r);
      loadDaysEvents(_selectedDate!);
    });
  }

  _insertSEvent(SingularEvent s) async {
    await fldb;
    setState(() {
      ldb!.addSingularEvent(s);
      loadDaysEvents(_selectedDate!);
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

  _showAddEventDialog() async {
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
                          if (_selectedDate != null) {
                            _selectedDate = _selectedDate!
                                .subtract(const Duration(days: 1));
                          }
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(DateFormat('dd-MM-yyyy').format(_selectedDate!)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedDate != null) {
                            _selectedDate =
                                _selectedDate!.add(const Duration(days: 1));
                          }
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
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return CheckboxListTile(
                    value: recurringEvent,
                    onChanged: (bool? newValue) {
                      setState(() {
                        recurringEvent = newValue!;
                        // print(recurringEvent);
                      });
                    },
                    title: const Text("Recurring Event"));
              })
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
                          "Required title and Description. Times must be entered properly."),
                      duration: Duration(seconds: 2),
                    ));
                    return;
                  } else {
                    if (recurringEvent == true) {
                      print("Adding Recurring Event");
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
                    } else {
                      print("Adding Singular Event");
                      SingularEvent s = SingularEvent(
                        title: titleController.text,
                        description: descpController.text,
                        date: _dateString(_selectedDate!),
                        stime: formatTimeOfDay(startTime),
                        etime: formatTimeOfDay(endTime),
                        creator: 'user',
                      );
                      _insertSEvent(s);
                    }
                    titleController.clear();
                    descpController.clear();
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
            focusedDay: _currentDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2024),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              loadDaysEvents(selectedDay);
              if (!isSameDay(_selectedDate, selectedDay)) {
                setState(() {
                  _selectedDate = selectedDay;
                  _currentDay = focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _currentDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          ..._listOfDayEvents(_selectedDate!).map((myEvents) => ListTile(
                leading: const Icon(
                  Icons.done,
                  color: Colors.indigo,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Event Title: ${myEvents.title}"),
                ),
                subtitle: Text("Description: ${myEvents.description}"),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            recurringEvent = false;
          });
          _showAddEventDialog();
        },
        label: const Text("Add Event"),
      ),
    );
  }
}
