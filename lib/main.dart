import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EventDB.startInstance();
  bool signin = false;
  if (EventDB.firstRun() || FirebaseAuth.instance.currentUser == null) {
    signin = true;
  } else if (FirebaseAuth.instance.currentUser != null) {
    signin = true;
    await Ids.resolveUser();
  }
  RootPage.signin(signin);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIT Ropar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      home: const RootPage(),
    );
  }
}
