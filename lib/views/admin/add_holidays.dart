import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
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
          decoration: const InputDecoration(
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
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Color(primaryLight)),
          ),
          onPressed: () {
            if (descinput.text == "") {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Add reason for holiday")));
              return;
            }
            // Show the confirmation dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: Text(
                      "Do you really want to add holiday on ${formatDateWord(stringDate(dateinput.text))}?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Add"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          //TODO: add alert dialog.
                          firebaseDatabase.addHolidayFB(
                              dateinput.text, descinput.text);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Holiday Declared on ${dateinput.text}")));
                          setState(() {});
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Submit"),
        ),
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
        children: [
          const Text('Upcoming Holidays',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          DateTime currentDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                          DateTime d = DateTime(hols[index].date.year,
                              hols[index].date.month, hols[index].date.day);
                          if (currentDate.compareTo(d) <= 0) {
                            double width = MediaQuery.of(context).size.width;
                            return Column(
                              children: [
                                SizedBox(
                                  height: 80,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 4 / 5.5 * width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Date: ${formatDateWord(hols[index].date)}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Reason : ${hols[index].desc}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Show the confirmation dialog
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content: Text(
                                                    "Do you really want to delete holiday on ${formatDateWord(hols[index].date)} ?"),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text("Cancel"),
                                                    onPressed: () {
                                                      // Close the dialog
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton.icon(
                                                      icon: const Icon(
                                                          Icons.delete),
                                                      label:
                                                          const Text("Delete"),
                                                      onPressed: () {
                                                        firebaseDatabase
                                                            .deleteHol(DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(
                                                                    hols[index]
                                                                        .date));
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        "Deleted holiday day")));
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {});
                                                      }),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.delete),
                                        color: Color(primaryLight)
                                            .withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 2,
                                  thickness: 1,
                                  color: Color(primaryLight).withOpacity(0.05),
                                ),
                              ],
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

  bool verifyHeader(List<dynamic> csv_head) {
    if (csv_head.isEmpty) {
      return false;
    }
    if (csv_head[0].toString().toLowerCase().trim() == "date" &&
        csv_head[1].toString().toLowerCase().trim() == "reason") {
      return true;
    }
    return false;
  }

  void _pickFile(ScaffoldMessengerState sm) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    String filePath = result.files.first.path!;
    RegExp date_regex = RegExp(r'^[0-9]{4}/[0-3]?[0-9]/[0-1]?[0-9]$');

    final input = File(filePath).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    if (!verifyHeader(fields[0])) {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv incorrect!")));
      return;
    } else {
      sm.showSnackBar(
          const SnackBar(content: Text("Header format in csv correct!")));
    }

    for (int i = 1; i < fields.length; i++) {
      bool date_check = true;
      if (fields[i][1] == "") {
        sm.showSnackBar(
            const SnackBar(content: Text("Reason can not be empty.")));
        continue;
      }
      if (date_regex.hasMatch(fields[i][0])) {
        List<String> date_split = fields[i][0].toString().split('/');
        int day = int.parse(date_split[2]);
        int month = int.parse(date_split[1]);
        int year = int.parse(date_split[0]);
        if (day < 0 || day > 31) date_check = false;
        if (month < 0 || month > 12) date_check = false;
        if (formChecks.beforeCurDate(DateTime(year, month, day))) {
          sm.showSnackBar(const SnackBar(
              content:
                  Text("Can not added holiday of days before current day.")));
          continue;
        }
        DateTime dt = DateTime(year, month, day);
        if (date_check) {
          firebaseDatabase.addHolidayFB(
              DateFormat('yyyy-MM-dd').format(dt).trim(),
              fields[i][1].toString().trim());
          continue;
        }
      }
      sm.showSnackBar(SnackBar(
          content:
              Text("String ${fields[i][0]} is not in the yyyy/mm/dd format.")));
    }
    setState(() {});
  }

  Widget csvOption(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Show an alert dialog with a confirmation prompt
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Given CSV format'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset('assets/holidays.png'),
                          ),
                          const Text(
                              '1.Date should be of the format -  yyyy/mm/dd. Ex: 2020/12/12'),
                          const Text('2.Reason should not be empty'),
                          const Text(
                              '3. Holidays of previous date are not allowed')
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Center(
                        child: ElevatedButton(
                          child: const Text('Upload File'),
                          onPressed: () {
                            // Close the dialog and call the onPressed function
                            _pickFile(ScaffoldMessenger.of(context));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            // Close the dialog and do nothing
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Upload via CSV'),
          ),
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
        csvOption(context),
        const SizedBox(height: 5),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Color(primaryLight)),
          ),
          child: const Text("Download Sample"),
          onPressed: () async {
            final result = await FilePicker.platform.getDirectoryPath();
            if (result == null) {
              return;
            }
            File nfile = File(p.join(result, 'holidaySample.csv'));
            nfile.writeAsString(
                await rootBundle.loadString('assets/holidaySample.csv'));
          },
        ),
        alldeclaredHolidays(),
      ],
    );
  }
}
