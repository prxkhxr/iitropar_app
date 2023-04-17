import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class changeTimetable extends StatefulWidget {
  const changeTimetable({super.key});

  @override
  State<changeTimetable> createState() => _changeTimetableState();
}

class _changeTimetableState extends State<changeTimetable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Change Time Table"),
        ),
        body: const AddForm());
  }
}

// Create a Form widget.
class AddForm extends StatefulWidget {
  const AddForm({super.key});

  @override
  AddFormState createState() {
    return AddFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddFormState extends State<AddForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  TextEditingController dateinput = TextEditingController();
  String selected_day = "Monday";
  late List<changedDay> chgs;
  bool hasUpdated = false;
  final _formKey = GlobalKey<FormState>();
  AddClassFormState() {
    chgs = [];
    dateinput.text = "";
  }

  Widget dateWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextFormField(
        validator: (value) {
          if (value == "") return "Enter a date";
          DateTime pickedDate = DateFormat('yyyy-MM-dd').parse(value!);
          DateTime currentDate = DateFormat('yyyy-MM-dd')
              .parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
          if (pickedDate.compareTo(currentDate) < 0) {
            return "Previous date event are not allowed";
          }
        },
        controller: dateinput, //editing controller of this TextField
        decoration: InputDecoration(
            icon: Icon(Icons.calendar_today), //icon of text field
            labelText: "Enter Date" //label text of field
            ),
        readOnly: true, //set it true, so that user will not able to edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));
          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              dateinput.text =
                  formattedDate; //set output date to TextField value.
            });
          }
        },
      ),
    );
  }

  Widget dayWidget() {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(child: Text("Monday"), value: "Monday"),
      DropdownMenuItem(child: Text("Tuesday"), value: "Tuesday"),
      DropdownMenuItem(child: Text("Wednesday"), value: "Wednesday"),
      DropdownMenuItem(child: Text("Thrusday"), value: "Thrusday"),
      DropdownMenuItem(child: Text("Friday"), value: "Friday"),
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Time table to be followed of '),
            DropdownButton(
              items: items,
              value: selected_day,
              onChanged: (value) {
                setState(() {
                  selected_day = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> getchgs() async {
    chgs = await firebaseDatabase.getChangedDays();
    return true;
  }

  Widget previous() {
    return Column(
      children: [
        Text('Previously Time table Changes'),
        FutureBuilder<bool>(
            future: getchgs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: chgs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          child: Center(
                              child: Text(
                                  'Date: ${chgs[index].date.toString()},  Desc : ${chgs[index].day_to_followed}')),
                        );
                      }),
                );
              }
            }),
      ],
    );
  }

  Widget submitWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                //TODO: add alert dialog.
                firebaseDatabase.switchTimetableFB(
                    dateinput.text, selected_day);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Added data")));
                setState(() {
                  hasUpdated = true;
                });
              }
            },
            child: Text("Submit")),
      ),
    );
  }

  Widget createForm() {
    return Form(
      key: _formKey,
      child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [dateWidget(), dayWidget(), submitWidget()])),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    return Column(
      children: [createForm(), previous()],
    );
  }
}
