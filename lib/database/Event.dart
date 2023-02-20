class Event {
  String title;
  String description = '';
  String stime;
  String etime;
  String creator;

  Event({
    required this.title,
    required this.description,
    required this.stime,
    required this.etime,
    required this.creator,
  });
}

class SingularEvent extends Event {
  String date;
  SingularEvent({
    required super.title,
    required super.description,
    required this.date,
    required super.stime,
    required super.etime,
    required super.creator,
  });
}

class RecurringEvent extends Event {
  String endDate, startDate;
  int mask;

  RecurringEvent({
    required super.title,
    required super.description,
    required super.stime,
    required super.etime,
    required this.startDate,
    required this.endDate,
    required this.mask,
    required super.creator,
  });
}
