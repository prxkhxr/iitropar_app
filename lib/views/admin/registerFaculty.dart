// ignore_for_file: file_names, camel_case_types, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class registerFaculty extends StatefulWidget {
  const registerFaculty({super.key});

  @override
  State<registerFaculty> createState() => _registerFacultyState();
}

class _registerFacultyState extends State<registerFaculty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Register Faculty"),
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
  late String facultyName;
  late String facultyDep;
  late String facultyEmail;
  AddEventFormState() {
    facultyEmail = "";
    facultyName = "";
    facultyDep = "Computer Science & Engineering";
  }
  Widget _buildFacultyName() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Faculty Name'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Faculty Name is required';
        }
        return null;
      },
      onSaved: (String? value) {
        facultyName = value!;
      },
    );
  }

  Widget _buildFacultyEmail() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Faculty Email'),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Faculty Email is required';
        }
        return null;
      },
      onSaved: (String? value) {
        facultyEmail = value!;
      },
    );
  }

  Widget _buildFacultyDep() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
          child: Text("BioMedical Engineering"),
          value: "BioMedical Engineering"),
      const DropdownMenuItem(
          child: Text("Chemical Engineering"), value: "Chemical Engineering"),
      const DropdownMenuItem(
          child: Text("Civil Engineering"), value: "Civil Engineering"),
      const DropdownMenuItem(
          child: Text("Electrical Engineering"),
          value: "Electrical Engineering"),
      const DropdownMenuItem(
          child: Text("Computer Science & Engineering"),
          value: "Computer Science & Engineering"),
      const DropdownMenuItem(
          child: Text("Metallurgical and Materials Engineering"),
          value: "Metallurgical and Materials Engineering"),
      const DropdownMenuItem(child: Text("Chemistry"), value: "Chemistry"),
      const DropdownMenuItem(child: Text("Physics"), value: "Physics"),
      const DropdownMenuItem(child: Text("Mathematics"), value: "Mathematics"),
      const DropdownMenuItem(
          child: Text("Humanities and Social Sciences"),
          value: "Humanities and Social Sciences"),
    ];
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Department',
            textAlign: TextAlign.left,
          ),
          DropdownButton(
            isExpanded: true,
            items: items,
            value: facultyDep,
            onChanged: (value) {
              setState(() {
                facultyDep = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFacultyName(),
              _buildFacultyDep(),
              _buildFacultyEmail(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      _formKey.currentState!.save();
                      firebaseDatabase.registerFacultyFB(
                          facultyName, facultyDep, facultyEmail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Faculty has been registered!")),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
