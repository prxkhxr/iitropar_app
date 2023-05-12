// ignore_for_file: camel_case_types, non_constant_identifier_names, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
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
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("CHANGE TIME-TABLE", context),
        ),
        body: const AddForm());
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
          return null;
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

  Widget dayWidget() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(child: Text("Monday"), value: "Monday"),
      const DropdownMenuItem(child: Text("Tuesday"), value: "Tuesday"),
      const DropdownMenuItem(child: Text("Wednesday"), value: "Wednesday"),
      const DropdownMenuItem(child: Text("Thursday"), value: "Thursday"),
      const DropdownMenuItem(child: Text("Friday"), value: "Friday"),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'Schedule to be followed of ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
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
    );
  }

  Future<bool> getchgs() async {
    chgs = await firebaseDatabase.getChangedDays();
    return true;
  }

  Widget previous() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Time table Changes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          DateTime currentDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                          DateTime d = DateTime(chgs[index].date.year,
                              chgs[index].date.month, chgs[index].date.day);
                          print(d.toString());
                          if (d.compareTo(currentDate) >= 0) {
                            return Container(
                              height: 100,
                              child: Center(
                                  child: Column(
                                children: [
                                  Text(
                                      'Date: ${formatDateWord(chgs[index].date)},  Day followed : ${chgs[index].day_to_followed}'),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Show the confirmation dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Confirm"),
                                            content: Text(
                                                "Do you really want to not follow ${chgs[index].day_to_followed}'s time table on ${formatDateWord(chgs[index].date)}"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                  // Close the dialog
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton.icon(
                                                  icon: Icon(Icons.delete),
                                                  label: Text("Delete"),
                                                  onPressed: () {
                                                    firebaseDatabase
                                                        .deleteChDay(DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(chgs[index]
                                                                .date));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    "Deleted switched day")));
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  }),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                    label: Text("Delete"),
                                  ),
                                ],
                              )),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget submitWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Color(primaryLight)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                //TODO: add alert dialog.
                firebaseDatabase.switchTimetableFB(
                    dateinput.text, selected_day);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Added data")));
                setState(() {
                  hasUpdated = true;
                });
              }
            },
            child: const Text("Submit")),
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
            const SizedBox(
              height: 10,
            ),
            dayWidget(),
            const SizedBox(
              height: 10,
            ),
            submitWidget()
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    return Column(
      children: [
        createForm(),
        const SizedBox(
          height: 20,
        ),
        previous()
      ],
    );
  }
}
