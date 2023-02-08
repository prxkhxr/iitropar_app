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

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

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
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(datetime)]!;
    } else {
      return [];
    }
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    if (mySelectedEvents[
                            DateFormat('yyyy-MM-dd').format(_selectedDate!)] !=
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
                  });

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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.menu),
            ),
            Expanded(child: Container()),
            const Text("Event Calendar"),
            Expanded(child: Container()),
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
        onPressed: () => _showAddEventDialog(),
        label: const Text("Add Event"),
      ),
    );
  }
}
