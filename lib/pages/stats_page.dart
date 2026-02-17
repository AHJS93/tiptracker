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
    final weeklyEntries = entries.where((e) => e.date.isAfter(weekAgo)).toList();
    final weeklyCash = weeklyEntries.fold<double>(0, (sum, e) => sum + e.cash);
    final weeklyAvg =
        weeklyEntries.isEmpty ? 0 : weeklyCash / weeklyEntries.length;

    // Monthly total (current month)
    final monthlyEntries = entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final monthlyCash =
        monthlyEntries.fold<double>(0, (sum, e) => sum + e.cash);
    final monthlyAvg =
        monthlyEntries.isEmpty ? 0 : monthlyCash / monthlyEntries.length;

    // Best day (highest cash)
    final bestEntry =
        entries.isEmpty ? null : entries.reduce((a, b) => a.cash > b.cash ? a : b);

    final bestDayLabel = bestEntry == null
        ? "No entries yet"
        : "${DateFormat('EEE, MMM d').format(bestEntry.date)}\n\$${bestEntry.cash.toStringAsFixed(2)}";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Stats Overview",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,
),
          ),

          const SizedBox(height: 20),

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
                label: "Overall Avg",
                value: "\$${overallAverage.toStringAsFixed(2)}/hr",
              ),

              _StatCard(
                label: "Last 7 Days",
                value:
                    "Total: \$${weeklyCash.toStringAsFixed(2)}\nAvg: \$${weeklyAvg.toStringAsFixed(2)}",
                isLarge: false,
                highlight: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeeklyBreakdownPage(),
                    ),
                  );
                },
              ),

              _StatCard(
                label: "This Month",
                value:
                    "Total: \$${monthlyCash.toStringAsFixed(2)}\nAvg: \$${monthlyAvg.toStringAsFixed(2)}",
                isLarge: false,
                highlight: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MonthlyBreakdownPage(),
                    ),
                  );
                },
              ),

              _StatCard(
                label: "Total Hours",
                value: totalHours.toStringAsFixed(1),
              ),

              _StatCard(
                label: "Best Day",
                value: bestDayLabel,
                isLarge: false,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final bool isLarge;
  final bool highlight;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    this.isLarge = true,
    this.onTap,
    this.highlight = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _borderController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // TAP controller FIRST — prevents LateInitializationError
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );

    // Border animation
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    if (widget.highlight) {
      _borderController.forward().whenComplete(() {
        _pulseController.forward().then((_) => _pulseController.reverse());
      });
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _borderController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getValueColor() {
    if (widget.label.contains("Cash") ||
        widget.label.contains("Avg") ||
        widget.label.contains("Best Day") ||
        widget.label.contains("Last 7 Days") ||
        widget.label.contains("This Month")) {
      return const Color.fromARGB(255, 35, 176, 28);
    }

    if (widget.label.contains("Hours")) {
      return Colors.blue;
    }

    return Colors.white;
  }

  List<TextSpan> _buildValueSpans(String text) {
    final green = const Color.fromARGB(255, 35, 176, 28);

    return text.split('\n').expand((line) {
      if (line.startsWith("Total:")) {
        return [
          TextSpan(text: "Total: ", style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
)),
          TextSpan(
            text: line.replaceFirst("Total: ", "") + "\n",
            style: TextStyle(color: green),
          ),
        ];
      }

      if (line.startsWith("Avg:")) {
        return [
          TextSpan(text: "Avg: ", style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
)),
          TextSpan(
            text: line.replaceFirst("Avg: ", ""),
            style: TextStyle(color: green),
          ),
        ];
      }

      return [
        TextSpan(
          text: line + "\n",
          style: TextStyle(color: _getValueColor()),
        )
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1 - (_tapController.value);

    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _borderController,
          _pulseController,
          _tapController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              painter: _BorderPainter(
                progress: _borderController.value,
                pulse: _pulseController.value,
                color: widget.highlight
                    ? const Color.fromARGB(255, 35, 176, 28)
                    : Colors.transparent,
              ),
              child: child,
            ),
          );
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),

                const SizedBox(height: 10),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: (widget.isLarge
                            ? Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                            : Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )),
                    children: _buildValueSpans(widget.value),
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


class _BorderPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color color;

  _BorderPainter({
    required this.progress,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final baseWidth = 3.0;
    final pulseWidth = baseWidth + (pulse * 3);

    final paint = Paint()
      ..color = color
      ..strokeWidth = pulseWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRect(rect);

    final metric = path.computeMetrics().first;
    final extractLength = metric.length * progress;

    final animatedPath = metric.extractPath(0, extractLength);

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.color != color;
  }
}
