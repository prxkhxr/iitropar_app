// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/event.dart';
import 'package:path/path.dart' as p;
import 'package:iitropar/frequently_used.dart';
import 'package:csv/csv.dart';

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

  Future<List<Event>> fetchSingularEvents(DateTime date) async {
    String d = DateFormat('yyyy-MM-dd').format(date);
    var t = await _db!
        .rawQuery('SELECT * FROM events WHERE startDate = "$d" and type = 0;');
    return Future(() => List.generate(
          t.length,
          (idx) => Event.singular(
            title: t[idx]['title'].toString(),
            description: t[idx]['desc'].toString(),
            stime: t[idx]['stime'].toString(),
            etime: t[idx]['etime'].toString(),
            displayDate: t[idx]['startDate'].toString(),
            creator: 'user',
          ),
          growable: true,
        ));
  }

  Future<int> _addSingularEvent(Event se) async {
    return await _db!.rawInsert(
        'INSERT INTO events(title, desc, stime, etime, startDate, creator, type) VALUES ("${se.title}", "${se.description}", "${se.stime}", "${se.etime}", "${se.displayDate}", "${se.creator}", 0);');
  }

  Future<int> _addRecurringEvent(Event re) async {
    var vals = await _db!.rawQuery(
        'SELECT * FROM events WHERE title = "${re.title}" and desc = "${re.description}" and stime = "${re.stime}" and etime = "${re.etime}";');

    if (vals.isEmpty) {
      return await _db!.rawInsert(
          'INSERT INTO events(title, desc, stime, etime, startDate, endDate, mask, creator, type) VALUES ("${re.title}", "${re.description}", "${re.stime}", "${re.etime}", "${re.startDate}", "${re.endDate}", ${re.mask}, "${re.creator}", 1);');
    } else {
      int mask = (int.parse(vals[0]['mask'].toString()) | re.mask!);
      return _db!.rawUpdate(
          'UPDATE events SET mask = $mask WHERE title = "${re.title}" and desc = "${re.description}" and stime = "${re.stime}" and etime = "${re.etime}";');
    }
  }

  Future<List<Event>> fetchRecurringEvents(DateTime d) async {
    String date = DateFormat('yyyy-MM-dd').format(d);
    int day = d.weekday;
    var t = await _db!.rawQuery(
        'SELECT * FROM events WHERE startDate <= "$date" and endDate >= "$date" and type = 1;');
    return Future(() {
      List<Event> l = List.empty(growable: true);
      for (var row in t) {
        int mask = int.parse(row['mask'].toString());
        if (mask & (1 << day) != 0) {
          l.add(Event.recurring(
            title: row['title'].toString(),
            description: row['desc'].toString(),
            stime: row['stime'].toString(),
            etime: row['etime'].toString(),
            startDate: row['startDate'].toString(),
            endDate: row['endDate'].toString(),
            displayDate: dateString(d),
            mask: mask,
            creator: 'user',
          ));
        }
      }
      return l;
    });
  }

  Future<int> delete(Event e) async {
    var cnt = await _db!.rawDelete(
        'DELETE FROM events WHERE title = "${e.title}" and desc = "${e.description}" and stime = "${e.stime}" and etime = "${e.etime}";');
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

  Future<List<Event>> fetchEvents(DateTime d) async {
    var se = fetchSingularEvents(d);
    var re = fetchRecurringEvents(d);
    List<Event> l1 = await se;
    List<Event> l2 = await re;
    return Future(() {
      l1.addAll(l2);
      return l1;
    });
  }

  Event _convertToEvent(Map<String, Object?> vals) {
    if (int.parse(vals['type'].toString()) == 0) {
      return Event.singular(
          title: vals['title'].toString(),
          description: vals['desc'].toString(),
          stime: vals['stime'].toString(),
          etime: vals['etime'].toString(),
          displayDate: vals['startDate'].toString(),
          creator: vals['creator'].toString());
    } else {
      return Event.recurring(
          title: vals['title'].toString(),
          description: vals['desc'].toString(),
          startDate: vals['startDate'].toString(),
          endDate: vals['endDate'].toString(),
          mask: int.parse(vals['mask'].toString()),
          stime: vals['stime'].toString(),
          etime: vals['etime'].toString(),
          displayDate: dateString(DateTime.now()),
          creator: vals['creator'].toString());
    }
  }

  Future<List<Event>> fetchOf(String creator) async {
    var events =
        await _db!.rawQuery('SELECT * FROM events WHERE creator = "$creator";');
    return List.from(events.map((e) => _convertToEvent(e)));
  }

  Future<bool> loadCourse(List<String> course_id) async {
    var courseSlots = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/CourseSlots.csv'));

    int len = courseSlots.length;
    Map<String, String> courseToSlot = {};
    for (int i = 0; i < len; i++) {
      print(courseSlots[i][0].runtimeType);
      if (courseSlots[i][0].runtimeType == int) {
        courseToSlot[courseSlots[i][1].replaceAll(' ', '')] = courseSlots[i][3];
      }
    }

    var slotTimes = const CsvToListConverter()
        .convert(await rootBundle.loadString('assets/TimeTable.csv'));

    len = slotTimes.length;
    Map<String, List<String>> slotToTime = {};
    List<String> timings = slotTimes[0].cast<String>();
    for (int i = 1; i < len; i++) {
      int sz = slotTimes[i].length;
      String weekday = slotTimes[i][0];
      for (int j = 1; j < sz; j++) {
        String slot = slotTimes[i][j].replaceAll(' ', '');
        if (slotToTime[slot] == null) {
          slotToTime[slot] = List.empty(growable: true);
        }
        slotToTime[slot]!.add('$weekday ${timings[j]}');
      }
    }

    for (int i = 0; i < course_id.length; i++) {
      for (int j = 0; j < 2; j++) {
        String? slot = courseToSlot[course_id[i].replaceAll(' ', '')];
        slot = (j == 0) ? (slot) : ('T-$slot');
        List<String>? times = slotToTime[slot];
        if (times == null) continue;
        for (int j = 0; j < times.length; j++) {
          String title = (slot!.substring(0, 2).compareTo('T-') == 0)
              ? ('${course_id[i]} Tutorial')
              : ('${course_id[i]} Class');
          String time = times[j];
          var l = time.split(' ');
          String day = l[0].toLowerCase();
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
          String stime = '${l[1]} ${l[4]}';
          String etime = '${l[3]} ${l[4]}';
          Event e = Event.recurring(
              title: title,
              description: title,
              stime: stime,
              etime: etime,
              startDate: dateString(DateTime(2023)),
              endDate: dateString(DateTime(2024)),
              displayDate: '',
              mask: mask,
              creator: 'admin');
          await insert(e);
        }
      }
    }

    return true;
  }
}
