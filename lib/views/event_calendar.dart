import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  Map<String, List> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDay;

    loadprevEvents();
  }

  loadprevEvents() {
    mySelectedEvents = {};
  }

  List _listOfDayEvents(DateTime datetime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)] != null) {
      if (weeklyEvents[datetime.weekday.toString()] != null) {
        List<dynamic> l = [
          ...mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)]!,
          ...weeklyEvents[datetime.weekday.toString()]!
        ];
        return l;
      } else {
        return mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)]!;
      }
    } else {
      if (weeklyEvents[datetime.weekday.toString()] != null) {
        return weeklyEvents[datetime.weekday.toString()]!;
      }
      return [];
    }
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
                controller: timeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Event time',
                ),
              ),
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
                      descpController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Required title and description"),
                      duration: Duration(seconds: 2),
                    ));
                    return;
                  } else {
                    setState(() {
                      if (recurringEvent == true) {
                        print("yeps");
                        int? day = _selectedDate?.weekday;
                        if (weeklyEvents[day.toString()] != null) {
                          weeklyEvents[day.toString()]?.add({
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                          });
                        } else {
                          weeklyEvents[day.toString()] = [
                            {
                              "eventTitle": titleController.text,
                              "eventDescp": descpController.text,
                            }
                          ];
                        }
                      } else {
                        if (mySelectedEvents[DateFormat('yyyy-MM-dd')
                                .format(_selectedDate!)] !=
                            null) {
                          mySelectedEvents[
                                  DateFormat('yyyy-MM-dd').format(_selectedDate!)]
                              ?.add({
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                          });
                        } else {
                          mySelectedEvents[
                              DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                            {
                              "eventTitle": titleController.text,
                              "eventDescp": descpController.text,
                            }
                          ];
                        }
                      }
                    });
                    print(json.encode(weeklyEvents));
                    print(json.encode(mySelectedEvents));
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
        centerTitle: true,
        title: const Text("Event Calendar"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text('Navigation Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/login');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event,
              ),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/events');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _currentDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2024),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
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
                  child: Text("Event Title: ${myEvents['eventTitle']}"),
                ),
                subtitle: Text("Description: ${myEvents['eventDescp']}"),
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
