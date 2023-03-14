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
  void uploadData(List<List<dynamic>> _events) {
    int len = _events.length;
    for (int i = 1; i < len; i++) {
      firebaseDatabase.addEventFB(
          _events[i][0],
          _events[i][1],
          _events[i][2],
          _events[i][3],
          _events[i][4],
          _events[i][5],
          _events[i][6],
          _events[i][7]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Added data sucessfully")));
    }
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
          title: const Text("Add Event using csv"),
        ),
        body: Center(
          child: Column(children: [
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Upload FIle"),
              onPressed: () {
                _pickFile();
              },
            )
          ]),
        ));
  }
}
