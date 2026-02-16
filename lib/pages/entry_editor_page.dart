import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class EntryEditorPage extends StatelessWidget {
  const EntryEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final entries = provider.entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest → oldest


    return Scaffold(
      appBar: AppBar(title: const Text("Edit Entries")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final Entry e = entries[i];
          final formattedDate = DateFormat('EEE, MMM d').format(e.date);

          return Card(
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
              onTap: () => _openEditor(context, e),
            ),
          );
        },
      ),
    );
  }

  void _openEditor(BuildContext context, Entry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EntryEditSheet(entry: entry),
    );
  }
}

class _EntryEditSheet extends StatefulWidget {
  final Entry entry;
  const _EntryEditSheet({required this.entry});

  @override
  State<_EntryEditSheet> createState() => _EntryEditSheetState();
}

class _EntryEditSheetState extends State<_EntryEditSheet> {
  late TextEditingController idController;
  late TextEditingController cashController;
  late TextEditingController hoursController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.entry.id.toString());
    cashController = TextEditingController(text: widget.entry.cash.toString());
    hoursController = TextEditingController(
      text: widget.entry.hours.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EntryProvider>();
    final entry = widget.entry;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edit Entry #${entry.id}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Cash
          TextField(
            controller: cashController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Cash",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Hours
          TextField(
            controller: hoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Hours",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Date/Time
          ElevatedButton(
            onPressed: () async {
              final newDate = await _pickDateTime(context, entry.date);
              if (newDate != null) {
                provider.updateEntryDate(entry, newDate);
              }
            },
            child: const Text("Change Date & Time"),
          ),
          const SizedBox(height: 20),

          // Save
          ElevatedButton(
            onPressed: () async {
              final newCash = double.tryParse(cashController.text);
              final newHours = double.tryParse(hoursController.text);
              if (newCash != null) provider.updateEntryCash(entry, newCash);
              if (newHours != null) provider.updateEntryHours(entry, newHours);

              // Reorder by date (newest first) and assign highest ID to newest
              await provider.renumberIds();

              // Force UI refresh
              provider.notifyListeners();

              Navigator.pop(context);
            },
            child: const Text("Save Changes"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
