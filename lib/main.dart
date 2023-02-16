import 'package:flutter/material.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/home_page.dart';
import 'package:iitropar/views/events.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIT Ropar App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const EventCalendarScreen(),
        '/login': (context) => const HomePage(),
        '/events': (context) => const Events(),
      }
    );
  }
}
