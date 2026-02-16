import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final cashController = TextEditingController();
  final hoursController = TextEditingController();

  double average = 0;

  @override
  void initState() {
    super.initState();

    // Load persisted average for today
    final provider = Provider.of<EntryProvider>(context, listen: false);
    average = provider.todaySavedAverage;

    // Update button state when typing
    cashController.addListener(() => setState(() {}));
    hoursController.addListener(() => setState(() {}));
  }

  // Form validation
  bool get isFormValid {
    final cash = double.tryParse(cashController.text.trim());
    final hours = double.tryParse(hoursController.text.trim());
    return cash != null && cash > 0 && hours != null && hours > 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Enter tips & hours",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: cashController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Cash Earned",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: hoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Hours Worked",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: FilledButton(
              onPressed: isFormValid
                  ? () {
                      final cash = double.parse(cashController.text.trim());
                      final hours = double.parse(hoursController.text.trim());

                      final newAverage = cash / hours;

                      setState(() {
                        average = newAverage;
                      });

                      final provider =
                          Provider.of<EntryProvider>(context, listen: false);

                      provider.addEntry(cash, hours);
                      provider.saveTodayAverage(newAverage);

                      cashController.clear();
                      hoursController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  : null,
              child: const Text("Save Entry"),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                Text(
                  "Today's Average",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${average.toStringAsFixed(2)}/hr",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 85, 212, 0),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
