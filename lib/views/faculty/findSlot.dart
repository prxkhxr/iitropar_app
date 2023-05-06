// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/loader.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:iitropar/views/faculty/seeSlots.dart';

//to do build a function to access all the events
class findSlots extends StatefulWidget {
  const findSlots({super.key});

  @override
  State<findSlots> createState() => _findSlotsState();
}

class _findSlotsState extends State<findSlots> {
  Set<String> students = {};
  int slotLength = 1;
  bool inputFormat = true;
  DateTime date = DateTime.now();
  TextEditingController entryInput = TextEditingController();

  bool verifyHeader(List<dynamic> csv_head) {
    if (csv_head.isEmpty) {
      return false;
    }
    String header = csv_head[0].toLowerCase();
    if (header.compareTo("entrynumber") == 0 ||
        header.compareTo("entry number") == 0) {
      return true;
    }
    return false;
  }

  Future<bool> checkEntryNumber(String entryNumber) async {
    RegExp regex = RegExp(r"^[0-9]{4}[a-z]{3}[0-9]{4}$");
    if (regex.hasMatch(entryNumber)) {
      bool check =
          await firebaseDatabase.checkIfDocExists("courses", entryNumber);
      if (!check) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Entry Number ${entryInput.text} is not in the database")));
      }
      return check;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Entry Number ${entryInput.text} is not valid")));
    return false;
  }

  void getStudentsCSV(List<dynamic> fields) async {
    inputFormat = true;
    Set<String> studs = {};
    for (int i = 1; i < fields.length; i++) {
      String entryNumber = fields[i][0].toString().toLowerCase();
      if (await checkEntryNumber(entryNumber)) {
        studs.add(entryNumber);
      } else {
        print(entryNumber);
        inputFormat = false;
      }
    }
    setState(() {
      students = studs;
    });
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    String filePath = result.files.first.path!;

    final input = File(filePath).openRead();
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
      getStudentsCSV(fields);
    }
  }

  Widget addSingleStudent() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            controller: entryInput,
            decoration: const InputDecoration(
                icon: Icon(Icons.description),
                labelText: "Enter Entry Number "),
          )),
      IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            if (await checkEntryNumber(entryInput.text)) {
              setState(() {
                students.add(entryInput.text);
              });
            } else {}
          }),
    ]);
  }

  Widget getStudents() {
    return Center(
        child: Column(children: [
      addSingleStudent(),
      const Text('OR'),
      const SizedBox(height: 10),
      ElevatedButton(
        child: const Text("Upload FIle"),
        onPressed: () {
          _pickFile(ScaffoldMessenger.of(context));
        },
      ),
      const Text('1 . Accepted CSV format is given below'),
      const SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Image.asset('assets/admin_course_format.png'),
      ),
      const SizedBox(height: 5),
    ]));
  }

  Widget showSelectedStudents() {
    return Column(
      children: [
        const Text('Selected Students'),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Expanded(
            child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            students.remove(students.elementAt(index));
                          });
                        },
                      ),
                      title: Text(students.elementAt(index)));
                }),
          ),
        ),
      ],
    );
  }

  Widget getSlot() {
    return Center(
      child: Column(
        children: [
          const Text('Select Slot Lenght (in hours)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (slotLength != 1) {
                    setState(() {
                      slotLength = slotLength > 0 ? slotLength - 1 : 0;
                    });
                  }
                },
              ),
              Text(
                '$slotLength',
                style: const TextStyle(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (slotLength != 12) {
                    setState(() {
                      slotLength++;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget getDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          child: const Text('Pick Event Date'),
          onPressed: () {
            showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100))
                .then((value) {
              if (value != null && value != date) {
                setState(() {
                  date = value;
                });
              }
            });
          },
        ),
        const SizedBox(width: 20),
        Text("${date.day}/${date.month}/${date.year}",
            style: const TextStyle(fontSize: 32)),
      ],
    );
  }

  Widget submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          // Validating form inputs
          DateTime currentDate = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
          if (date.compareTo(currentDate) < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Previous date event are not allowed")),
            );
            return;
          }
          if (students.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Add atleast one student")),
            );
            return;
          }
          List<int> conflicts =
              await getConflicts(slotLength, date, students.toList());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      seeSlots(slotLength: slotLength, conflicts: conflicts)));
        },
        child: const Text('Submit'),
      ),
    );
  }

  Future<List<int>> getConflicts(
      int slotLength, DateTime date, List<String> students) async {
    List<int> conflicts = List.filled(12 - 2 * slotLength, 0);

    if (Loader.courseToSlot == null) {
      await Loader.loadCourseSlot();
    }
    if (Loader.slotToTime == null) {
      await Loader.loadSlotTime();
    }
    for (int m = 0; m < students.length; m++) {
      var courses = await firebaseDatabase.getCourses(students[m]);
      for (int i = 0; i < courses.length; i++) {
        courses[i] = courses[i].replaceAll(' ', '');
      }

      for (int i = 0; i < courses.length; i++) {
        for (int j = 0; j < 2; j++) {
          String? slot = Loader.courseToSlot![courses[i]];
          //  Processes as Tutorial or Class
          slot = (j == 0) ? (slot) : ('T-$slot');
          List<String>? times = Loader.slotToTime![slot];
          if (times == null) continue;

          for (int k = 0; k < times.length; k++) {
            var l = times[k].split('|');
            String day = l[0];
            const weekdays = [
              'monday',
              'tuesday',
              'wednesday',
              'thursday',
              'friday',
              'saturday',
              'sunday'
            ];
            if (day.compareTo(weekdays[date.weekday - 1]) != 0) continue;

            TimeOfDay s = str2tod(l[1]);
            TimeOfDay e = str2tod(l[2]);
            int from = s.hour;
            int to = (e.minute == 0) ? e.hour : e.hour + 1;

            int slotStart = 8;
            int slotEnd = slotStart + slotLength;
            int idx = 0;
            for (; idx < (conflicts.length) / 2; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
            slotStart = 14;
            slotEnd = slotStart + slotLength;
            for (; idx < conflicts.length; idx++) {
              if (from >= slotStart && from < slotEnd) {
                conflicts[idx]++;
              } else if (to > slotStart && to <= slotEnd) {
                conflicts[idx]++;
              }
              slotStart++;
              slotEnd++;
            }
          }
        }
      }
    }
    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: buildTitleBar("Find Slots", context),
          elevation: 0,
          backgroundColor: Color(secondaryLight),
        ),
        // drawer: const NavDrawer(),
        body: Column(children: [
          getStudents(),
          divider(),
          getSlot(),
          getDate(),
          divider(),
          submitButton(),
          showSelectedStudents()
        ]));
  }
}
