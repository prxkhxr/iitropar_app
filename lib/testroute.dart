import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
class TestRoute extends StatelessWidget {
  const TestRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yo mah niggas"),
      ),
      body: ElevatedButton(
        onPressed: (){},
        child: const Text("Sign out nigga."),
      ),
    );
  }
}