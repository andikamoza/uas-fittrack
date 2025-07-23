import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/preference_service.dart';
import '../auth/login_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  String? goal;
  String? activityLevel;
  String? workoutTime;

  final List<String> goals = ['Lose Weight', 'Stay Fit', 'Build Muscle'];
  final List<String> activityLevels = ['Sedentary', 'Active', 'Very Active'];
  final List<String> workoutTimes = ['Morning', 'Evening', 'Night'];

  void _savePreferences() async {
    if (goal != null && activityLevel != null && workoutTime != null) {
      await PreferenceService.savePreferenceData({
        'goal': goal,
        'activityLevel': activityLevel,
        'workoutTime': workoutTime,
      });

      // ✅ Tampilkan snackbar custom
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Preferences saved successfully!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      // ⏳ Tunggu sedikit sebelum pindah halaman
      await Future.delayed(const Duration(milliseconds: 1600));

      // 🔁 Pindah ke halaman Login
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all preferences')),
      );
    }
  }


  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              isExpanded: true,
              hint: Text('Select $label'),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Preferences',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown(
                  label: "What's your goal?",
                  icon: Icons.fitness_center,
                  value: goal,
                  items: goals,
                  onChanged: (val) => setState(() => goal = val),
                ),
                _buildDropdown(
                  label: "Activity Level",
                  icon: Icons.directions_walk,
                  value: activityLevel,
                  items: activityLevels,
                  onChanged: (val) => setState(() => activityLevel = val),
                ),
                _buildDropdown(
                  label: "Workout Time",
                  icon: Icons.access_time,
                  value: workoutTime,
                  items: workoutTimes,
                  onChanged: (val) => setState(() => workoutTime = val),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Preferences',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
