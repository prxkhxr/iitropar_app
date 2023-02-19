import 'package:flutter/material.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/home_page.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Text('Navigation Menu',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
            ),
            title: const Text('Home'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage(),
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_month,
            ),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const EventCalendarScreen(),
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.event,
            ),
            title: const Text('Events'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Events(),
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.food_bank,
            ),
            title: const Text('Mess Menu'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  MessMenuPage(), // PUT NAME OF CLASS HERE FOR ROUTING, OK JATIN?
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.link,
            ),
            title: const Text('Quick Links'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const QuickLinks(),
                )
              );
            },
          ),
        ],
      ),
    );
  }
}