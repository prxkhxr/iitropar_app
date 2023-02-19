
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/navigation_drawer.dart';


class MenuItem {
  String name;
  String description;

  MenuItem(this.name, this.description);
}

class MessMenuPage extends StatefulWidget {
  @override
  _MessMenuPageState createState() => _MessMenuPageState();
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

  final Map<String, List<MenuItem>> _menu = {
    'Monday': [
      MenuItem('Breakfast', 'Aloo pyaz paratha, Sprouts, Milk'),
      MenuItem('Lunch', 'Veg Biryani, Dal tadka, Mix-Raita'),
      MenuItem('Dinner', 'Clear soup, Lauki chana ki sabzi, Arhar Dal, Roti')
    ],
    'Tuesday': [
      MenuItem('Breakfast', 'Uttapam Sambar, Bread, Butter, Jam'),
      MenuItem('Lunch', 'Cabbage and Beans ki sabzi, Dal makhani with Curd'),
      MenuItem('Dinner', 'Ajwain Paratha, Chole, Palak arhar dal, Rice')
    ],
    'Wednesday': [
      MenuItem('Breakfast', 'Methi puri, Aloo-Gobhi, Sweet Corn rice and naan bread'),
      MenuItem('Lunch', 'Rajma Chawal, Curd with Chapati'),
      MenuItem('Dinner', 'Mix-Veg-Paneer Biryani, Dal tadka, Mix-Raita')
    ],
    'Thursday': [
      MenuItem('Breakfast', 'Upma, Bread-Pakoda with Fruits'),
      MenuItem('Lunch', 'Kadi-Pakoda, Alu methi, Jeera rice with Papad'),
      MenuItem('Dinner', 'Hot-n-Sour Soup, Baingan bharta, Masoor dal')
    ],
    'Friday': [
      MenuItem('Breakfast', 'Poha, Medu Wada(2Pc), Sprouts and Bread, Butter, Jam'),
      MenuItem('Lunch', 'Palak Paneer, Arhar Dal, Curd with Chapati '),
      MenuItem('Dinner', 'Sev-Tamatar, Matar Pulao, Green Sabut Moong dal with Ladoo')
    ],
    'Saturday': [
      MenuItem('Breakfast', 'Pav Bhaji, Sprouts, boiled-egg with Bournvita'),
      MenuItem('Lunch', 'Vegetable Khichdi, Alu-pyaz ka bharta, Papad with Curd'),
      MenuItem('Dinner', 'Tomato Soup, Gajar Matar Sabzi, Moth dal, Rice')
    ],
    'Sunday': [
      MenuItem('Breakfast', 'Besan Chilla, Dalia(Sweet) omelette and Milk'),
      MenuItem('Lunch', 'Masala-puri, Chana masala, Tomato rice bread with Boondi-Raita'),
      MenuItem('Dinner', 'Butter Chicken, Arhar dal, Rice, Tandoori Roti')
    ],
  };

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
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mess Menu'),
          backgroundColor: const Color.fromARGB(255, 58, 126, 245),
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
            Text(
              'Menu for ${_daysOfWeek[_selectedDayIndex]}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
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

        return ListTile(
          title: Text(meal.name),
          subtitle: Text(meal.description),
        );
      },
    );
  }
}
