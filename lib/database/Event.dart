import 'package:path/path.dart' as p;

class Event {
  String title;
  String description = '';
  String time;
  String creator;

  Event({
    required this.title,
    required this.description,
    required this.creator,
    required this.time,
  });
}

class SingularEvent extends Event {
  String date;
  SingularEvent(
      {required super.title,
      required super.description,
      required super.creator,
      required this.date,
      required super.time});
}

class RecurringEvent extends Event {
  String endDate, startDate;
  int mask;

  RecurringEvent(
      {required super.time,
      required super.title,
      required super.creator,
      required super.description,
      required this.startDate,
      required this.endDate,
      required this.mask});
}
