import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/club/add_club_event.dart';

import 'home_page.dart';

class ClubHome extends AbstractHome {
  const ClubHome({super.key});

  @override
  State<AbstractHome> createState() => _ClubHomeState();
}

class _ClubHomeState extends HomePageState {
  String clubName = "";

  _ClubHomeState() {
    firebaseDatabase
        .getClubName(FirebaseAuth.instance.currentUser!.email!)
        .then((value) {
      setState(() {
        clubName = value;
      });
    });
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => addClubEvent(
                      clubName: clubName,
                    )));
      },
      child: const Text("Add Event"),
    ));

    return l;
  }
}
