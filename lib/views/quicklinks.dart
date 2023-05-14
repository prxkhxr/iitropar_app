import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinks extends StatefulWidget {
  const QuickLinks({super.key});

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  final Map<String, Map<String, String>> quickLinks = {
    'Academics': {
      'Library': 'https://www.iitrpr.ac.in/library',
      'Departments': 'https://www.iitrpr.ac.in/departments-centers',
      'Course Booklet':
          'https://www.iitrpr.ac.in/sites/default/files/COURSE%20BOOKLET%20FOR%20UG%202018-19.pdf',
      'UG Handbook':
          'https://www.iitrpr.ac.in/sites/default/files/Final%20Handbook%20of%20Information%20AY%202022-23.pdf',
    },
    'Facilities': {
      'Medical Centre': 'https://www.iitrpr.ac.in/medical-center/',
      'Guest House': 'https://www.iitrpr.ac.in/guest-house/',
      'Bus Timings':
          'https://docs.google.com/document/d/1oFeyY-JxaXzPH0hWT1HTMEA_nOtyz1g1w2XYEwTC9_Y/edit/',
          'Hostel': 'https://www.iitrpr.ac.in/hostels',
          'Download Forms':'https://www.iitrpr.ac.in/downloads/forms.html',

    },
    'Student Activities': {
      'क्षितिज – The Horizon': 'https://www.iitrpr.ac.in/kshitij/',
      'TBIF': 'https://www.tbifiitrpr.org/',
      'BOST': 'https://bost-19.github.io/',

    },
    'Departments': {
      'Biomedical': 'http://www.iitrpr.ac.in/cbme',
      'Chemical': 'https://www.iitrpr.ac.in/chemical',
      'Chemistry': 'https://www.iitrpr.ac.in/chemistry',
      'Civil': 'https://www.iitrpr.ac.in/civil',
      'CSE': 'https://cse.iitrpr.ac.in/',
      'Electrical': 'https://ee.iitrpr.ac.in/',
      'HSS': 'https://www.iitrpr.ac.in/hss/',
      'Mathematical': 'https://www.iitrpr.ac.in/math/',
      'Physics': 'http://www.iitrpr.ac.in/physics/',
      'Mechanical': 'https://mech.iitrpr.ac.in/',
      'Metallurgical': 'https://mme.iitrpr.ac.in/',
    },
    'Our Team': {
        'Dr Puneet Goyal(Mentor)' : 'https://sites.google.com/view/goyalpuneet/',
        'Jugal Chapatwala(Backend Developer)': 'https://www.linkedin.com/in/jugal-chapatwala-636143179/',
        'Gautam Sethia(Backend Developer)' : 'https://www.linkedin.com/in/gautamsethia7/',
        'Jatin Gupta(Frontend Developer)': 'https://www.linkedin.com/in/jatingupta1792/',
        'Prakhar Saxena(Frontend Developer)': 'https://www.linkedin.com/in/prakhar-saxena-148a10209/'
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Color(secondaryLight),
        title: buildTitleBar("QUICK LINKS", context),
      ),
      backgroundColor: Color(secondaryLight),
      body: ListView.builder(
        itemCount: quickLinks.length,
        itemBuilder: (context, index) {
          String category = quickLinks.keys.elementAt(index);
          Map<String, String> links = quickLinks[category]!;
          return Column(
            children: [
              const SizedBox(
              height: 20,
            ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff555555)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Color(primaryLight).withOpacity(.5), 
                      blurStyle: BlurStyle.outer,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ExpansionTile(
                   initiallyExpanded: index == 0,
                  title: Text(category,style: TextStyle(fontWeight: FontWeight.bold, color: Color(primaryLight)),),
                  children: [
                    for (var linkName in links.keys)
                      ListTile(

                        title: Text(linkName,style: TextStyle(color: Color(primaryLight)),),
                        onTap: () async {
                          String url = links[linkName]!;
                          _launchURL(url);
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(
        Icons.sync_rounded,
      ),
      color: Color(primaryLight),
      iconSize: 28,
    );
  }

  TextStyle appbarTitleStyle() {
    return TextStyle(
        color: Color(primaryLight),
        // fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5);
  }

  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        themeButtonWidget(),
        Flexible(
          child: SizedBox(
            height: 30,
            child: FittedBox(
              child: Text(
                text,
                style: appbarTitleStyle(),
              ),
            ),
          ),
        ),
        signoutButtonWidget(context),
      ],
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
