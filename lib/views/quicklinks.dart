import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const QuickLinks(),
    );
  }
}

class QuickLinks extends StatefulWidget {
  const QuickLinks({super.key});

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  static const Map<String, String> links = {
    'Library': 'https://www.iitrpr.ac.in/library',
    'Departments': 'https://www.iitrpr.ac.in/departments-centers',
    'Course Booklet':
        'https://www.iitrpr.ac.in/sites/default/files/COURSE%20BOOKLET%20FOR%20UG%202018-19.pdf',
    'UG Handbook':
        'https://www.iitrpr.ac.in/sites/default/files/IIT-Ropar-UG-Handbook-2021-15.9.21-5-3.pdf',
    'Medical Centre': 'https://www.iitrpr.ac.in/medical-center/',
    'Guest House': 'https://www.iitrpr.ac.in/guest-house/',
    'Bus Timings':
        'https://docs.google.com/document/d/1oFeyY-JxaXzPH0hWT1HTMEA_nOtyz1g1w2XYEwTC9_Y/edit/',
    'क्षितिज – The Horizon': 'https://www.iitrpr.ac.in/kshitij/',
    'TBIF': 'https://www.tbifiitrpr.org/',
    'BOST': 'https://bost-19.github.io/',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Links'),
      ),
      body: GridView.count(
        crossAxisCount: 3, // 2 columns
        children: links.entries.map((entry) {
          return GestureDetector(
            onTap: () => _launchURL(entry.value),
            child: Card(
              child: Center(
                child: Text(entry.key),
              ),
            ),
          );
        }).toList(),
      ),
      // drawer: const NavDrawer(),
    );
  }

  // void _launchURL(String url) async {
  //   Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
