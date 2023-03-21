class Event {
  String title;
  String description = '';
  bool _recurring = false;
  String stime;
  String etime;
  String displayDate;
  String? startDate;
  String? endDate;
  int? mask;
  String creator;

  Event.singular({
    required this.title,
    required this.description,
    required this.stime,
    required this.etime,
    required this.displayDate,
    required this.creator,
  });

  Event.recurring({
    required this.title,
    required this.description,
    required this.stime,
    required this.etime,
    required this.startDate,
    required this.endDate,
    required this.displayDate,
    required this.mask,
    required this.creator,
  }) {
    _recurring = true;
  }

  bool isRecurring() {
    return _recurring;
  }
}
