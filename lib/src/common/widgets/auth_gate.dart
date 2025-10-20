import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/storage/token_storage.dart';
import 'package:mentee_mentor/src/modules/home/presentation/home_page.dart';
import 'package:mentee_mentor/src/modules/login/presentation/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _hasToken;
  @override
  void initState() {
    super.initState();
    _hasToken = _checkToken();
  }
  Future<bool> _checkToken() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _hasToken,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const HomePage() : const LoginPage();
      },
    );
  }
}