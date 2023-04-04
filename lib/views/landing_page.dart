import 'package:flutter/src/widgets/framework.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/signin.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static bool _signin = false;

  static void signin(bool val) {
    _signin = val;
  }

  @override
  Widget build(BuildContext context) {
    if (_signin) {
      return const SignInScreen();
    } else {
      return const HomePage();
    }
  }
}
