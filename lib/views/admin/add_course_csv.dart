// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'dart:convert';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:path/path.dart' as p;

class addCoursecsv extends StatefulWidget {
  const addCoursecsv({super.key});

  @override
  State<addCoursecsv> createState() => _addCoursecsvState();
}

class _addCoursecsvState extends State<addCoursecsv> {
  List<List<dynamic>> _data = [];
  String? filePath;
  bool checkData(List<List<dynamic>> events) {
    int len = events.length;
    for (int i = 1; i < len; i++) {
      int num_of_courses = events[i].length;
      for (int j = 1; j < num_of_courses; j++) {
        print(events[i][j]);
      }
    }
    return false;
  }

  void uploadData(List<List<dynamic>> events) {
    //toDo
    int len = events.length;
    for (int i = 1; i < len; i++) {
      List<dynamic> courses = [];
      int num_of_courses = events[i].length;
      for (int j = 2; j < num_of_courses; j++) {
        events[i][j] = events[i][j].toString().trim().replaceAll(' ', '');
        if (events[i][j] != "") {
          courses.add(events[i][j].toString().toUpperCase().trim());
        }
      }
      firebaseDatabase.addCourseFB(events[i][0], events[i][1], courses);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploaded data sucessfully")));
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    if (!verifyHeader(fields[0])) {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
      uploadData(fields);
    }
    setState(() {
      _data = fields;
    });
  }

  bool verifyHeader(List<dynamic> header) {
    return (header[0].toString().toLowerCase().trim() ==
            "entryNumber".toLowerCase()) &&
        (header[1].toString().toLowerCase().trim() == "name");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("ADD COURSES USING CSV", context),
        ),
        body: Column(children: [
          const SizedBox(height: 50),
          const Text('Accepted CSV format is given below',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset('assets/admin_course_format.png'),
          ),
          const SizedBox(height: 5),
          const Text(
            'Ensure that you enter valid entryNumber and courseCode',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Color(primaryLight)),
            ),
            child: const Text("Upload File"),
            onPressed: () {
              _pickFile(ScaffoldMessenger.of(context));
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Color(primaryLight)),
            ),
            child: const Text("Download Sample"),
            onPressed: () async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result == null) {
                return;
              }
              File nfile = File(p.join(result, 'courseSample.csv'));
              nfile.writeAsString(
                  await rootBundle.loadString('assets/courseSample.csv'));
            },
          ),
        ]));
  }

  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back,
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
