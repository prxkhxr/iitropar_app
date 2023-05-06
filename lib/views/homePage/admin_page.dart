import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';

import '../admin/add_course_csv.dart';
import '../admin/add_event.dart';
import '../admin/add_event_csv.dart';
import '../admin/add_holidays.dart';
import '../admin/change_time_table.dart';
import '../admin/faculty_courses.dart';
import '../admin/registerClub.dart';
import '../admin/registerFaculty.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Color(secondaryLight),
        title: buildTitleBar("HOME", context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AdminCard(context, const AddEvent(), "Add Event"),
                AdminCard(context, const addEventcsv(), "Add Event Using CSV"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AdminCard(
                    context, const addCoursecsv(), "Add Course Using CSV"),
                AdminCard(context, const registerClub(), "Register Club"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AdminCard(context, const addHoliday(), "Declare Holiday"),
                AdminCard(
                    context, const changeTimetable(), "Change time table"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AdminCard(context, const registerFaculty(), "Register Faculty"),
                AdminCard(
                    context, const FacultyList(), "Manage Faculty & Courses"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
