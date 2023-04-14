import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({super.key});

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage>
    with SingleTickerProviderStateMixin {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final Map<String, List<MenuItem>> _menu = Menu.menu;

  int _selectedDayIndex = 0;

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  List<MenuItem> _getMenuItemsForSelectedDay() {
    return _menu[_daysOfWeek[_selectedDayIndex]] ?? [];
  }

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Mon'),
    Tab(text: 'Tue'),
    Tab(text: 'Wed'),
    Tab(text: 'Thu'),
    Tab(text: 'Fri'),
    Tab(text: 'Sat'),
    Tab(text: 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Color(secondaryLight),
          title: buildTitleBar("MESS MENU", context),
          bottom: TabBar(
            labelColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            unselectedLabelColor: Color(primaryLight),
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  color: Color(primaryLight), width: 2), // Indicator height
              insets:
                  const EdgeInsets.symmetric(horizontal: 48), // Indicator width
            ),
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: [
            ..._daysOfWeek.map((day) => _buildMenuList(day)),
          ],
        ),
        backgroundColor: Color(secondaryLight),
      ),
    );
  }

  Widget _buildMenuList(String day) {
    return ListView.builder(
      itemCount: _menu[day]!.length,
      itemBuilder: (context, index) {
        final meal = _menu[day]![index];

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
                title: Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, color: Color(primaryLight)),),
                subtitle: Text(checkTime(meal.name), style: TextStyle(color: Color(primaryLight)),),
                initiallyExpanded: meal.name == "Breakfast" ? true : false,
                children: [
                  ...parseString(meal.description).map((myMeal) {
                    return ListTile(
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Color(primaryLight),),
                      title: Text(myMeal, style: TextStyle(color: Color(primaryLight)),),
                    );
                  })
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String checkTime(String name) {
    if (name == 'Breakfast') {
      return "7:30 AM to 9:15 AM";
    } else if (name == 'Lunch') {
      return "12:30 PM to 2:15 PM";
    } else {
      return "7:30 PM to 9:15 PM";
    }
  }

  List<String> parseString(String desc) {
    return desc.split(", ");
  }
}
