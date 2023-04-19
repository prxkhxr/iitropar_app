// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class seeSlots extends StatefulWidget {
  const seeSlots(
      {super.key, required this.slotLength, required this.conflicts});
  final int slotLength;
  final List<int> conflicts;
  @override
  State<seeSlots> createState() =>
      _seeSlotsState(slotLength: slotLength, conflicts: conflicts);
}

class GradientColorGenerator {
  static Color getColorFromGradient(int value) {
    final int colorValue = (value * 255 / 12).floor();
    return Color.fromRGBO(255 - colorValue, colorValue, 0, 1);
  }
}

class _seeSlotsState extends State<seeSlots> {
  _seeSlotsState({required this.slotLength, required this.conflicts});
  final int slotLength;
  final List<int> conflicts;

  Widget createWid(String startT, String endT, int conflict) {
    final Color color = GradientColorGenerator.getColorFromGradient(conflict);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                startT.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                endT.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conflicts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                conflict.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget viewSlots() {
    TimeOfDay slotStart = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay slotEnd = TimeOfDay(hour: 8 + slotLength, minute: 0);
    int totalSlots = 12 - 2 * slotLength;
    List<Widget> wids = [];
    for (int i = 0; i < totalSlots; i++) {
      wids.add(createWid(
          "${slotStart.hour.toString().padLeft(2, "0")}:${slotEnd.minute.toString().padLeft(2, "0")}",
          "${slotEnd.hour.toString().padLeft(2, "0")}:${slotEnd.minute.toString().padLeft(2, "0")}",
          conflicts[i]));
      slotStart = TimeOfDay(hour: slotStart.hour + 1, minute: 0);
      slotEnd = TimeOfDay(hour: slotEnd.hour + 1, minute: 0);

      if (slotStart.hour == 13) {
        wids.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Lunch Break")],
        ));
        slotStart = TimeOfDay(hour: slotStart.hour + 1, minute: 0);
        slotEnd = TimeOfDay(hour: slotEnd.hour + 1, minute: 0);
      }
    }
    return Container(
        child: SingleChildScrollView(child: Column(children: wids)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("SLOT LENGTH = $slotLength "),
        ),
        body: viewSlots());
  }
}

// Create a Form widget.

