import 'package:path/path.dart' as p;

class Event {
  String title;
  String description = '';
  String creator;

  Event({
    required this.title,
    required this.description,
    required this.creator,
  });
}

class SingularEvent extends Event {
  String date;
  String time;
  SingularEvent(
      {required super.title,
      required super.description,
      required super.creator,
      required this.date,
      required this.time});
}

class RecurringEvent extends Event {
  String endDate, startDate;
  RecurringEvent(
      {required super.title,
      required super.creator,
      required super.description,
      required this.startDate,
      required this.endDate});
}
