import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:iitropar/frequently_used.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Add Event"),
        ),
        body: const AddEventForm());
  }
}

// Create a Form widget.
class AddEventForm extends StatefulWidget {
  const AddEventForm({super.key});

  @override
  AddEventFormState createState() {
    return AddEventFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddEventFormState extends State<AddEventForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.

  final _formKey = GlobalKey<FormState>();
  late String eventTitle;
  late String eventType;
  late String eventDesc;
  late DateTime eventDate;
  late String eventVenue;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  String? imageURL;
  XFile? file;

  AddEventFormState() {
    eventDate = DateTime.now();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
  }
  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Widget _buildEventTitle() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Event Title'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Title is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventTitle = value!;
      },
    );
  }

  Widget _buildEventType() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Event Type'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Type is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventType = value!;
      },
    );
  }

  Widget _buildEventDesc() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Event Description'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Description is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventDesc = value!;
      },
    );
  }

  Widget _buildEventVenue() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Event Venue'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Event Venue is required';
        }
        return null;
      },
      onSaved: (String? value) {
        eventVenue = value!;
      },
    );
  }

  Widget _buildEventDate() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          child: Text('Pick Event Date'),
          onPressed: () {
            showDatePicker(
                    context: context,
                    initialDate: eventDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100))
                .then((date) {
              if (date != null && date != eventDate) {
                setState(() {
                  eventDate = date;
                });
              }
            });
          },
        ),
        SizedBox(width: 20),
        Text(
            eventDate == null
                ? 'Nothing has been picked yet'
                : "${eventDate.day}/${eventDate.month}/${eventDate.year}",
            style: TextStyle(fontSize: 32)),
      ],
    );
  }

  Widget _buildStartTime() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          child: Text('Set Start time'),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: startTime,
            ).then((time) {
              if (time != null && time != startTime) {
                setState(() {
                  startTime = time;
                });
              }
            });
          },
        ),
        SizedBox(width: 20),
        Text(
            startTime == null
                ? 'Nothing has been picked yet'
                : formatTimeOfDay(startTime),
            style: TextStyle(fontSize: 32)),
      ],
    );
  }

  Widget _buildEndTime() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          child: Text('Set End time'),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: endTime,
            ).then((time) {
              if (time != null && time != endTime) {
                setState(() {
                  endTime = time;
                });
              }
            });
          },
        ),
        SizedBox(width: 20),
        Text(
            endTime == null
                ? 'Nothing has been picked yet'
                : formatTimeOfDay(endTime),
            style: TextStyle(fontSize: 32)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventTitle(),
            _buildEventType(),
            _buildEventDesc(),
            _buildEventVenue(),
            SizedBox(height: 20),
            _buildEventDate(),
            _buildStartTime(),
            _buildEndTime(),
            Row(
              children: [
                Text('Add Event Image'),
                IconButton(
                    onPressed: () async {
                      ImagePicker imagepicker = ImagePicker(); // pick an image
                      file = await imagepicker.pickImage(
                          source: ImageSource.gallery);
                    },
                    icon: Icon(Icons.camera_alt)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validating form inputs
                  if (eventDate.compareTo(DateTime.now()) < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Previous date event are not allowed")),
                    );
                    return;
                  }
                  if (toDouble(startTime) > toDouble(endTime)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Invalid Time. End time is before start time.")),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (file == null) {
                      print("No file selected!");
                    } else {
                      print("${file?.path} added!");
                      String filename =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Reference refDir =
                          FirebaseStorage.instance.ref().child('images');
                      Reference imgToUpload = refDir.child(filename);
                      String filePath = (file?.path)!;
                      try {
                        await imgToUpload.putFile(File(filePath));
                        imageURL = await imgToUpload.getDownloadURL();
                      } catch (error) {
                        print(error);
                      }
                    }
                  }
                  firebaseDatabase.addEventFB(
                      eventTitle,
                      eventType,
                      eventDesc,
                      eventVenue,
                      "${eventDate.day}/${eventDate.month}/${eventDate.year}",
                      "${startTime.hour}:${startTime.minute}",
                      "${endTime.hour}:${endTime.minute}",
                      imageURL,
                      "admin");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Event Added Sucessfully")),
                  );
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
