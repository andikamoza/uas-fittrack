import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/preference_service.dart';
import '../auth/login_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen>
    with SingleTickerProviderStateMixin {
  String? goal;
  String? activityLevel;
  String? workoutTime;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<String> goals = ['Lose weight', 'Stay fit', 'Gain muscle'];
  final List<String> activityLevels = ['Sedentary', 'Active', 'Very active'];
  final List<String> workoutTimes = ['Morning', 'Afternoon', 'Night'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _savePreferences() async {
    if (goal != null && activityLevel != null && workoutTime != null) {
      await PreferenceService.savePreferenceData({
        'goal': goal,
        'activityLevel': activityLevel,
        'workoutTime': workoutTime,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all preferences')),
      );
    }
  }

  Widget _buildCard({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 16, color: Colors.blue[900])),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              final selected = option == selectedValue;
              return ChoiceChip(
                label: Text(option, style: GoogleFonts.poppins()),
                selected: selected,
                onSelected: (_) => onChanged(option),
                selectedColor: Colors.blue.shade200,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        elevation: 0,
        title: Text(
          'Your Preferences',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => Transform.scale(
                  scale: 0.9 + (_controller.value * 0.1),
                  child: Icon(Icons.auto_awesome, size: 60, color: Colors.blue.shade400),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Let\'s set your preferences\nto personalize your FitTrack experience!',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue.shade800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'What is your health goal?',
                options: goals,
                selectedValue: goal,
                onChanged: (value) => setState(() => goal = value),
              ),
              _buildCard(
                title: 'How active are you?',
                options: activityLevels,
                selectedValue: activityLevel,
                onChanged: (value) => setState(() => activityLevel = value),
              ),
              _buildCard(
                title: 'When do you usually work out?',
                options: workoutTimes,
                selectedValue: workoutTime,
                onChanged: (value) => setState(() => workoutTime = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'Save & Continue',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
