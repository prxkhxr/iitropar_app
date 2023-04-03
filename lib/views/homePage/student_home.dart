import 'package:flutter/material.dart';
import 'package:iitropar/views/homePage/home_page.dart';

class StudentHome extends AbstractHome {
  const StudentHome({super.key});

  @override
  State<AbstractHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends AbstractHomeState {
  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    return l;
  }
}
