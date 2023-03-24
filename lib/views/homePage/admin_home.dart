import 'package:flutter/material.dart';
import 'package:iitropar/views/admin/add_event.dart';
import 'package:iitropar/views/admin/add_event_csv.dart';
import 'package:iitropar/views/admin/add_course_csv.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/admin/registerClub.dart';

import 'home_page.dart';

class AdminHome extends AbstractHome {
  const AdminHome({super.key});

  @override
  State<AbstractHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends HomePageState {
  void _signout() async {
    await FirebaseServices().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home Page"),
      ),
      drawer: const NavDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddEvent()));
              },
              child: Text("Add Event"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => addEventcsv()));
              },
              child: Text("Add Event using CSV file"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => addCoursecsv()));
              },
              child: Text("Add Course List of students "),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => registerClub()));
              },
              child: Text("Register a club"),
            ),
          ],
        ),
      ),
    );
  }

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

    return l;
  }
}
