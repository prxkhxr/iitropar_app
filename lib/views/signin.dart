import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/admin/home_page_admin.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/club/home_page_club.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Image logoWidget(String imageName) {
    return Image.asset(
      imageName,
      fit: BoxFit.fitWidth,
      width: 240,
      height: 240,
      color: Colors.black,
    );
  }

  void getUserScreen() async {
    var admin_email = ["2020csb1086@iitrpr.ac.in"];
    List<dynamic> Email = await firebaseDatabase.getClubIds();
    if (FirebaseAuth.instance.currentUser != null &&
        admin_email.contains(FirebaseAuth.instance.currentUser!.email)) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePageAdmin()));
    } else if (FirebaseAuth.instance.currentUser != null &&
        Email.contains(FirebaseAuth.instance.currentUser!.email)) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePageClub()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.1,
                0.4,
                0.6,
                0.9,
              ],
              colors: [
                Colors.grey,
                Colors.blue,
                Colors.blue,
                Colors.grey,
              ],
            )),
            // margin: EdgeInsets.symmetric(horizontal: 80),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  logoWidget('assets/iitropar_logo.png'),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseServices().signInWithGoogle();
                        getUserScreen(); // navigate according to the email id
                      },
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Colors.grey[100];
                      })),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Login with Gmail",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                              Image.asset(
                                "assets/google.png",
                                width: 40,
                                height: 40,
                              ),
                            ]),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Colors.grey[100];
                      })),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Login as Guest",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
