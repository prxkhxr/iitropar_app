import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/club/add_club_event.dart';

import '../../utilities/colors.dart';
import 'home_page.dart';

class FacultyHome extends AbstractHome {
  const FacultyHome({super.key});

  @override
  State<AbstractHome> createState() => _FacultyHomeState();
}

class _FacultyHomeState extends AbstractHomeState {
  String facultyName = "";
  String facultyDep = "";

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(ElevatedButton(
      onPressed: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => addClubEvent(
        //               clubName: facultyName,
        //             )));
      },
      child: Text(
        "Check Free Slots",
        style: TextStyle(color: Color(secondaryLight)),
      ),
    ));

    return l;
  }
}
