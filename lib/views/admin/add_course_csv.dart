import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';

class addCoursecsv extends StatefulWidget {
  const addCoursecsv({super.key});

  @override
  State<addCoursecsv> createState() => _addCoursecsvState();
}

class _addCoursecsvState extends State<addCoursecsv> {
  List<List<dynamic>> _data = [];
  String? filePath;
  bool checkData(List<List<dynamic>> _events) {
    int len = _events.length;
    for (int i = 1; i < len; i++) {
      int num_of_courses = _events[i].length;
      for (int j = 1; j < num_of_courses; j++) {
        print(_events[i][j]);
      }
    }
    return false;
  }

  void uploadData(List<List<dynamic>> _events) {
    //toDo
    int len = _events.length;
    for (int i = 1; i < len; i++) {
      List<dynamic> courses = [];
      int num_of_courses = _events[i].length;
      for (int j = 1; j < num_of_courses; j++) {
        if (_events[i][j] != "") courses.add(_events[i][j]);
      }
      firebaseDatabase.addCourseFB(_events[i][0], courses);
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Uploaded data sucessfully")));
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    print(fields[0]);
    if (!verifyHeader(fields[0])) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Header format in csv correct!")));
      uploadData(fields);
    }
    setState(() {
      _data = fields;
    });
  }

  bool verifyHeader(List<dynamic> header) {
    if (header[0] == "entryNumber")
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Event using csv"),
        ),
        body: Center(
          child: Column(children: [
            SizedBox(height: 50),
            ElevatedButton(
              child: const Text("Upload FIle"),
              onPressed: () {
                _pickFile();
              },
            ),
            SizedBox(height: 50),
            Text('1 . Accepted CSV format is given below'),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset('assets/admin_course_format.png'),
            ),
            SizedBox(height: 5),
            Text('2 . Ensure that you enter valid entryNumber and courseCode'),
          ]),
        ));
  }
}
