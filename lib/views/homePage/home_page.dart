import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/homePage/admin_home.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/homePage/faculty_home.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/landing_page.dart';

abstract class AbstractHome extends StatefulWidget {
  const AbstractHome({super.key});
}

abstract class AbstractHomeState extends State<AbstractHome> {
  CircleAvatar getUserImage(double radius) {
    ImageProvider image;
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.photoURL != null) {
      image =
          NetworkImage(FirebaseAuth.instance.currentUser!.photoURL.toString());
    } else {
      image = const AssetImage('assets/user.png');
    }
    return CircleAvatar(
      backgroundImage: image,
      radius: radius,
    );
  }

  String getUserName() {
    if (Ids.role.compareTo("faculty") == 0) {
      return Ids.name;
    }
    if (FirebaseAuth.instance.currentUser == null) return "Guest User";
    return FirebaseAuth.instance.currentUser!.displayName.toString();
  }

  List<Widget> buttons();

  Widget getText() {
    if (Ids.role.compareTo("faculty") == 0) {
      return Text(Ids.dep,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(primaryLight), // Set text color to blue
            fontSize: 18, // Set text size to 24// Set text font to bold
          ));
    }
    return Text('How are you doing today?',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Color(primaryLight), // Set text color to blue
          fontSize: 18, // Set text size to 24// Set text font to bold
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.2;
    final textSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: Color(secondaryLight),
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Color(secondaryLight),
        title: buildTitleBar("HOME", context),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(children: [
                getUserImage(iconSize / 2 - 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: textSize,
                        child: Text('Hey! ${getUserName()}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color:
                                  Color(primaryLight), // Set text color to blue
                              fontSize: 22, // Set text size to 24
                              fontWeight:
                                  FontWeight.bold, // Set text font to bold
                            ))),
                    SizedBox(
                      width: textSize,
                      child: getText(),
                    )
                  ],
                ),
              ])), // Set text alignment to center
          Divider(
            color: Color(primaryLight),
            height: 30,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Column(
                  children: [
                    ...buttons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String user = "guest";
  Future<bool> resolveUser() async {
    user = await Ids.resolveUser();
    return true;
  }

  Widget userScreen(BuildContext context) {
    if (user.compareTo('admin') == 0) {
      return const AdminHome();
    } else if (user.compareTo('club') == 0) {
      return const ClubHome();
    } else if (user.compareTo('faculty') == 0) {
      return const FacultyHome();
    }
    return const StudentHome();
  }

  @override
  Widget build(BuildContext context) {
    LoadingScreen.setPrompt("Loading Home...");
    LoadingScreen.setTask(resolveUser);
    LoadingScreen.setBuilder(userScreen);
    return LoadingScreen.build(context);
  }
}
