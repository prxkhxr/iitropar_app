// ignore_for_file: camel_case_types, file_names, no_logic_in_create_state

import 'package:flutter/material.dart';

class ConflictSlot {
  TimeOfDay start;
  TimeOfDay end;
  int conflicts;

  ConflictSlot(this.start, this.end, this.conflicts);
}

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
              const Text(
                'Start Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                startT.toString(),
                style: const TextStyle(
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
              const Text(
                'End Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                endT.toString(),
                style: const TextStyle(
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
              const Text(
                'Conflicts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                conflict.toString(),
                style: const TextStyle(
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

    List<ConflictSlot> conflictSlots = List.empty(growable: true);
    for (int i = 0; i < totalSlots; i++) {
      conflictSlots.add(ConflictSlot(slotStart, slotEnd, conflicts[i]));
      slotStart = TimeOfDay(hour: slotStart.hour + 1, minute: 0);
      slotEnd = TimeOfDay(hour: slotEnd.hour + 1, minute: 0);

      if (slotStart.hour <= 13 && slotEnd.hour > 13) {
        slotStart = const TimeOfDay(hour: 14, minute: 0);
        slotEnd = TimeOfDay(hour: 14 + slotLength, minute: 0);
      }
    }
    conflictSlots.sort((a, b) {
      if (a.conflicts < b.conflicts) {
        return -1;
      } else if (a.conflicts == b.conflicts) {
        return 0;
      } else {
        return 1;
      }
    });

    for (int i = 0; i < totalSlots; i++) {
      wids.add(createWid(
          "${conflictSlots[i].start.hour.toString().padLeft(2, "0")}:${conflictSlots[i].start.minute.toString().padLeft(2, "0")}",
          "${conflictSlots[i].end.hour.toString().padLeft(2, "0")}:${conflictSlots[i].end.minute.toString().padLeft(2, "0")}",
          conflictSlots[i].conflicts));
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

