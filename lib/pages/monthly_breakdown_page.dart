import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class MonthlyBreakdownPage extends StatelessWidget {
  const MonthlyBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final entries = provider.entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final months = _groupByMonth(entries);

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Breakdown")),
      body: ListView.builder(
        itemCount: months.length,
        itemBuilder: (_, i) {
          final m = months[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(m.label),
              subtitle: Text(
                "Total: \$${m.totalCash.toStringAsFixed(2)}\n"
                "Hours: ${m.totalHours.toStringAsFixed(1)}\n"
                "Avg: \$${m.average.toStringAsFixed(2)}",
              ),
            ),
          );
        },
      ),
    );
  }

  List<_MonthGroup> _groupByMonth(List<Entry> entries) {
    final List<_MonthGroup> result = [];

    int? currentYear;
    int? currentMonth;
    List<Entry> currentEntries = [];

    for (final e in entries) {
      final y = e.date.year;
      final m = e.date.month;

      if (currentYear == null || currentMonth == null || y != currentYear || m != currentMonth) {
        if (currentEntries.isNotEmpty) {
          result.add(_MonthGroup.fromEntries(currentYear!, currentMonth!, currentEntries));
        }
        currentYear = y;
        currentMonth = m;
        currentEntries = [];
      }

      currentEntries.add(e);
    }

    if (currentEntries.isNotEmpty) {
      result.add(_MonthGroup.fromEntries(currentYear!, currentMonth!, currentEntries));
    }

    return result;
  }
}

class _MonthGroup {
  final String label;
  final double totalCash;
  final double totalHours;
  final double average;

  _MonthGroup({
    required this.label,
    required this.totalCash,
    required this.totalHours,
    required this.average,
  });

  factory _MonthGroup.fromEntries(int year, int month, List<Entry> entries) {
    final label = DateFormat('MMMM yyyy').format(DateTime(year, month));

    final totalCash = entries.fold(0.0, (sum, e) => sum + e.cash);
    final totalHours = entries.fold(0.0, (sum, e) => sum + e.hours);
    final average = entries.isEmpty ? 0.0 : totalCash / entries.length;

    return _MonthGroup(
      label: label,
      totalCash: totalCash,
      totalHours: totalHours,
      average: average,
    );
  }
}
