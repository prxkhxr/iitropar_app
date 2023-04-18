// ignore_for_file: non_constant_identifier_names

import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/event.dart';
import 'package:path/path.dart' as p;
import 'package:iitropar/frequently_used.dart';
import 'package:csv/csv.dart';
import 'package:mutex/mutex.dart';

import 'package:flutter/services.dart' show rootBundle;

String _dbName = "Events.db";

class EventDB {
  static Database? _db;
  static bool _firstRun = false;

  EventDB();

  static int _next = 0;
  static final Mutex _lock = Mutex();

  Future<List<Event>> _fetchSingularEvents(DateTime date) async {
    var t = await _db!.rawQuery(''
        'SELECT e.id as id, e.title as title, e.desc as desc, e.stime as stime, e.etime as etime, e.creator as creator '
        'FROM events as e, event_meta as em '
        'WHERE e.id = em.event_id and em.key = "date" and em.val = "${dateString(date)}"');
    return Future(
        () => List.generate(t.length, (idx) => _convertToEvent(t[idx])));
  }

  Future<List<Event>> _fetchRecurringEvents(DateTime date) async {
    int mask = 1 << (date.weekday - 1);
    String maskstr = _mask2str(mask);

    String datestr = dateString(date);

    var t = await _db!.rawQuery(''
        'SELECT e.id as id, e.title as title, e.desc as desc, e.stime as stime, e.etime as etime, e.creator as creator '
        'FROM events as e, event_meta as em1, event_meta as em2, event_meta as em3 '
        'WHERE e.id = em1.event_id and e.id = em2.event_id and e.id = em3.event_id and '
        ' em1.key = "start_date" and em1.val <= "$datestr" and '
        ' em2.key = "end_date" and em2.val >= "$datestr" and '
        ' em3.key = "mask" and em3.val LIKE "$maskstr" '
        '');

    var lt = List.generate(t.length, (idx) => _convertToEvent(t[idx]));
    var dt = await deletedForDay(lt, date);

    for (int i = 0; i < dt.length; i++) {
      lt.remove(dt[i]);
    }
    return lt;
  }

  Future<void> _addEvent(Event e, int id) async {
    await _db!.rawInsert(
        'INSERT INTO events(id, title, desc, stime, etime, creator) VALUES'
        ' ($id, "${e.title}", "${e.desc}", "${e.startTime()}", "${e.endTime()}", "${e.creator}");');
  }

  Future<void> _addEventMeta(int id, String key, String val) async {
    await _db!.rawInsert(
        'INSERT INTO event_meta(event_id, key, val) VALUES ($id, "$key", "$val")');
  }

  Event _convertToEvent(Map<String, Object?> vals) {
    return Event(
      title: vals['title'].toString(),
      desc: vals['desc'].toString(),
      stime: str2tod(vals['stime'].toString()),
      etime: str2tod(vals['etime'].toString()),
      creator: vals['creator'].toString(),
      id: int.parse(vals['id'].toString()),
    );
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

  String _mask2str(int mask) {
    String str = '';
    for (int i = 0; i < 7; i++) {
      if (mask % 2 == 0) {
        str = '_$str';
      } else {
        str = '1$str';
      }
      mask = mask >> 1;
    }
    return str;
  }

  int _str2mask(String str) {
    int mask = 0;
    for (int i = 0; i < 7; i++) {
      if (str[i].compareTo('0') == 0 || str[i].compareTo('_') == 0) {
        mask = mask << 1;
      } else {
        mask = (mask << 1) + 1;
      }
    }
    return mask;
  }

  static Future<void> startInstance() async {
    _db ??= await openDatabase(
      p.join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, version) async {
        _firstRun = true;
        await db.execute(
            "CREATE TABLE events(id INTEGER PRIMARY KEY, title TEXT, desc TEXT, stime TEXT, etime TEXT, creator TEXT);");
        await db.execute(
            "CREATE TABLE event_meta(event_id INTEGER, key TEXT, val TEXT, FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE, PRIMARY KEY(event_id, key));");

        _lock.acquire();
        _next = 1;
        _lock.release();
      },
      onOpen: (db) async {
        var q = (await db.rawQuery('SELECT MAX(id) as id FROM events;'));

        if (q[0]['id'] == null) return;

        _lock.acquire();
        _next = int.parse(q[0]['id'].toString()) + 1;
        _lock.release();
      },
    );
  }

