// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class MyClass extends StatefulWidget {
  final Set<dynamic> courses;
  const MyClass({super.key, required this.courses});
  @override
  State<MyClass> createState() => _MyClassState();
}

class _MyClassState extends State<MyClass> {
  late List<ExtraClass> filteredEc = [];
  late String selectedCourse;
  late List<ExtraClass> allClasses;
  late Set<dynamic> allcourses = Set();
  getAllClasses() async {
    allClasses = await firebaseDatabase.getExtraClass(selectedCourse);
    filteredEc =
        allClasses.where((ec) => ec.courseID == selectedCourse).toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    allcourses = widget.courses;
    allcourses.add("None");
    selectedCourse = allcourses.first;
  }

  @override
  Widget build(BuildContext context) {
    getAllClasses();
    allcourses.add("None");
    return Scaffold(
      appBar: AppBar(
        title: const Text('See Extra Classes'),
      ),
      body: Column(
        children: [
          DropdownButton(
            value: selectedCourse,
            onChanged: (value) {
              setState(
                () {
                  selectedCourse = value.toString();
                  filteredEc = allClasses
                      .where((ec) => ec.courseID == selectedCourse)
                      .toList();
                },
              );
            },
            items: allcourses
                .map((course) => DropdownMenuItem(
                      value: course,
                      child: Text(course),
                    ))
                .toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEc.length,
              itemBuilder: (context, index) {
                final ec = filteredEc[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0.0, 8.0),
                      child: Center(
                        child: Text(
                          ec.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Venue: ${ec.venue}')),
                            Expanded(
                                child:
                                    Text('Date: ${formatDateWord(ec.date)}')),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    'Start Time: ${TimeString(ec.startTime)}')),
                            Expanded(
                                child: Text(
                                    'End Time: ${TimeString(ec.endTime)}')),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement delete functionality here
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: Text(
                                          "Do you really want to Delete class Scheduled on ${formatDateWord(ec.date)}?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () {
                                            firebaseDatabase.deleteClass(ec);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
