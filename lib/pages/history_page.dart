import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();

    // Newest entries first
    final entries = provider.entries.toList()
  ..sort((a, b) => b.date.compareTo(a.date));


    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final Entry e = entries[i];

        // Format: Sat, Feb 14
        final formattedDate = DateFormat('EEE, MMM d').format(e.date);

        return Dismissible(
          key: ValueKey(e.key),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            provider.deleteEntry(e);
          },
          child: Card(
            elevation: 1,
            child: ListTile(
              title: Text(
                "#${e.id}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  children: [
                    TextSpan(text: "$formattedDate\n"),
                    const TextSpan(text: "Cash: "),
                    TextSpan(
                      text: "\$${e.cash}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    const TextSpan(text: " | Hours: "),
                    TextSpan(
                      text: "${e.hours}",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),

              trailing: Text(
                "\$${e.average.toStringAsFixed(2)}/hr",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
