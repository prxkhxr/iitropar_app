import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iitropar/database/Event.dart';
import 'package:path/path.dart' as p;

String _dbName = "Events.db";

Future<EventDB> openEventDB() async {
  return Future(() async {
    var inst = EventDB.instance;
    if (inst.init == false) {
      inst._db = await openDatabase(
        p.join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE singular(title TEXT, desc TEXT, date TEXT, stime TEXT, etime TEXT, PRIMARY KEY(title, date, stime, etime)) WITHOUT ROWID;");
          await db.execute(
              "CREATE TABLE recurring(title TEXT, desc TEXT, startDate TEXT, endDate TEXT, stime TEXT, etime TEXT, PRIMARY KEY(title, desc)) WITHOUT ROWID;");
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
    var t = await _db!.rawQuery('SELECT * FROM singular WHERE date = "$d";');
    return Future(() => List.generate(
          t.length,
          (idx) => Event(
            title: t[idx]['title'].toString(),
            stime: t[idx]['stime'].toString(),
            etime: t[idx]['etime'].toString(),
            description: t[idx]['desc'].toString(),
            creator: 'user',
          ),
          growable: true,
        ));
  }

  Future<void> addSingularEvent(SingularEvent se) async {
    await _db!.execute(
        "INSERT INTO singular VALUES (${se.title}, ${se.description}, ${se.date}, ${se.stime}, ${se.etime});");
  }

  Future<void> addRecurringEvent(RecurringEvent re) async {
    await _db!.execute(
        'INSERT INTO recurring VALUES ("${re.title}", "${re.description}", "${re.startDate}", "${re.endDate}, "${re.stime}", "${re.etime}");');
  }

  Future<List<Event>> fetchRecurringEvents(DateTime d) async {
    String date = DateFormat('yyyy-MM-dd').format(d);
    int day = d.weekday;
    var t = await _db!.rawQuery(
        'SELECT * FROM recurring WHERE startDate <= "$date" and endDate >= "$date";');
    return Future(() {
      List<Event> l = List.empty(growable: true);
      for (var row in t) {
        int mask = int.parse(row['mask'].toString());
        if (mask & (1 << day) != 0) {
          l.add(Event(
            title: row['title'].toString(),
            description: row['desc'].toString(),
            creator: 'user',
            stime: row['stime'].toString(),
            etime: row['etime'].toString(),
          ));
        }
      }
      return l;
    });
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
