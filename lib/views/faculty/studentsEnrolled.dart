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

class studentsEnrolled extends StatefulWidget {
  final String course;
  const studentsEnrolled({super.key, required this.course});
  @override
  State<studentsEnrolled> createState() => _studentsEnrolledState();
}

class _studentsEnrolledState extends State<studentsEnrolled> {
  late List<List<dynamic>> studentList = [];
  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  void _getStudents() async {
    List<List<dynamic>> students =
        await firebaseDatabase.getStudentsWithName(widget.course);
    setState(() {
      studentList = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students Enrolled"),
      ),
      body: ListView.builder(
        itemCount: studentList.length,
        itemBuilder: (context, index) {
          final student = studentList[index];
          return ListTile(
            title: Text('${student[0]} (${student[1]})'),
          );
        },
      ),
    );
  }
}
