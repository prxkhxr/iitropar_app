import 'package:flutter/material.dart';
import 'package:iitropar/views/admin/add_event.dart';
import 'package:iitropar/views/admin/add_event_csv.dart';
import 'package:iitropar/views/admin/add_course_csv.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/signin.dart';
import 'package:iitropar/utilities/firebase_services.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
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
            Text(getUserName()),
            getUserImage(),
            ElevatedButton(
              onPressed: () async {
                await FirebaseServices().signOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              child: Text("Logout"),
            ),
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
          ],
        ),
      ),
    );
  }

  Image getUserImage() {
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.photoURL != null) {
      return Image.network(
          FirebaseAuth.instance.currentUser!.photoURL.toString());
    }
    return Image.asset('assets/user.jpg', height: 100, width: 100);
  }

  String getUserName() {
    if (FirebaseAuth.instance.currentUser == null) return "Guest User";
    return FirebaseAuth.instance.currentUser!.displayName.toString();
  }
}
