import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
import '../home/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _login(BuildContext context) async {
    await PreferenceService.setLoginStatus(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _login(context),
          child: const Text("Login (Dummy)"),
        ),
      ),
    );
  }
}
