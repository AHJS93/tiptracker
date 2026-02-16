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
    final entries = provider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Entry Timestamps"),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final Entry e = entries[i];
          final formatted = DateFormat('yyyy-MM-dd  HH:mm').format(e.date);

          return ListTile(
            title: Text("Entry #${e.id}"),
            subtitle: Text("Current: $formatted"),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final newDate = await _pickDateTime(context, e.date);
              if (newDate != null) {
                provider.updateEntryDate(e, newDate);
              }
            },
          );
        },
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
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

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
