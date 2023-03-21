import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
          title: const Text("Register Club"),
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
      decoration: InputDecoration(labelText: 'Club Title'),
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
      decoration: InputDecoration(labelText: 'Club Description'),
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
      decoration: InputDecoration(labelText: 'Club Email'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Club Email is required';
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
        margin: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildclubTitle(),
            _buildclubDesc(),
            _buildclubEmail(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    _formKey.currentState!.save();
                    firebaseDatabase.registerClubFB(
                        clubTitle, clubDesc, clubEmail);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Club has been registered!")),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
