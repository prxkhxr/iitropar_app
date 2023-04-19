import 'package:flutter/material.dart';

class Event {
  final String title;
  final String desc;
  final TimeOfDay stime;
  final TimeOfDay etime;
  final String creator;
  int? id;

  Event(
      {required this.title,
      required this.desc,
      required this.stime,
      required this.etime,
      required this.creator,
      this.id});

  String startTime() {
    return tod2str(stime);
  }

  String endTime() {
    return tod2str(etime);
  }

  String displayTime() {
    return '${_convertTo12(stime)}-${_convertTo12(etime)}';
  }

  int compareTo(Event other) {
    if (stime.hour < other.stime.hour) return -1;
    if (stime.hour > other.stime.hour) return 1;
    if (stime.minute < other.stime.minute) return -1;
    if (stime.minute > other.stime.minute) return 1;
    return 0;
  }
}

String _convertTo12(TimeOfDay tod) {
  int h = tod.hour;
  String s = 'AM';

  if (h >= 12) {
    s = 'PM';
  }
  if (h > 12) {
    h -= 12;
  } else if (h == 0) {
    h = 12;
  }

  return '${h.toString().padLeft(2, "0")}:${tod.minute.toString().padLeft(2, "0")} $s';
}

String tod2str(TimeOfDay t) {
  return '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
}

TimeOfDay str2tod(String time) {
  int hour = int.parse(time.split(':')[0]);
  int min = int.parse(time.split(':')[1]);
  return TimeOfDay(hour: hour, minute: min);
}
