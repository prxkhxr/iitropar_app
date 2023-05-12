// ignore_for_file: non_constant_identifier_names

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';

class NewSemester extends StatefulWidget {
  const NewSemester({super.key});

  @override
  State<NewSemester> createState() => _NewSemesterState();
}

class _NewSemesterState extends State<NewSemester> {
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();
  late DateTime cur_start_date = DateTime.now();
  late DateTime cur_end_date = DateTime.now();

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void initDate() async {
    semesterDur sD = await firebaseDatabase.getSemDur();
    if (mounted) {
      setState(() {
        cur_start_date = sD.startDate!;
        cur_end_date = sD.endDate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initDate();
    // List<d
    return Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          title: buildTitleBar("Semester Details", context),
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 20,
                ),
                seeSemesterInfo(context),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                updateSemesterDur(context),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                clear_semester(context),
                const SizedBox(
                  height: 10,
                ),
              ]),
        ));
  }

  Widget themeButtonWidget() {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(
      Icons.arrow_back,
    ),
    color: Color(primaryLight),
    iconSize: 28,
  );
}

TextStyle appbarTitleStyle() {
  return TextStyle(
      color: Color(primaryLight),
      // fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5);
}

Row buildTitleBar(String text, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      themeButtonWidget(),
      Flexible(
        child: SizedBox(
          height: 30,
          child: FittedBox(
            child: Text(
              text,
              style: appbarTitleStyle(),
            ),
          ),
        ),
      ),
      signoutButtonWidget(context),
    ],
  );
}

  Widget clear_semester(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Add your button click logic here
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text(
                      "Do you really want to clear the semester. This will remove all student courses, faculty courses and classes."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () async {
                          firebaseDatabase.clearSemester();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "all courses and classes are removed")));
                        }),
                  ],
                );
              });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        child: const Text(
          "CLEAR SEMESTER",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget seeSemesterInfo(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Current Semester Duration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  'START DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatDateWord(cur_start_date),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'END DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatDateWord(cur_end_date),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _updateSemesterDuration(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to have \n'),
              Text('start date  =  ${formatDateWord(_startDate)}'),
              Text('end date  = ${formatDateWord(_endDate)} ?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                // Perform the update operation here
                firebaseDatabase.addSemDur(_startDate, _endDate);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Semester dates updated succesfully.")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget updateSemesterDur(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Update Semester Duration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'START DATE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _selectStartDate(context),
                child: Text(
                  formatDateWord(_startDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'END DATE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _selectEndDate(context),
                child: Text(
                  formatDateWord(_endDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (!formChecks.isbeforeDate(_startDate, _endDate)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Start date can not be before End date.")),
              );
              return;
            }
            _updateSemesterDuration(context);
          },
          child: const Text('Update Semester Duration'),
        ),
      ],
    );
  }
}
