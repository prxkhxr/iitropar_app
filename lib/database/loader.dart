// ignore_for_file: non_constant_identifier_names

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/utilities/firebase_database.dart';

import 'event.dart';

class Loader {
  static String convertTo24(String time, String segment) {
    int hour = int.parse(time.split('.')[0]);
    int min = int.parse(time.split('.')[1]);
    if (segment.toLowerCase().compareTo('am') != 0) {
      if (hour != 12) hour += 12;
    } else if (hour == 12) {
      hour = 0;
    }
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}';
  }

  static Map<String, String>? courseToSlot;
  static Map<String, List<String>>? slotToTime;

  static Future<void> loadSlots() async {
    //  Load Slots of each Course
    var courseSlots = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/CourseSlots.csv'));
    int len = courseSlots.length;
    courseToSlot = {};
    for (int i = 0; i < len; i++) {
      if (courseSlots[i][0].runtimeType == int) {
        courseToSlot![courseSlots[i][1].replaceAll(' ', '')] =
            courseSlots[i][3];
      }
    }
  }

  static Future<void> loadTimes() async {
    var slotTimes = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/TimeTable.csv'));
    var len = slotTimes.length;
    slotToTime = {};

    // Process Times
    List<String> timings = slotTimes[0].cast<String>();
    for (int i = 1; i < timings.length; i++) {
      List<String> tokens = timings[i].split(' ');
      if (tokens.length != 4) continue;
      timings[i] =
          '${convertTo24(tokens[0], tokens[3])}|${convertTo24(tokens[2], tokens[3])}'
              .toLowerCase();
    }

    //  Load time corresponding to slots
    for (int i = 1; i < len; i++) {
      int sz = slotTimes[i].length;
      String weekday = slotTimes[i][0];
      weekday = weekday.toLowerCase();

      for (int j = 1; j < sz; j++) {
        String slot = slotTimes[i][j].replaceAll(' ', '');
        if (slotToTime![slot] == null) {
          slotToTime![slot] = List.empty(growable: true);
        }
        //  Add time to corresponding slot
        slotToTime![slot]!.add('$weekday|${timings[j]}'); // monday 8 - 8.50 AM
      }
    }
  }

  static Future<bool> saveCourses(List<String> course_id) async {
    //  Preprocess
    for (int i = 0; i < course_id.length; i++) {
      course_id[i] = course_id[i].replaceAll(' ', '');
    }

    if (courseToSlot == null) {
      await loadSlots();
    }
    if (slotToTime == null) {
      await loadTimes();
    }

    for (int i = 0; i < course_id.length; i++) {
      await saveExtraClasses(course_id[i]);
      for (int j = 0; j < 2; j++) {
        String? slot = courseToSlot![course_id[i]];
        //  Processes as Tutorial or Class
        slot = (j == 0) ? (slot) : ('T-$slot');
        String title = course_id[i];
        String desc = (j == 0) ? 'Class' : 'Tutorial';

        List<String>? times = slotToTime![slot];
        if (times == null) continue;

        for (int j = 0; j < times.length; j++) {
          var l = times[j].split('|');
          String day = l[0];
          int mask = 0;
          const weekdays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday'
          ];
          for (int k = 0; k < 7; k++) {
            if (day.compareTo(weekdays[k]) == 0) {
              mask = 1 << k;
              break;
            }
          }

          String stime = l[1];
          String etime = l[2];
          Event e = Event(
            title: title,
            desc: desc,
            stime: str2tod(stime),
            etime: str2tod(etime),
            creator: 'course',
          );
          await EventDB().addRecurringEvent(
            e,
            DateTime(2023),
            DateTime(2024),
            mask,
          );
        }
      }
    }

    return true;
  }

  static Future<void> loadMidSem(
    DateTime startDate,
    TimeOfDay morningSlot_start,
    TimeOfDay morningSlot_end,
    TimeOfDay eveningSlot_start,
    TimeOfDay eveningSlot_end,
    List<String> courses,
  ) async {
    var exams = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/MidSemTimeTable.csv'));

    if (courseToSlot == null) {
      await loadSlots();
    }

    Map<String, String> slotToDay = {};
    for (int i = 0; i < exams.length; i++) {
      if (exams[i].length != 2) {
        throw ArgumentError("Invalid CSV");
      }
      slotToDay[exams[i][0]] =
          "${dateString(startDate)}|${tod2str(morningSlot_start)}|${tod2str(morningSlot_end)}";
      slotToDay[exams[i][1]] =
          "${dateString(startDate)}|${tod2str(eveningSlot_start)}|${tod2str(eveningSlot_end)}";
      startDate = startDate.add(const Duration(days: 1));
      if (startDate.weekday == 7) {
        startDate = startDate.add(const Duration(days: 1));
      }
    }

    for (int i = 0; i < courses.length; i++) {
      var day = slotToDay[courseToSlot![courses[i]]];
      if (day == null) {
        continue;
      }
      var l = day.split('|');
      var e = Event(
        title: 'Mid-Semester Examinations',
        desc: courses[i],
        stime: str2tod(l[1]),
        etime: str2tod(l[2]),
        creator: 'exam',
      );
      EventDB().addSingularEvent(e, stringDate(l[0]));
    }
  }

  static Future<void> loadEndSem(
    DateTime startDate,
    TimeOfDay morningSlot_start,
    TimeOfDay morningSlot_end,
    TimeOfDay eveningSlot_start,
    TimeOfDay eveningSlot_end,
    List<String> courses,
  ) async {
    var exams = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/EndSemTimeTable.csv'));

    var courseSlots = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/CourseSlots.csv'));
    int len = courseSlots.length;
    Map<String, String> courseToSlot = {};
    for (int i = 0; i < len; i++) {
      if (courseSlots[i][0].runtimeType == int) {
        courseToSlot[courseSlots[i][1].replaceAll(' ', '')] = courseSlots[i][3];
      }
    }

    Map<String, String> slotToDay = {};
    for (int i = 0; i < exams.length; i++) {
      if (exams[i].length != 2) {
        throw ArgumentError("Invalid CSV");
      }
      slotToDay[exams[i][0]] =
          "${dateString(startDate)}|${tod2str(morningSlot_start)}|${tod2str(morningSlot_end)}";
      slotToDay[exams[i][1]] =
          "${dateString(startDate)}|${tod2str(eveningSlot_start)}|${tod2str(eveningSlot_end)}";
      startDate = startDate.add(const Duration(days: 1));
      if (startDate.weekday == 7) {
        startDate = startDate.add(const Duration(days: 1));
      }
    }

    for (int i = 0; i < slotToDay.length; i++) {
      var l = slotToDay[courseToSlot[courses[i]]]!.split('|');
      var e = Event(
          title: 'End-Semester Examinations',
          desc: l[0],
          stime: str2tod(l[2]),
          etime: str2tod(l[3]),
          creator: 'exam');
      EventDB().addSingularEvent(e, stringDate(l[1]));
    }
  }

  static Future<List<ExtraClass>> loadExtraClasses(String course) async {
    return firebaseDatabase.getExtraClass(course);
  }

  static Future<void> saveExtraClasses(String course_id) async {
    List<ExtraClass> extraclasses =
        await firebaseDatabase.getExtraClass(course_id);

    for (ExtraClass c in extraclasses) {
      Event e = Event(
        title: c.courseID,
        desc: c.description,
        stime: c.startTime,
        etime: c.endTime,
        creator: 'course',
      );
      await EventDB().addSingularEvent(e, c.date);
    }
  }
}
