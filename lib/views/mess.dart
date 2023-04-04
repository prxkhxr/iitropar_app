import 'package:flutter/material.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';
import 'package:iitropar/frequently_used.dart';

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
          title: const Text('Mess Menu'),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white30,
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide:
                  BorderSide(color: Colors.white, width: 2), // Indicator height
              insets: EdgeInsets.symmetric(horizontal: 48), // Indicator width
            ),
            tabs: myTabs,
          ),
        ),
        drawer: const NavDrawer(),
        body: TabBarView(
          children: [
            ..._daysOfWeek.map((day) => _buildMenuList(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(String day) {
    return ListView.builder(
      itemCount: _menu[day]!.length,
      itemBuilder: (context, index) {
        final meal = _menu[day]![index];

        return ExpansionTile(
          title: Text(meal.name),
          subtitle: Text(checkTime(meal.name)),
          initiallyExpanded: meal.name == "Breakfast" ? true : false,
          children: [
            ...parseString(meal.description).map((myMeal) {
              return ListTile(
                title: Text(myMeal),
              );
            })
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
