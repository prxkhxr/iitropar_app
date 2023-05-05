// ignore_for_file: non_constant_identifier_names

import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/event.dart';
import 'package:path/path.dart' as p;
import 'package:iitropar/frequently_used.dart';
import 'package:mutex/mutex.dart';

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
        'FROM events e, event_meta em '
        'WHERE e.id = em.event_id and em.key = "date" and em.val = "${dateString(date)}"');
    return Future(
        () => List.generate(t.length, (idx) => _convertToEvent(t[idx])));
  }

  Future<List<Event>> _fetchRecurringEvents(DateTime date) async {
    String datestr = dateString(date);

    var t = await _db!.rawQuery(''
        'SELECT e.id as id, e.title as title, e.desc as desc, e.stime as stime, e.etime as etime, e.creator as creator '
        'FROM events e, event_meta em1, event_meta em2, event_meta em3 '
        'WHERE e.id = em1.event_id and e.id = em2.event_id and e.id = em3.event_id and '
        ' em1.key = "start_date" and em1.val <= "$datestr" and '
        ' em2.key = "end_date" and em2.val >= "$datestr" and '
        ' em3.key = "recur_on" and em3.val = "${date.weekday}" '
        '');

    var lt = List.generate(t.length, (idx) => _convertToEvent(t[idx]));
    var dt = await deletedForDay(lt, date);

    for (int i = 0; i < dt.length; i++) {
      lt.remove(dt[i]);
    }
    return lt;
  }

  Future<int> _addEvent(Event e) async {
    var l = await _db!.rawQuery(
        'SELECT * FROM events WHERE title = "${e.title}" and desc = "${e.desc}" and stime = "${e.startTime()}" and etime = "${e.endTime()}" and creator = "${e.creator}"');
    if (l.isNotEmpty) {
      return int.parse(l[0]['id'].toString());
    }

    var id = _getID();
    await _db!.rawInsert(
        'INSERT INTO events(id, title, desc, stime, etime, creator) VALUES'
        ' ($id, "${e.title}", "${e.desc}", "${e.startTime()}", "${e.endTime()}", "${e.creator}");');
    return id;
  }

  Future<void> _addEventMeta(int id, String key, String val) async {
    await _db!.rawInsert(
        'INSERT OR IGNORE INTO event_meta(event_id, key, val) VALUES ($id, "$key", "$val")');
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

  void printAll() async {
    var e = await _db!.rawQuery('SELECT * FROM events');
    var em = await _db!.rawQuery('SELECT * FROM event_meta');
    print(e);
    print(em);
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
            "CREATE TABLE event_meta(event_id INTEGER, key TEXT, val TEXT, FOREIGN KEY(event_id) REFERENCES events(id), PRIMARY KEY(event_id, key, val)) WITHOUT ROWID;");

        _lock.acquire();
        _next = 1;
        _lock.release();
      },
      onOpen: (db) async {
        var q = (await db.rawQuery('SELECT MAX(id) as id FROM events;'));

        if (q[0]['id'] == null) {
          _lock.acquire();
          _next = 1;
          _lock.release();
          return;
        }

        _lock.acquire();
        _next = int.parse(q[0]['id'].toString()) + 1;
        _lock.release();
      },
    );
  }

  Future<void> addSingularEvent(Event se, DateTime day) async {
    var id = await _addEvent(se);
    await _addEventMeta(id, "date", dateString(day));
  }

  Future<void> addRecurringEvent(
      Event re, DateTime startDate, DateTime endDate, int mask) async {
    var id = await _addEvent(re);
    await _addEventMeta(id, "start_date", dateString(startDate));
    await _addEventMeta(id, "end_date", dateString(endDate));
    for (int i = 0; i < 7; i++) {
      if (mask % 2 == 1) await _addEventMeta(id, "recur_on", "${i + 1}");
      mask = (mask >> 1);
    }
  }

  Future<List<Event>> deletedForDay(List<Event> l, DateTime day) async {
    var t = await _db!.rawQuery(''
        'SELECT e.id as id, e.title as title, e.desc as desc, e.stime as stime, e.etime as etime, e.creator as creator '
        'FROM events e, event_meta em '
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
    e = await fillID(e);
    await _db!.rawDelete(''
        'DELETE FROM events '
        'WHERE id = ${e.id} '
        '');
    await _db!.rawDelete(''
        'DELETE FROM event_meta '
        'WHERE event_id = ${e.id} '
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

  int _getID() {
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
        'SELECT e.id FROM events e WHERE e.title = "${e.title}" and e.desc = "${e.desc}" and e.stime = "${e.startTime()}" and e.etime = "${e.endTime()}" and e.creator = "${e.creator}"');
    e.id = int.parse(t[0]['id'].toString());
    return e;
  }
}
