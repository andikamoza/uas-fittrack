import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _durationController = TextEditingController();
  String _selectedWorkout = 'Running';

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

  List<List<double>> weeklyCalories = List.generate(7, (_) => []);
  List<List<String>> weeklyWorkoutType = List.generate(7, (_) => []);

  void _addWorkoutToChart() async {
    final durationText = _durationController.text.trim();
    final duration = double.tryParse(durationText);
    if (duration == null || duration <= 0) return;

    final calorieRate = _calorieRates[_selectedWorkout]!;
    final calories = duration * calorieRate;
    final weekday = DateTime.now().weekday % 7;

    setState(() {
      weeklyCalories[weekday].add(calories);
      weeklyWorkoutType[weekday].add(_selectedWorkout);
    });

    try {
      await FirebaseFirestore.instance.collection('workouts').add({
        'type': _selectedWorkout,
        'duration': duration,
        'calories': calories,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout successfully logged!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log workout: $e')),
      );
    }

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
        child: ListView(
          children: [
            const Text("Log Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedWorkout,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                      if (value != null) {
                        setState(() => _selectedWorkout = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      border: OutlineInputBorder(),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Calories Burned (kcal)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 250,
                  width: constraints.maxWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: getMaxY(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              return Text(
                                weekDays[index % 7],
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 50,
                            reservedSize: 36,
                            getTitlesWidget: (value, _) =>
                                Text("${value.toInt()} kcal", style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (dayIndex) {
                        return BarChartGroupData(
                          x: dayIndex,
                          barRods: List.generate(weeklyCalories[dayIndex].length, (entryIndex) {
                            final type = weeklyWorkoutType[dayIndex][entryIndex];
                            return BarChartRodData(
                              toY: weeklyCalories[dayIndex][entryIndex],
                              color: _workoutColors[type] ?? Colors.blue,
                              width: 8,
                              borderRadius: BorderRadius.circular(4),
                            );
                          }),
                          barsSpace: 4,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text("Health Articles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('articles')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No articles available.");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ArticleCard(
                      title: data['title'] ?? 'No Title',
                      imageUrl: data['imageUrl'] ?? '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Opening: ${data['title']}")),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
