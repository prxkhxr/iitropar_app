import 'package:flutter/material.dart';
import 'package:iitropar/views/event_calendar.dart';

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
      home: const EventCalendarScreen(),
    );
  }
}
