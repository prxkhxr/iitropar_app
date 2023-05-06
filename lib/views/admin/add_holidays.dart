import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class addHoliday extends StatefulWidget {
  const addHoliday({super.key});

  @override
  State<addHoliday> createState() => _addHolidayState();
}

class _addHolidayState extends State<addHoliday> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("ADD HOLIDAY", context),
        ),
        body: const AddClassForm());
  }
}

// Create a Form widget.
class AddClassForm extends StatefulWidget {
  const AddClassForm({super.key});

  @override
  AddClassFormState createState() {
    return AddClassFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddClassFormState extends State<AddClassForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  TextEditingController dateinput = TextEditingController();
  TextEditingController descinput = TextEditingController();
  late List<holidays> hols;
  final _formKey = GlobalKey<FormState>();
  AddClassFormState() {
    hols = [];
    dateinput.text = "";
    descinput.text = "";
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
        decoration: const InputDecoration(
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

  Widget descWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: TextFormField(
          controller: descinput,
          decoration: InputDecoration(
              icon: Icon(Icons.description), labelText: "Enter reason "),
        ));
  }

  Future<bool> getHols() async {
    hols = await firebaseDatabase.getHolidayFB();
    return true;
  }

  Widget submitWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                //TODO: add alert dialog.
                firebaseDatabase.addHolidayFB(dateinput.text, descinput.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Holiday Declared on ${dateinput.text}")));
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
          margin: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            dateWidget(),
            const SizedBox(height: 10),
            descWidget(),
            const SizedBox(height: 20),
            submitWidget()
          ])),
    );
  }

  Widget alldeclaredHolidays() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previously Declared Holidays',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<bool>(
              future: getHols(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: hols.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title:
                                Text(dateString(hols[index].date), style: const TextStyle(fontSize: 20),),
                            subtitle: Text(hols[index].desc, style: const TextStyle(fontSize: 18),),
                          );
                        }),
                  );
                }
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    return Column(
      children: [
        createForm(),
        alldeclaredHolidays(),
      ],
    );
  }
}
