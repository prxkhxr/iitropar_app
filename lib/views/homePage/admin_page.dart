import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';

import '../../database/loader.dart';
import '../admin/add_course_csv.dart';
import '../admin/add_event.dart';
import '../admin/add_event_csv.dart';
import '../admin/add_holidays.dart';
import '../admin/change_time_table.dart';
import '../admin/faculty_courses.dart';
import '../admin/registerClub.dart';
import '../admin/registerFaculty.dart';
import '../admin/start_sem.dart';

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
        title: buildTitleBar("ADMIN-HOME", context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register",
                style: TextStyle(
                    color: Color(primaryLight),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(
                        context, const NewSemester(), "Start New Semester"),
                    AdminCard(
                        context, const registerFaculty(), "Register Faculty"),
                    AdminCard(context, const FacultyList(),
                        "Manage Faculty & Courses"),
                    AdminCard(context, const addCoursecsv(),
                        "Add Student Record (CSV)"),
                    AdminCard(context, const registerClub(), "Register Club"),
                  ],
                ),
              ),
              Text(
                "Alter Time-Table",
                style: TextStyle(
                    color: Color(primaryLight),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(context, const addHoliday(), "Declare Holiday"),
                    AdminCard(
                        context, const changeTimetable(), "Change time table"),
                  ],
                ),
              ),
              Text(
                "Add Events",
                style: TextStyle(
                    color: Color(primaryLight),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdminCard(context, const AddEvent(), "Add Event"),
                    AdminCard(
                        context, const addEventcsv(), "Add Event Using CSV"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget themeButtonWidget() {
  return IconButton(
    onPressed: () {
    },
    icon: const Icon(
      Icons.home,
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
