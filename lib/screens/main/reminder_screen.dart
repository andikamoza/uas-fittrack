import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ Jangan gunakan const untuk AppBar, karena Text bukan const di sini
      appBar: AppBar(title: const Text("Reminder")),
      body: const Center(
        child: Text(
          "Set your daily reminders here.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
