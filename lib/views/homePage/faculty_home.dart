import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/faculty/findSlot.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/faculty/scheduleCourse.dart';
import 'package:iitropar/views/faculty/showClasses.dart';
import '../../utilities/colors.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyHome extends AbstractHome {
  const FacultyHome({super.key});

  @override
  State<AbstractHome> createState() => _FacultyHomeState();
}

class _FacultyHomeState extends AbstractHomeState {
  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => findSlots(f.courses)));
      },
      child: Text(
        "Check Free Slots",
        style: TextStyle(color: Color(secondaryLight)),
      ),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CourseSchedule(courses: f.courses)));
      },
      child: Text(
        "Schedule Extra Class",
        style: TextStyle(color: Color(secondaryLight)),
      ),
    ));
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyClass(courses: f.courses)));
      },
      child: Text(
        "See added extra classes",
        style: TextStyle(color: Color(secondaryLight)),
      ),
    ));
    return l;
  }
}
