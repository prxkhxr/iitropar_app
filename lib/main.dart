import 'package:flutter/material.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/home_page.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/views/admin/home_page_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const SignInScreen(),
    );
  }
}
