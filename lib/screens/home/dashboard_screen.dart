import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
import '../auth/login_screen.dart';
import 'package:fittrack/services/preference_service.dart'; // ← Tambahkan ini


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await PreferenceService.setLoginStatus(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitTrack Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to your health dashboard!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
