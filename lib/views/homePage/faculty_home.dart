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
  Widget allCourses() {
    List<dynamic> coursesList = f.courses.toList();
    if (coursesList.isEmpty) {
      return const Text('No Courses Registered');
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xff555555),
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
            color: Color(primaryLight),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Courses",
              style: TextStyle(
                  color: Color(primaryLight),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              height: 150,
              child: ListView.builder(
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: coursesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueGrey,
                    ),
                    child: ListTile(
                      title: Text(coursesList[index],
                          style: TextStyle(color: Color(secondaryLight)),),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(allCourses());
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
