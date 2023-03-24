import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EventDB.startInstance();
  bool signin = false;
  if (await EventDB.firstRun() || FirebaseAuth.instance.currentUser == null) {
    signin = true;
  }
  runApp(App(signin: signin));
}

class App extends StatelessWidget {
  final bool signin;
  const App({required this.signin, super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIT Ropar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      home: (signin) ? (const SignInScreen()) : (const HomePage()),
    );
  }
}
