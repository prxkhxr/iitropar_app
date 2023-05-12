import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/frequently_used.dart';

class FacultyList extends StatefulWidget {
  const FacultyList({Key? key}) : super(key: key);

  @override
  _FacultyListState createState() => _FacultyListState();
}

class _FacultyListState extends State<FacultyList> {
  List<faculty> faculties = [];
  bool hasLoad = false;
  void getFaculties() async {
    faculties = await firebaseDatabase.getFaculty();
    setState(() {
      hasLoad =
          true; // this hasLoad can be used to implemented loaded in future
      for (int i = 0; i < faculties.length; i++) {
        _newCourseController.add(TextEditingController());
      }
    });
  }

  List<TextEditingController> _newCourseController = [];

  _FacultyListState() {
    getFaculties();
  }

  void _addCourse(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
              "Are you sure you want to add course ${_newCourseController[index].text} ?"),
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
                // Close the dialog and call the onPressed function
                setState(() {
                  faculties[index].courses.add(_newCourseController[index]
                      .text
                      .toString()
                      .replaceAll(' ', '')
                      .toUpperCase());
                  _newCourseController[index].clear();
                });
                Navigator.of(context).pop();
                sendDataToFB(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Faculty ${faculties[index].name} 's courses has been updated.")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(String course, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Are you sure you want to delete course $course ?'),
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
                // Close the dialog and call the onPressed function
                setState(() {
                  faculties[index].courses.remove(course);
                });
                Navigator.of(context).pop();
                sendDataToFB(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Faculty ${faculties[index].name} 's courses has been updated.")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void sendDataToFB(int index) {
    //todo
    firebaseDatabase.updateFaculty(faculties[index]);
  }

  Widget submitButton(int index) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Show an alert dialog with a confirmation prompt
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmation'),
                content: const Text('Are you sure you want to submit?'),
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
                      // Close the dialog and call the onPressed function
                      Navigator.of(context).pop();
                      sendDataToFB(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Faculty ${faculties[index].name} 's courses has been updated.")),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text('Update Courses'),
      ),
    );
  }

  String dep_search = "Computer Science & Engineering";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Color(secondaryLight),
          title: buildTitleBar("FACULTY LIST", context),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: DropdownButton(
                      isExpanded: true,
                      items: departments,
                      value: dep_search,
                      onChanged: (value) {
                        setState(() {
                          dep_search = value!;
                        });
                      },
                    )),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color(primaryLight)),
                  ),
                  onPressed: () {
                    // Perform search
                    setState(() {});
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: faculties.length,
                itemBuilder: (BuildContext context, int index) {
                  print(dep_search);
                  if (faculties[index].department != dep_search) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            blurStyle: BlurStyle.outer,
                            blurRadius: 5,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 1),
                      ),
                      child: ListTile(
                        title: Text(
                          faculties[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(faculties[index].department,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(faculties[index].email,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Courses:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: faculties[index]
                                  .courses
                                  .map(
                                    (course) => Chip(
                                      label: Text(course),
                                      deleteIcon: const Icon(Icons.clear),
                                      onDeleted: () {
                                        _deleteCourse(course, index);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newCourseController[index],
                                    decoration: const InputDecoration(
                                        hintText: 'Add course'),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    if (allCourses.contains(
                                        _newCourseController[index]
                                            .text
                                            .toString()
                                            .replaceAll(' ', '')
                                            .toUpperCase())) {
                                      _addCourse(index);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Enter valid course code")));
                                    }
                                  },
                                ),
                              ],
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // submitButton(index)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
}
