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
    setState(() {
      cur_start_date = sD.startDate!;
      cur_end_date = sD.endDate!;
    });
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
                SizedBox(
                  height: 20,
                ),
                seeSemesterInfo(context),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                updateSemesterDur(context),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                clear_semester(context),
                SizedBox(
                  height: 10,
                ),
              ]),
        ));
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
                  title: Text("Confirm"),
                  content: Text(
                      "Do you really want to clear the semester. This will remove all student courses, faculty courses and classes."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton.icon(
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () {
                          // firebaseDatabase.clearSemesterFB(),
                        }),
                  ],
                );
              });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        child: Text(
          "CLEAR SEMESTER",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget seeSemesterInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Current Semester Duration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'START DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
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
                Text(
                  'END DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
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
          title: Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to have \n'),
              Text('start date  =  ${formatDateWord(_startDate)}'),
              Text('end date  = ${formatDateWord(_endDate)} ?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
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
        Text(
          'Update Semester Duration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
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
        SizedBox(height: 20),
        Text(
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
        SizedBox(height: 20),
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
          child: Text('Update Semester Duration'),
        ),
      ],
    );
  }
}
