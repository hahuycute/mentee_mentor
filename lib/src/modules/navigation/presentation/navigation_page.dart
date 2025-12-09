import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/modules/main_home/presentation/main_home_page.dart';
import 'package:mentee_mentor/src/modules/profile/profile_page.dart';
import 'package:mentee_mentor/src/modules/my_schedules/presentation/my_schedule_page.dart';
import 'package:mentee_mentor/src/modules/booking/presentation/booking_list_page.dart';
import 'package:mentee_mentor/src/modules/sessions/presentation/sessions_list_page.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class NavigationPage extends StatefulWidget {
  final int initialIndex;
  const NavigationPage({super.key, this.initialIndex = 0});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with TickerProviderStateMixin {
  late int _currentIndex;
  late MotionTabBarController _tabController;
  final List<Widget> _pages = [
    MainHomePage(),
    MySchedulesPage(),
    BookingListPage(),
    SessionsListPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = MotionTabBarController(initialIndex: _currentIndex, length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MotionTabBar(
        controller: _tabController,
        initialSelectedTab: "Home",
        labels: ["Home", "Calen", "Book", "Sess", "Profile"],
        icons: [Icons.home, Icons.calendar_today, Icons.event, Icons.list, Icons.person],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        tabIconColor: Colors.blue,
        tabIconSelectedColor: Colors.white,
        tabSelectedColor: Colors.blue,
        onTabItemSelected: (int value) {
          setState(() {
            _tabController.index = value;
            _currentIndex = value;
          });
        },
      ),
      
    );
  }
}