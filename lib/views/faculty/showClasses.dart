import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class MyClass extends StatefulWidget {
  final Set<dynamic> courses;
  MyClass({required this.courses});
  @override
  _MyClassState createState() => _MyClassState();
}

class _MyClassState extends State<MyClass> {
  late List<ExtraClass> filteredEc = [];
  late String selectedCourse;
  late List<ExtraClass> allClasses;
  getAllClasses() async {
    allClasses = await firebaseDatabase.getExtraCass(selectedCourse);
    filteredEc =
        allClasses.where((ec) => ec.courseID == selectedCourse).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectedCourse = widget.courses
        .first; // initialize selectedCourse to the first coursegetAllClasses();
  }

  @override
  Widget build(BuildContext context) {
    getAllClasses();
    return Scaffold(
      appBar: AppBar(
        title: Text('See Extra Classes'),
      ),
      body: Column(
        children: [
          DropdownButton(
            value: selectedCourse,
            onChanged: (value) {
              setState(() {
                selectedCourse = value.toString();
                filteredEc = allClasses
                    .where((ec) => ec.courseID == selectedCourse)
                    .toList();
              });
            },
            items: widget.courses
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
                return ListTile(
                  title: Text(ec.description),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Venue: ${ec.venue}'),
                      Text('Date: ${dateString(ec.date)}'),
                      Text('Start Time: ${TimeString(ec.startTime)}'),
                      Text('End Time: ${TimeString(ec.endTime)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // TODO: Implement delete functionality here
                      firebaseDatabase.deleteClass(ec);
                      setState(() {});
                    },
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
