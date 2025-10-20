import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/modules/add_post/presentation/add_post_page.dart';
import 'package:mentee_mentor/src/modules/main_home/presentation/main_home_page.dart';
import 'package:mentee_mentor/src/modules/noti/presentation/noti_page.dart';
import 'package:mentee_mentor/src/modules/profile/profile_page.dart';
import 'package:mentee_mentor/src/modules/search/presentation/searching_page.dart';
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
    SearchingPage(),
    NotiPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = MotionTabBarController(initialIndex: _currentIndex, length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  Future<void> _goAddPost() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPostPage()),
    );
    // Nếu đăng bài thành công, có thể reload lại MainHomePage nếu cần
    if (result == true && _currentIndex == 0) {
      setState(() {});
    }
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
        labels: const ["Home", "Search", "Noti", "Profile"],
        icons: const [Icons.home, Icons.search, Icons.notifications, Icons.person],
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _goAddPost,
              child: const Icon(Icons.add),
              tooltip: 'Đăng bài',
            )
          : null,
    );
  }
}