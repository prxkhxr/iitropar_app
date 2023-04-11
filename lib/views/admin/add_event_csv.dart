// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';

class addEventcsv extends StatefulWidget {
  const addEventcsv({super.key});

  @override
  State<addEventcsv> createState() => _addEventcsvState();
}

class _addEventcsvState extends State<addEventcsv> {
  List<List<dynamic>> _data = [];
  String? filePath;
  bool checkData(List<List<dynamic>> events) {
    int len = events.length;
    RegExp time_regex = RegExp(r'^[0-2]?[0-9]:[0-6]?[0-9]$');
    RegExp date_regex = RegExp(r'^[0-3]?[0-9]/[0-1]?[0-9]/[0-9]{4}$');
    for (int i = 1; i < len; i++) {
      if (!date_regex.hasMatch(events[i][4])) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Date format at line $i is incorrect - ${events[i][4]}")));
        return false;
      }
      if (!time_regex.hasMatch(events[i][5].toString())) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Time format at line $i is incorrect - ${events[i][5]}")));
        return false;
      }
      if (!time_regex.hasMatch(events[i][6].toString())) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Time format at line $i is incorrect - ${events[i][6]}")));
        return false;
      }
    }
    return true;
  }

  void uploadData(List<List<dynamic>> events) {
    int len = events.length;
    for (int i = 1; i < len; i++) {
      firebaseDatabase.addEventFB(
          events[i][0],
          events[i][1],
          events[i][2],
          events[i][3],
          events[i][4],
          events[i][5],
          events[i][6],
          events[i][7],
          "admin");
    }
  }

  void _pickFile(ScaffoldMessengerState sm) async {
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
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
      if (checkData(fields)) {
        uploadData(fields);
      }
    }
    setState(() {
      _data = fields;
    });
  }

  bool verifyHeader(List<dynamic> header) {
    if (header.length != 8) return false;
    if (header[0].toString() != "eventTitle" ||
        header[1].toString() != "eventType" ||
        header[2].toString() != "eventDesc" ||
        header[3].toString() != "eventVenue" ||
        header[4].toString() != "date" ||
        header[5].toString() != "startTime" ||
        header[6].toString() != "endTime" ||
        header[7].toString() != "imgURL") return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Events using csv"),
        ),
        body: Center(
          child: Column(children: [
            const SizedBox(height: 50),
            ElevatedButton(
              child: const Text("Upload FIle"),
              onPressed: () {
                _pickFile(ScaffoldMessenger.of(context));
              },
            ),
            const SizedBox(height: 50),
            const Text('1 . Accepted CSV format is given below'),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset('assets/admin_csv_format.png'),
            ),
            const SizedBox(height: 5),
            const Text('2 . Time should be of the form HH:MM'),
            const SizedBox(height: 20),
            const Text('3. Date should be of the format DD/MM/YYYY')
          ]),
        ));
  }
}
