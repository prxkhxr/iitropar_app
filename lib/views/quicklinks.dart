import 'package:flutter/material.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';

class QuickLinks extends StatefulWidget {
  const QuickLinks({super.key});

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Links"),
      ),
      drawer: const NavDrawer(),
    );
  }
}
