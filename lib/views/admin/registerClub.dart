// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class registerClub extends StatefulWidget {
  const registerClub({super.key});

  @override
  State<registerClub> createState() => _registerClubState();
}

class _registerClubState extends State<registerClub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          automaticallyImplyLeading: false,
          title: buildTitleBar("REGISTER CLUB", context),
        ),
        body: const AddEventForm());
  }
}

// Create a Form widget.
class AddEventForm extends StatefulWidget {
  const AddEventForm({super.key});

  @override
  AddEventFormState createState() {
    return AddEventFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AddEventFormState extends State<AddEventForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.

  final _formKey = GlobalKey<FormState>();
  late String clubTitle;
  late String clubDesc;
  late String clubEmail;
  AddEventFormState() {
    clubTitle = "initial Title";
    clubDesc = "inital desc";
    clubEmail = "inital emial";
  }
  Widget _buildclubTitle() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Club Title'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Club Title is required';
        }
        return null;
      },
      onSaved: (String? value) {
        clubTitle = value!;
      },
    );
  }

  Widget _buildclubDesc() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Club Description'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Club Description is required';
        }
        return null;
      },
      onSaved: (String? value) {
        clubDesc = value!;
      },
    );
  }

  Widget _buildclubEmail() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Club Email'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Club Email is required';
        } else if (!formChecks.email_check(value)) {
          return 'Enter correct email';
        }
        return null;
      },
      onSaved: (String? value) {
        clubEmail = value!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildclubTitle(),
            _buildclubDesc(),
            _buildclubEmail(),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color(primaryLight)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.

                      _formKey.currentState!.save();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: Text(
                                "Are you sure you want to add club $clubTitle ?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  // Close the dialog and do nothing
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: const Text('Submit'),
                                onPressed: () {
                                  firebaseDatabase.registerClubFB(
                                      clubTitle, clubDesc, clubEmail);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Club has been registered!")),
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
