import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';

class NewSemester extends StatefulWidget {
  const NewSemester({super.key});

  @override
  State<NewSemester> createState() => _NewSemesterState();
}

class _NewSemesterState extends State<NewSemester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Color(secondaryLight),
        title: buildTitleBar("NEW SEMESTER", context),
      ),
    );
  }
}