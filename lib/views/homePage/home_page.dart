import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/views/homePage/admin_home.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:iitropar/views/signin.dart';

abstract class AbstractHome extends StatefulWidget {
  const AbstractHome({super.key});
}

abstract class HomePageState extends State<AbstractHome> {
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

  List<Widget> buttons();

  Future<bool> _signout() async {
    await FirebaseServices().signOut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      drawer: const NavDrawer(),
      body: Column(
        children: [
          getUserImage(),
          Text('Name: ${getUserName()}'),
          ...buttons(),
          ElevatedButton(
            onPressed: () {
              LoadingScreen.setTask(_signout);
              LoadingScreen.setPrompt('Signing Out');
              LoadingScreen.setBuilder((context) => const LandingPage());
              LandingPage.signin(true);
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: LoadingScreen.build,
                      settings: const RouteSettings(name: '/')));
            },
            child: const Text('Signout'),
          )
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
  String user = "guest";

  Future<bool> resolveUser() async {
    var adminEmails = ["2020csb1086@iitrpr.ac.in"];
    var clubEmails = await firebaseDatabase.getClubIds();
    if (FirebaseAuth.instance.currentUser != null &&
        adminEmails.contains(FirebaseAuth.instance.currentUser!.email)) {
      user = "admin";
    } else if (FirebaseAuth.instance.currentUser != null &&
        clubEmails.contains(FirebaseAuth.instance.currentUser!.email)) {
      user = "club";
    } else {
      user = "student";
    }
    return true;
  }

  Widget userScreen(BuildContext context) {
    if (user.compareTo('admin') == 0) {
      return const AdminHome();
    } else if (user.compareTo('club') == 0) {
      return const ClubHome();
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
