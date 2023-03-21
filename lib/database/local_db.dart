import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/event.dart';
import 'package:path/path.dart' as p;
import 'package:iitropar/frequently_used.dart';

String _dbName = "Events.db";

Future<EventDB> openEventDB() async {
  return Future(() async {
    var inst = EventDB.instance;
    if (inst.init == false) {
      inst._db = await openDatabase(
        p.join(await getDatabasesPath(), _dbName),
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE events(title TEXT, desc TEXT, stime TEXT, etime TEXT, startDate TEXT, endDate TEXT, mask TEXT, type INTEGER, PRIMARY KEY(title, desc, stime, etime, startDate)) WITHOUT ROWID;");
        },
      );
      inst.init = true;
    }
    return inst;
  });
}

class EventDB {
  Database? _db;
  bool init = false;
  int cnt = 0;

  EventDB._privateconstructor();
  static final instance = EventDB._privateconstructor();

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
        'INSERT INTO events(title, desc, stime, etime, startDate, type) VALUES ("${se.title}", "${se.description}", "${se.stime}", "${se.etime}", "${se.displayDate}", 0);');
  }

  Future<int> _addRecurringEvent(Event re) async {
    return await _db!.rawInsert(
        'INSERT INTO events(title, desc, stime, etime, startDate, endDate, mask, type) VALUES ("${re.title}", "${re.description}", "${re.stime}", "${re.etime}", "${re.startDate}", "${re.endDate}", ${re.mask}, 1);');
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

  Future<bool> delete(Event e) async {
    var cnt = await _db!.rawDelete(
        'DELETE FROM events WHERE title = "${e.title}" and desc = "${e.description}" and stime = "${e.stime}" and etime = "${e.etime}";');
    return !(cnt == 0);
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
}
