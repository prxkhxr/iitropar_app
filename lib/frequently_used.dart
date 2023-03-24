import 'package:flutter/material.dart';
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

class LoadingScreen {
  static Future<bool> Function()? _task;
  static String? _msg;
  static Widget Function(BuildContext) _builder =
      (context) => const Placeholder();

  LoadingScreen._privatConstructor();

  static void setPrompt(String message) {
    _msg = message;
  }

  static void setTask(Future<bool> Function() task) {
    _task = task;
  }

  static void setBuilder(Widget Function(BuildContext context) builder) {
    _builder = builder;
  }

  static Widget build(BuildContext context) {
    FutureBuilder(
        future: _task!(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Expanded(
                child: Dialog(
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 15,
                ),
                Text((_msg != null) ? _msg! : 'Loading...'),
              ]),
            ));
          }
          return const Placeholder();
        });
    return _builder(context);
  }
}
