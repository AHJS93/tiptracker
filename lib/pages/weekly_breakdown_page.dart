import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class WeeklyBreakdownPage extends StatelessWidget {
  const WeeklyBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final entries = provider.entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 👇 Use Monday as the fixed start of week
    final List<_WeekGroup> weeks = _groupByWeek(entries, DateTime.monday);

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Breakdown")),
      body: ListView.builder(
        itemCount: weeks.length,
        itemBuilder: (_, i) {
          final week = weeks[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(week.label),
              subtitle: Text(
                "Total: \$${week.totalCash.toStringAsFixed(2)}\n"
                "Hours: ${week.totalHours.toStringAsFixed(1)}\n"
                "Avg: \$${week.average.toStringAsFixed(2)}",
              ),
            ),
          );
        },
      ),
    );
  }

  // Groups entries into weeks based on a fixed start-of-week
  List<_WeekGroup> _groupByWeek(List<Entry> entries, int startOfWeek) {
    final List<_WeekGroup> result = [];

    DateTime? currentStart;
    List<Entry> currentEntries = [];

    for (final e in entries) {
      final rawStart = e.date.subtract(
        Duration(days: (e.date.weekday - startOfWeek) % 7),
      );

      // Normalize to midnight to avoid duplicates
      final weekStart = DateTime(rawStart.year, rawStart.month, rawStart.day);

      if (currentStart == null || !weekStart.isAtSameMomentAs(currentStart)) {
        if (currentEntries.isNotEmpty) {
          result.add(_WeekGroup.fromEntries(currentStart!, currentEntries));
        }
        currentStart = weekStart;
        currentEntries = [];
      }

      currentEntries.add(e);
    }

    if (currentEntries.isNotEmpty) {
      result.add(_WeekGroup.fromEntries(currentStart!, currentEntries));
    }

    return result;
  }
}

class _WeekGroup {
  final String label;
  final double totalCash;
  final double totalHours;
  final double average;

  _WeekGroup({
    required this.label,
    required this.totalCash,
    required this.totalHours,
    required this.average,
  });

  factory _WeekGroup.fromEntries(DateTime start, List<Entry> entries) {
    final end = start.add(const Duration(days: 6));

    final label =
        "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}";

    final totalCash = entries.fold(0.0, (sum, e) => sum + e.cash);
    final totalHours = entries.fold(0.0, (sum, e) => sum + e.hours);

    final average = entries.isEmpty ? 0.0 : totalCash / entries.length;

    return _WeekGroup(
      label: label,
      totalCash: totalCash,
      totalHours: totalHours,
      average: average,
    );
  }
}
