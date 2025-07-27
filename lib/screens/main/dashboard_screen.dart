// File: lib/screens/dashboard/dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_preference.dart';
import '../../services/firestore_service.dart';
import '../../services/share_pref_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _durationController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _sharedPrefService = SharedPrefService();

  String _selectedWorkout = 'Running';
  List<List<double>> weeklyCalories = List.generate(7, (_) => []);
  List<List<String>> weeklyWorkoutType = List.generate(7, (_) => []);

  final Map<String, double> _calorieRates = {
    'Running': 10,
    'Cycling': 8,
    'Swimming': 11,
    'Walking': 4,
  };

  final Map<String, IconData> _workoutIcons = {
    'Running': Icons.directions_run,
    'Cycling': Icons.directions_bike,
    'Swimming': Icons.pool,
    'Walking': Icons.directions_walk,
  };

  final Map<String, Color> _workoutColors = {
    'Running': Colors.redAccent,
    'Cycling': Colors.green,
    'Swimming': Colors.blue,
    'Walking': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _loadWorkoutLogs();
  }

  Future<void> _loadUserPreferences() async {
    final pref = await _sharedPrefService.getUserPreference();
    if (pref != null) {
      await _firestoreService.savePreferenceToFirestore(pref);
    }
  }

  Future<void> _loadWorkoutLogs() async {
    final logs = await _firestoreService.getWorkoutLogs();
    for (var log in logs) {
      final date = (log['createdAt'] as Timestamp).toDate();
      final weekday = date.weekday % 7;
      setState(() {
        weeklyCalories[weekday].add((log['calories'] as num).toDouble());
        weeklyWorkoutType[weekday].add(log['type'] as String);
      });
    }
  }

  Future<void> _addWorkoutToChart() async {
    final durationText = _durationController.text.trim();
    final duration = double.tryParse(durationText);
    if (duration == null || duration <= 0) return;

    final calorieRate = _calorieRates[_selectedWorkout]!;
    final calories = duration * calorieRate;
    final weekday = DateTime.now().weekday % 7;
    final now = Timestamp.now();

    setState(() {
      weeklyCalories[weekday].add(calories);
      weeklyWorkoutType[weekday].add(_selectedWorkout);
    });

    final workoutData = {
      'type': _selectedWorkout,
      'duration': duration,
      'calories': calories,
      'createdAt': now,
    };

    await _firestoreService.saveWorkoutLog(workoutData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout successfully logged!')),
    );

    _durationController.clear();
  }

  List<String> getWeekDays() {
    final now = DateTime.now();
    final todayIndex = now.weekday % 7;
    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: todayIndex - index));
      return DateFormat.E().format(day);
    });
  }

  double getMaxY() {
    double max = 0;
    for (var daily in weeklyCalories) {
      final total = daily.fold(0.0, (a, b) => a + b);
      if (total > max) max = total;
    }
    return (max <= 0) ? 100 : (max * 1.2).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = getWeekDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Activity Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildWorkoutForm(),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Your Weekly Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              _buildBarChart(weekDays),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Latest Articles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              _buildArticlesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Log Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedWorkout,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
              labelText: "Workout Type",
            ),
            items: _calorieRates.keys.map((workout) {
              return DropdownMenuItem(
                value: workout,
                child: Row(
                  children: [
                    Icon(_workoutIcons[workout], color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(workout),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedWorkout = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duration (min)',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addWorkoutToChart,
              icon: const Icon(Icons.add),
              label: const Text("Add Workout"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<String> weekDays) {
    return Container(
      height: 260,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: BarChart(
        BarChartData(
          maxY: getMaxY(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  weekDays[value.toInt() % 7],
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (dayIndex) {
            return BarChartGroupData(
              x: dayIndex,
              barRods: List.generate(weeklyCalories[dayIndex].length, (entryIndex) {
                final type = weeklyWorkoutType[dayIndex][entryIndex];
                final value = weeklyCalories[dayIndex][entryIndex];
                return BarChartRodData(
                  toY: value,
                  color: _workoutColors[type] ?? Colors.blue,
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No articles available.");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final formattedDate = createdAt != null ? DateFormat('MMM dd, yyyy').format(createdAt) : 'Unknown';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((data['imageUrl'] as String?)?.isNotEmpty ?? false)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        data['imageUrl'],
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 160,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'No Title',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("By Andika · Published on $formattedDate", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          (data['content'] as String?)?.split("\n").first ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/article-detail', arguments: data);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text("More →", style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
