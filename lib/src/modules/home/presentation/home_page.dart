import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/modules/main_home/presentation/main_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MainHomePage(),
    );
  }
}