  Future<void> addSingularEvent(Event se, DateTime day, int id) async {
    await _addEvent(se, id);
    await _addEventMeta(id, "date", dateString(day));
  }

  Future<void> addRecurringEvent(
      Event re, DateTime startDate, DateTime endDate, int id, int mask) async {
    await _addEvent(re, id);
    await _addEventMeta(id, "start_date", dateString(startDate));
    await _addEventMeta(id, "end_date", dateString(endDate));
    await _addEventMeta(id, "mask", _mask2str(mask));
  }

  Future<List<Event>> deletedForDay(List<Event> l, DateTime day) async {
    var t = await _db!.rawQuery(''
        'SELECT e.id as id, e.title as title, e.desc as desc, e.stime as stime, e.etime as etime, e.creator as creator '
        'FROM events as e, event_meta as em '
        'WHERE e.id = em.event_id and em.key = "deleted_for" and em.val = "${dateString(day)}" '
        '');
    var lt = List.generate(t.length, (idx) => _convertToEvent(t[idx]));
    return lt;
  }

  Future<void> deleteForDay(Event e, DateTime date) async {
    if (e.id == null) {
      e = await fillID(e);
    }
    await _addEventMeta(e.id!, "deleted_for", dateString(date));
  }

  Future<void> delete(Event e) async {
    await _db!.rawDelete(''
        'DELETE FROM events as e '
        'WHERE e.title = "${e.title}" and e.desc = "${e.desc}" and e.stime = "${e.startTime()}" and e.etime = "${e.endTime()}" '
        '');
    // await _db!.rawDelete('')
  }

  Future<int> deleteOf(String creator) async {
    var cnt =
        await _db!.rawDelete('DELETE FROM events WHERE creator = "$creator"');
    return cnt;
  }

  Future<List<Event>> fetchEvents(DateTime d, [String? of]) async {
    var se = _fetchSingularEvents(d);
    var re = _fetchRecurringEvents(d);
    List<Event> l1 = await se;
    List<Event> l2 = await re;
    l1.addAll(l2);
    if (of != null) {
      var n = List<Event>.empty(growable: true);
      for (var e in l1) {
        if (e.creator.compareTo(of) == 0) {
          n.add(e);
        }
      }
      l1 = n;
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
              mask = 1 << k;
              break;
            }
          }

          String stime = l[1];
          String etime = l[2];
          Event e = Event(
              title: title,
              desc: title,
              stime: str2tod(stime),
              etime: str2tod(etime),
              creator: 'admin');
          int id = getID();
          await addRecurringEvent(
            e,
            DateTime(2023),
            DateTime(2024),
            id,
            mask,
          );
        }
      }
    }

    return true;
  }

  int getID() {
    _lock.acquire();
    int ans = _next++;
    _lock.release();

    return ans;
  }

  static bool firstRun() {
    return _firstRun;
  }

  Future<Event> fillID(Event e) async {
    var t = await _db!.rawQuery(
        "SELECT e.id FROM events as e WHERE e.title = ${e.title} and e.desc = ${e.desc} and e.stime = ${e.startTime()} and e.etime = ${e.endTime()} and e.creator = ${e.creator}");
    e.id = int.parse(t[0]['id'].toString());
    return e;
  }

  List<int> getConflicts(
      int slotLenght, DateTime date, List<String> entryNumber) {
    // return list containing conflicts in slots starting from 8 am to 8 pm
    List<int> conflicts = [
      1,
      2,
      3,
      4,
      5,
      9,
      0,
      12,
      12,
      12,
      0,
      0
    ]; // example for one hour slot.
    return conflicts;
  }
}
