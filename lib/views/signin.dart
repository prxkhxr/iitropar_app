import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/PBTabView.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/database/local_db.dart';

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
      color: Color(secondaryLight),
    );
  }

  void _signin() async {
    await FirebaseServices().signInWithGoogle();
    if (FirebaseAuth.instance.currentUser == null) return;
    if ((await Ids.resolveUser()).compareTo('student') == 0) {
      await EventDB().loadCourse(await firebaseDatabase
          .getCourses(FirebaseAuth.instance.currentUser!.email!.split('@')[0]));
    }
    _moveToHome();
  }

  void _moveToHome() {
    RootPage.signin(false);
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const RootPage(),
        settings: const RouteSettings(name: '/'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double buttonMargin = 30;
    final double buttonWidth = (screenSize.width - 2 * buttonMargin) * 0.8;

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // stops: const [
            //   0.1,
            //   0.4,
            //   0.6,
            //   0.9,
            // ],
            colors: [Color(0xff111111), Color(0xff333333)],
          )),
          // margin: EdgeInsets.symmetric(horizontal: 80),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: screenSize.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "IIT Connect",
                        style: TextStyle(
                            color: Color(secondaryLight),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                logoWidget('assets/iitropar_logo.png'),
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: buttonMargin),
                    child: ElevatedButton(
                      onPressed: () {
                        _signin(); // navigate according to the email id
                      },
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Color(secondaryLight);
                      })),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: buttonWidth * 0.8,
                              child: Text(
                                "Login with Gmail",
                                style: TextStyle(
                                  color: Color(primaryLight),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            Image.asset(
                              "assets/google.png",
                              width: buttonWidth * 0.2,
                              height: buttonWidth * 0.2,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: buttonMargin),
                    child: ElevatedButton(
                        onPressed: () {
                          _moveToHome();
                        },
                        style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Color(secondaryLight);
                        })),
                        child: SizedBox(
                          width: buttonWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Login as Guest",
                                style: TextStyle(
                                    color: Color(primaryLight),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                            ],
                          ),
                        )),
                  ),
                ])
              ]),
        ),
      ),
    );
  }
}
