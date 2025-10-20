import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentee_mentor/src/common/widgets/auth_gate.dart';


void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Đặt style cho system bars (Android)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false, // quan trọng trên Android 10+
  ));
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Mentee Mentor',
      home: AuthGate(),
    );
  }
}

