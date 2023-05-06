// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'homePage/admin_page.dart';

class MainLandingPage extends StatelessWidget {
  const MainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: _buildScreens(),
      items: _navbarItems(),
      navBarStyle: NavBarStyle.style9,
      backgroundColor: Color(secondaryLight),
      screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: false,
          duration: Duration(seconds: 1),
          curve: Curves.ease),
    );
  }

  List<Widget> _buildScreens() {
    if (Ids.role == "admin") {
      return [
        const AdminHomePage(),
        const EventCalendarScreen(),
        const Events(),
        const MessMenuPage(),
        const QuickLinks()
      ];
    } else {
      return [
        const HomePage(),
        const EventCalendarScreen(),
        const Events(),
        const MessMenuPage(),
        const QuickLinks()
      ];
    }
  }

  List<PersistentBottomNavBarItem> _navbarItems() {
    return [
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.home),
          title: 'Home',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.calendar),
          title: 'Calendar',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.event),
          title: 'Events',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.food_bank),
          title: 'Mess Menu',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.link),
          title: 'Quick Links',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
    ];
  }
}
