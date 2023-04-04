import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class MainLandingPage extends StatelessWidget {
  const MainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: _buildScreens(),
      items: _navbarItems(),
      navBarStyle: NavBarStyle.style9,
    );
  }

  List<Widget> _buildScreens(){
    return [
      const HomePage(),
      const EventCalendarScreen(),
      const Events(),
      const MessMenuPage(),
      const QuickLinks()
    ];
  }

  List<PersistentBottomNavBarItem> _navbarItems(){
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: 'Home',
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey[400]
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.calendar),
        title: 'Calendar',
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey[400]
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.event),
        title: 'Events',
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey[400]
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.food_bank),
        title: 'Mess Menu',
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey[400]
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.link),
        title: 'Quick Links',
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey[400]
      ),
    ];
  }
}
