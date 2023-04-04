import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/homePage/admin_home.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.indigo,
      selectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.food_bank),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.link),
          label: 'Misc',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.popUntil(context, ModalRoute.withName("/"));

            if (Ids.role.compareTo("admin") == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AdminHome(),
                  ));
            } else if (Ids.role.compareTo("club") == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const ClubHome(),
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const StudentHome(),
                  ));
            }
            break;
          case 1:
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const EventCalendarScreen(),
                ));
            break;
          case 2:
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Events(),
                ));
            break;
          case 3:
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const MessMenuPage(), // PUT NAME OF CLASS HERE FOR ROUTING, OK JATIN?
                ));
            break;
          case 4:
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const QuickLinks(),
                ));
            break;
          default:
        }
      },
    );
  }
}
