import 'package:intl/intl.dart';

String dateString(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(d);
}

DateTime stringDate(String d) {
  int year = int.parse(d.substring(0, 4));
  int month = int.parse(d.substring(5, 7));
  int day = int.parse(d.substring(8, 10));
  return DateTime(year, month, day);
}
