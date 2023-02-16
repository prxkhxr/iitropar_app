import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      drawer: Drawer(
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
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/login');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event,
              ),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popAndPushNamed('/events');
              },
            ),
          ],
        ),
      ),
    );
  }
}
