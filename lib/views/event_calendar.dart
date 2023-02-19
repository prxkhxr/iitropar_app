import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';

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
  Map<String, List> mySelectedEvents = {};
  Map<String, List> weeklyEvents = {};

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

  String formatTimeOfDay(TimeOfDay tod) {
    final now =  DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  //"6:00 AM"
    return format.format(dt);
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;

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
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(_selectedDate!=null){
                              _selectedDate = _selectedDate!.subtract(const Duration(days:1));
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_left),
                      ),
                      Text(DateFormat('dd-MM-yyyy').format(_selectedDate!)),
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(_selectedDate!=null){
                              _selectedDate = _selectedDate!.add(const Duration(days:1));
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_right),
                      ),

                    ],
                  );
                }
              ),
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
                        TimeOfDay? newTime = await showTimePicker(context: context, initialTime: startTime);
                        if(newTime!=null){
                          setState(() {
                            startTime = newTime;
                          });
                        }
                      },
                      child: Text(
                        "Start Time : ${formatTimeOfDay(startTime)}",
                        style: const TextStyle(fontSize: 18),
                      ));
                }
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return TextButton(
                      onPressed: () async {
                        TimeOfDay? newTime = await showTimePicker(context: context, initialTime: endTime);
                        if(newTime!=null){
                          setState(() {
                            endTime = newTime;
                          });
                        }
                      },
                      child: Text(
                        "End Time : ${formatTimeOfDay(endTime)}",
                        style: const TextStyle(fontSize: 18),
                      ));
                }
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
                      descpController.text.isEmpty || toDouble(endTime) < toDouble(startTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Required title and Description. Times must be entered properly."),
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
                          mySelectedEvents[DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate!)]
                              ?.add({
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                          });
                        } else {
                          mySelectedEvents[DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)] = [
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
      drawer: const NavDrawer(),
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
