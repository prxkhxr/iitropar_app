import 'package:flutter/material.dart';
import 'package:iitropar/views/PBTabView.dart';
import 'package:iitropar/views/signin.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  static bool _signin = false;

  static void signin(bool val) {
    _signin = val;
  }

  @override
  Widget build(BuildContext context) {
    if (_signin) {
      return const SignInScreen();
    } else {
      return const MainLandingPage();
    }
  }
}
