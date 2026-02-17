import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import 'package:intl/intl.dart';
import 'weekly_breakdown_page.dart';
import 'monthly_breakdown_page.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final entries = provider.entries;

    // Totals
    final totalCash = entries.fold<double>(0, (sum, e) => sum + e.cash);
    final totalHours = entries.fold<double>(0, (sum, e) => sum + e.hours);
    final overallAverage = totalHours == 0 ? 0 : totalCash / totalHours;

    // Weekly total (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyEntries = entries
        .where((e) => e.date.isAfter(weekAgo))
        .toList();
    final weeklyCash = weeklyEntries.fold<double>(0, (sum, e) => sum + e.cash);
    final weeklyAvg = weeklyEntries.isEmpty
        ? 0
        : weeklyCash / weeklyEntries.length;

    // Monthly total (current month)
    final monthlyEntries = entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final monthlyCash = monthlyEntries.fold<double>(
      0,
      (sum, e) => sum + e.cash,
    );
    final monthlyAvg = monthlyEntries.isEmpty
        ? 0
        : monthlyCash / monthlyEntries.length;

    // Best day (highest cash)
    final bestEntry = entries.isEmpty
        ? null
        : entries.reduce((a, b) => a.cash > b.cash ? a : b);

    final bestDayLabel = bestEntry == null
        ? "No entries yet"
        : "${DateFormat('EEE, MMM d').format(bestEntry.date)}\n\$${bestEntry.cash.toStringAsFixed(2)}";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Stats Overview",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔥 2-column grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _StatCard(
                label: "Total Cash",
                value: "\$${totalCash.toStringAsFixed(2)}",
              ),
              _StatCard(
                label: "Total Hours",
                value: totalHours.toStringAsFixed(1),
              ),
              _StatCard(
                label: "Overall Avg",
                value: "\$${overallAverage.toStringAsFixed(2)}/hr",
              ),

              // 🔥 Last 7 Days (Total + Avg)
              _StatCard(
                label: "Last 7 Days",
                value:
                    "Total: \$${weeklyCash.toStringAsFixed(2)}\nAvg: \$${weeklyAvg.toStringAsFixed(2)}",
                isLarge: false,
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeeklyBreakdownPage(),
                    ),
                  );
                },
              ),

              // 🔥 This Month (Total + Avg)
              _StatCard(
                label: "This Month",
                value:
                    "Total: \$${monthlyCash.toStringAsFixed(2)}\nAvg: \$${monthlyAvg.toStringAsFixed(2)}",
                isLarge: false,
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MonthlyBreakdownPage(),
                    ),
                  );
                },
              ),

              _StatCard(label: "Best Day", value: bestDayLabel, isLarge: false),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isLarge;
  final bool showArrow;
  final VoidCallback? onTap; // 👈 NEW

  const _StatCard({
    required this.label,
    required this.value,
    this.isLarge = true,
    this.showArrow = false,
    this.onTap, // 👈 NEW
  });

  Color _getValueColor() {
    if (label.contains("Cash") ||
        label.contains("Avg") ||
        label.contains("Best Day") ||
        label.contains("Last 7 Days") ||
        label.contains("This Month")) {
      return Color.fromARGB(255, 35, 176, 28);
    }

    if (label.contains("Hours")) {
      return Colors.blue;
    }

    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 👈 Card is now tappable
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                value,
                textAlign: TextAlign.center,
                style:
                    (isLarge
                            ? Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              )
                            : Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ))
                        ?.copyWith(color: _getValueColor()),
              ),

              if (showArrow)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
