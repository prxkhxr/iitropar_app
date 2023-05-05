import 'package:flutter/material.dart';
import 'package:iitropar/views/admin/add_event.dart';
import 'package:iitropar/views/admin/add_event_csv.dart';
import 'package:iitropar/views/admin/add_course_csv.dart';
import 'package:iitropar/views/admin/add_holidays.dart';
import 'package:iitropar/views/admin/faculty_courses.dart';
import 'package:iitropar/views/admin/registerClub.dart';
import 'package:iitropar/views/admin/change_time_table.dart';
import 'package:iitropar/views/admin/registerFaculty.dart';
import 'home_page.dart';

class AdminHome extends AbstractHome {
  const AdminHome({super.key});

  @override
  State<AbstractHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends AbstractHomeState {
  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);

    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AddEvent()));
      },
      child: const Text("Add Event"),
    ));

    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const addEventcsv()));
      },
      child: const Text("Add Event using CSV file"),
    ));

    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const addCoursecsv()));
      },
      child: const Text("Add Course List of students"),
    ));

    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const registerClub()));
      },
      child: const Text("Register a club"),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const addHoliday()));
      },
      child: const Text("Declare Holiday"),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const changeTimetable()));
      },
      child: const Text("Change time table"),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const registerFaculty()));
      },
      child: const Text("Register Faculty"),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FacultyList()));
      },
      child: const Text("Manage Faculty and Courses"),
    ));

    return l;
  }
}
