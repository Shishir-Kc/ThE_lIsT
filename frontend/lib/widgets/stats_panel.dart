import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../services/task_service.dart';
import 'package:intl/intl.dart';

class StatsPanel extends StatefulWidget {
  final TaskService taskService;
  const StatsPanel({super.key, required this.taskService});

  @override
  State<StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends State<StatsPanel> {
  // Animation stuff
  List<BarChartGroupData> _barGroups = [];
  Map<int, DateTime> _dayIndexMap = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    widget.taskService.addListener(_updateData);
    widget.taskService.fetchActivity();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      widget.taskService.fetchActivity();
    });
    _updateData();
  }

  @override
  void dispose() {
    widget.taskService.removeListener(_updateData);
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _updateData() {
    _generateGraphData();
    setState(() {});
  }

  void _generateGraphData() {
    final sessions = widget.taskService.activitySessions;
    if (sessions.isEmpty) {
      _barGroups = [];
      return;
    }

    // 1. Group sessions by day
    final Map<String, List<ActivitySession>> sessionsByDay = {};
    for (var session in sessions) {
      // Handle sessions spanning multiple days could be complex, 
      // for now simplistic assumption or visual clamping
      // better: split session if creates visual overflow? 
      // For this UI, simple mapping to Start Date's day is reasonable first step.
      final key = _formatDateKey(session.start);
      if (!sessionsByDay.containsKey(key)) {
        sessionsByDay[key] = [];
      }
      sessionsByDay[key]!.add(session);
    }

    // 2. Create BarGroups
    // Sort days
    final sortedKeys = sessionsByDay.keys.toList()..sort();
    // optionally limit to last 7 or 30 days? 
    // User sample has 2026, let's just show what we have.
    
    _barGroups = [];
    _dayIndexMap.clear();

    for (int i = 0; i < sortedKeys.length; i++) {
        final key = sortedKeys[i];
        final sessions = sessionsByDay[key]!;
        // Assuming key is yyyy-MM-dd
        final dayDate = DateTime.parse(key);
        _dayIndexMap[i] = dayDate;

        final rods = <BarChartRodData>[];
        for (var session in sessions) {
             // Calculate start and end hours (0.0 - 24.0)
             final startH = session.start.hour + session.start.minute / 60.0;
             var endH = session.end.hour + session.end.minute / 60.0;
             
             // Handle day overflow visual
             if (session.end.day != session.start.day) {
                 endH = 24.0; // Draw to end of day
             }
             
             rods.add(BarChartRodData(
                 toY: endH,
                 fromY: startH,
                 color: Theme.of(context).colorScheme.primary,
                 width: 8, // Thicker bars
                 borderRadius: BorderRadius.circular(2),
             ));
        }
        
        _barGroups.add(BarChartGroupData(
            x: i,
            barRods: rods,
        ));
    }
  }

  String _formatDateKey(DateTime date) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: Text(
              "Activity",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Caveat',
                    fontSize: 24,
                  ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            top: 60, // Leave space for title
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_barGroups.isEmpty) {
      return const Center(child: Text("No Activity Data"));
    }
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 4, // Every 4 hours line
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05)),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 4, // 0, 4, 8, 12, 16, 20, 24
                  getTitlesWidget: (value, meta) {
                       final int hour = value.toInt();
                       if (hour < 0 || hour > 24) return const SizedBox();
                       
                       String text;
                       if (hour == 0 || hour == 24) text = '12 AM';
                       else if (hour < 12) text = '$hour AM';
                       else if (hour == 12) text = '12 PM';
                       else text = '${hour - 12} PM';
                       
                       return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10));
                  }
              )
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final date = _dayIndexMap[index];
                if (date == null) return const SizedBox();
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 24, 
        barGroups: _barGroups,
      ),
    );
  }
}
