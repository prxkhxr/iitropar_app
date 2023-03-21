import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/admin/add_event.dart';
import 'package:iitropar/views/admin/add_event_csv.dart';
import 'package:iitropar/views/admin/add_course_csv.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/signin.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/admin/registerClub.dart';
import 'package:iitropar/views/club/add_club_event.dart';

class HomePageClub extends StatefulWidget {
  const HomePageClub({super.key});

  @override
  State<HomePageClub> createState() => _HomePageClubState();
}

class _HomePageClubState extends State<HomePageClub> {
  String clubName = "";

  _HomePageClubState() {
    firebaseDatabase
        .getClubName(FirebaseAuth.instance.currentUser!.email!)
        .then((value) {
      setState(() {
        clubName = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$clubName Home Page"),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => addClubEvent(
                              clubName: clubName,
                            )));
              },
              child: Text("Add Event"),
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
    return Image.asset('assets/user.png', height: 100, width: 100);
  }

  String getUserName() {
    if (FirebaseAuth.instance.currentUser == null) return "Guest User";
    return FirebaseAuth.instance.currentUser!.displayName.toString();
  }
}
