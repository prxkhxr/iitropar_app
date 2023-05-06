import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class CourseSchedule extends StatefulWidget {
  final Set<dynamic> courses;
  TimeOfDay st = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay et = const TimeOfDay(hour: 9, minute: 0);
  CourseSchedule({required this.courses, st, et});

  @override
  _CourseScheduleState createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> {
  late String selectedCourse;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String venue;
  late String description;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    selectedCourse = widget.courses.first;
    startTime = widget.st;
    endTime = widget.et;
    venue = '';
    description = '';
  }

  Future<void> _showStartTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (newTime != null) {
      setState(() {
        startTime = newTime;
      });
    }
  }

  Future<void> _showEndTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );

    if (newTime != null) {
      setState(() {
        endTime = newTime;
      });
    }
  }

  void _onVenueChanged(String newValue) {
    setState(() {
      venue = newValue;
    });
  }

  void _onDescriptionChanged(String newValue) {
    setState(() {
      description = newValue;
    });
  }

  Widget selectCourse() {
    return Column(
      children: [
        const Text('Select Course',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedCourse,
          items: widget.courses.toList().map((dynamic course) {
            return DropdownMenuItem<String>(
              value: course,
              child: Text(course),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCourse = newValue!;
            });
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget selectTime() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Start Time'),
            trailing: Text('${startTime.format(context)}'),
            onTap: _showStartTimePicker,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('End Time'),
            trailing: Text('${endTime.format(context)}'),
            onTap: _showEndTimePicker,
          ),
        ),
      ],
    );
  }

  Widget selectVenue() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Venue',
        hintText: 'Enter the venue',
      ),
      onChanged: _onVenueChanged,
    );
  }

  Widget selectDescription() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter the description',
      ),
      onChanged: _onDescriptionChanged,
    );
  }

  Widget selectDate() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          child: const Text('Pick Event Date'),
          onPressed: () {
            showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100))
                .then((_date) {
              if (_date != null && _date != date) {
                setState(() {
                  date = _date;
                });
              }
            });
          },
        ),
        const SizedBox(width: 20),
        Text("${date.day}/${date.month}/${date.year}",
            style: const TextStyle(fontSize: 24,fontWeight: FontWeight.normal)),
      ],
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              // Courses Dropdown
              selectCourse(),
              // Timings (Start time and End Time)
              selectDate(),
              selectTime(),
              const SizedBox(height: 16.0),
              // Venue
              selectVenue(),
              const SizedBox(height: 16.0),
              // Description
              selectDescription(),
              const SizedBox(height: 16.0),
              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (date.compareTo(getTodayDateTime()) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Previous date event are not allowed")),
                    );
                    return;
                  }
                  if (toDouble(startTime) > toDouble(endTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Invalid Time. End time is before start time.")),
                    );
                    return;
                  }
                  ExtraClass c = ExtraClass(
                      courseID: selectedCourse,
                      date: date,
                      startTime: startTime,
                      endTime: endTime,
                      description: description,
                      venue: venue);
                  bool hasSubmit = await firebaseDatabase.addExtraClass(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Event Added Succesfully")),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
