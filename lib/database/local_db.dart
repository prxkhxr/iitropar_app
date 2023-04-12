// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/event.dart';
import 'package:path/path.dart' as p;
import 'package:iitropar/frequently_used.dart';
import 'package:csv/csv.dart';
import 'package:iitropar/frequently_used.dart';

import 'package:flutter/services.dart' show rootBundle;

String _dbName = "Events.db";

class EventDB {
  static Database? _db;
  static bool _firstRun = false;

  EventDB();

  static Future<void> startInstance() async {
    _db ??= await openDatabase(
      p.join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, version) async {
        _firstRun = true;
        await db.execute(
            "CREATE TABLE events(title TEXT, desc TEXT, stime TEXT, etime TEXT, startDate TEXT, endDate TEXT, mask TEXT, creator INTEGER, type INTEGER, PRIMARY KEY(title, desc, stime, etime, startDate)) WITHOUT ROWID;");
      },
    );
  }

  static Future<bool> firstRun() async {
    return _firstRun;
  }

  Future<List<Event>> _fetchSingularEvents(DateTime date) async {
    String d = DateFormat('yyyy-MM-dd').format(date);
    var t = await _db!
        .rawQuery('SELECT * FROM events WHERE startDate = "$d" and type = 0;');
    return Future(
        () => List.generate(t.length, (idx) => _convertToEvent(t[idx])));
  }

  Future<List<Event>> _fetchRecurringEvents(DateTime date) async {
    String d = dateString(date);
    int day = date.weekday;
    var t = await _db!.rawQuery(
        'SELECT * FROM events WHERE startDate <= "$d" and endDate >= "$d" and type = 1;');
    return Future(() {
      List<Event> l = List.empty(growable: true);
      for (var row in t) {
        int mask = int.parse(row['mask'].toString());
        if (mask & (1 << day) != 0) {
          l.add(_convertToEvent(row));
        }
      }
      return l;
    });
  }

  Future<int> _addSingularEvent(Event se) async {
    return await _db!.rawInsert(
        'INSERT INTO events(title, desc, stime, etime, startDate, creator, type) VALUES ("${se.title}", "${se.description}", "${(se.startTime())}", "${(se.endTime())}", "${dateString(se.displayDate)}", "${se.creator}", 0);');
  }

  Future<int> _addRecurringEvent(Event re) async {
    var vals = await _db!.rawQuery(
        'SELECT * FROM events WHERE title = "${re.title}" and desc = "${re.description}" and stime = "${(re.startTime())}" and etime = "${(re.endTime())}";');

    if (vals.isEmpty) {
      return await _db!.rawInsert(
          'INSERT INTO events(title, desc, stime, etime, startDate, endDate, mask, creator, type) VALUES ("${re.title}", "${re.description}", "${(re.startTime())}", "${(re.endTime())}", "${dateString(re.startDate!)}", "${dateString(re.endDate!)}", ${re.mask}, "${re.creator}", 1);');
    } else {
      int mask = (int.parse(vals[0]['mask'].toString()) | re.mask!);
      return _db!.rawUpdate(
          'UPDATE events SET mask = $mask WHERE title = "${re.title}" and desc = "${re.description}" and stime = "${(re.startTime())}" and etime = "${(re.endTime())}";');
    }
  }

  Event _convertToEvent(Map<String, Object?> vals) {
    if (int.parse(vals['type'].toString()) == 0) {
      return Event.singular(
          title: vals['title'].toString(),
          description: vals['desc'].toString(),
          stime: str2tod(vals['stime'].toString()),
          etime: str2tod(vals['etime'].toString()),
          displayDate: stringDate(vals['startDate'].toString()),
          creator: vals['creator'].toString());
    } else {
      return Event.recurring(
          title: vals['title'].toString(),
          description: vals['desc'].toString(),
          startDate: stringDate(vals['startDate'].toString()),
          endDate: stringDate(vals['endDate'].toString()),
          mask: int.parse(vals['mask'].toString()),
          stime: str2tod(vals['stime'].toString()),
          etime: str2tod(vals['etime'].toString()),
          displayDate: DateTime.now(),
          creator: vals['creator'].toString());
    }
  }

  String _convertTo24(String time, String segment) {
    int hour = int.parse(time.split('.')[0]);
    int min = int.parse(time.split('.')[1]);
    if (segment.toLowerCase().compareTo('am') != 0) {
      if (hour != 12) hour += 12;
    } else if (hour == 12) {
      hour = 0;
    }
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}';
  }

  Future<int> delete(Event e) async {
    var cnt = await _db!.rawDelete(
        'DELETE FROM events WHERE title = "${e.title}" and desc = "${e.description}" and stime = "${e.startTime()}" and etime = "${e.endTime()}";');
    return cnt;
  }

  Future<int> deleteOf(String creator) async {
    var cnt =
        await _db!.rawDelete('DELETE FROM events WHERE creator = "$creator"');
    return cnt;
  }

  Future<bool> insert(Event e) async {
    var cnt = 0;
    if (e.isRecurring()) {
      cnt = await _addRecurringEvent(e);
    } else {
      cnt = await _addSingularEvent(e);
    }
    return !(cnt == 0);
  }

  Future<List<Event>> fetchEvents(DateTime d, [String? of]) async {
    var se = _fetchSingularEvents(d);
    var re = _fetchRecurringEvents(d);
    List<Event> l1 = await se;
    List<Event> l2 = await re;
    l1.addAll(l2);
    if (of != null) {
      for (var e in l1) {
        if (e.creator.compareTo(of) != 0) {
          l1.remove(e);
        }
      }
    }
    return l1;
  }

  Future<List<Event>> fetchOf(String creator) async {
    var events =
        await _db!.rawQuery('SELECT * FROM events WHERE creator = "$creator";');
    return List.from(events.map((e) => _convertToEvent(e)));
  }

  Future<bool> loadCourse(List<String> course_id) async {
    //  Preprocess
    for (int i = 0; i < course_id.length; i++) {
      course_id[i] = course_id[i].replaceAll(' ', '');
    }

    //  Load Slots of each Course
    var courseSlots = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/CourseSlots.csv'));
    int len = courseSlots.length;
    Map<String, String> courseToSlot = {};
    for (int i = 0; i < len; i++) {
      if (courseSlots[i][0].runtimeType == int) {
        courseToSlot[courseSlots[i][1].replaceAll(' ', '')] = courseSlots[i][3];
      }
    }

    var slotTimes = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/TimeTable.csv'));
    len = slotTimes.length;
    Map<String, List<String>> slotToTime = {};

    // Process Times
    List<String> timings = slotTimes[0].cast<String>();
    for (int i = 1; i < timings.length; i++) {
      List<String> tokens = timings[i].split(' ');
      if (tokens.length != 4) continue;
      timings[i] =
          '${_convertTo24(tokens[0], tokens[3])} ${_convertTo24(tokens[2], tokens[3])}';
    }

    //  Load time corresponding to slots
    for (int i = 1; i < len; i++) {
      int sz = slotTimes[i].length;
      String weekday = slotTimes[i][0];

      for (int j = 1; j < sz; j++) {
        String slot = slotTimes[i][j].replaceAll(' ', '');
        if (slotToTime[slot] == null) {
          slotToTime[slot] = List.empty(growable: true);
        }
        //  Add time to corresponding slot
        slotToTime[slot]!.add(
            '${weekday.toLowerCase()} ${timings[j].toLowerCase()}'); // monday 8 - 8.50 AM
      }
    }

    for (int i = 0; i < course_id.length; i++) {
      for (int j = 0; j < 2; j++) {
        String? slot = courseToSlot[course_id[i]];
        //  Processes as Tutorial or Class
        slot = (j == 0) ? (slot) : ('T-$slot');
        String title =
            (j == 0) ? ('${course_id[i]} Class') : '${course_id[i]} Tutorial';

        List<String>? times = slotToTime[slot];
        if (times == null) continue;

        for (int j = 0; j < times.length; j++) {
          var l = times[j].split(' ');
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
              mask = 1 << (k + 1);
              break;
            }
          }

          String stime = l[1];
          String etime = l[2];
          Event e = Event.recurring(
              title: title,
              description: title,
              stime: str2tod(stime),
              etime: str2tod(etime),
              startDate: DateTime(2023),
              endDate: DateTime(2024),
              displayDate: DateTime.now(),
              mask: mask,
              creator: 'admin');
          await insert(e);
        }
      }
    }

    return true;
  }
}
