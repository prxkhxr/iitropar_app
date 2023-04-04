import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/views/homePage/admin_home.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/landing_page.dart';

abstract class AbstractHome extends StatefulWidget {
  const AbstractHome({super.key});
}

abstract class AbstractHomeState extends State<AbstractHome> {
  CircleAvatar getUserImage() {
    var image;
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.photoURL != null) {
      image =
          NetworkImage(FirebaseAuth.instance.currentUser!.photoURL.toString());
    } else {
      image = AssetImage('assets/user.png');
    }
    return CircleAvatar(
      backgroundImage: image,
      radius: 50,
    );
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Home Page"),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[500]),
              child: const Text('Signout'),
            )
          ],
        ),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: getUserImage(),
                  ),
                  Column(
                    children: [
                      Text('Hey ${getUserName()}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.black, // Set text color to blue
                            fontSize: 24, // Set text size to 24
                            fontWeight:
                                FontWeight.bold, // Set text font to bold
                          )),
                      SizedBox(height: 5),
                      Text('  How are you doing today?',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.black, // Set text color to blue
                            fontSize:
                                24, // Set text size to 24// Set text font to bold
                          )),
                    ],
                  ),
                ],
              ), // Set text alignment to center
              Divider(
                color: Colors.black,
                height: 30,
                thickness: 1,
                indent: 30,
                endIndent: 30,
              ),
              ...buttons(),
            ],
          ),
        ),
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
