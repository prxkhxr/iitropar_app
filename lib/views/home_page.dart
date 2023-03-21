import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
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
