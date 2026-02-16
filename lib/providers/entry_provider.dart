import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/entry.dart';

class EntryProvider extends ChangeNotifier {
  late Box<Entry> _box;
  late Box _settingsBox;

  List<Entry> get entries => _box.values.toList();

  Future<void> init() async {
    _box = Hive.box<Entry>('entries');
    _settingsBox = Hive.box('app_settings');
    notifyListeners();
  }

  // -----------------------------
  // Persisted Today's Average
  // -----------------------------

  double get todaySavedAverage {
    final savedDate = _settingsBox.get('today_average_date');
    final today = DateTime.now();

    if (savedDate is DateTime &&
        savedDate.year == today.year &&
        savedDate.month == today.month &&
        savedDate.day == today.day) {
      return _settingsBox.get('today_average', defaultValue: 0.0);
    }

    return 0.0;
  }

  void saveTodayAverage(double avg) {
    final today = DateTime.now();
    _settingsBox.put('today_average', avg);
    _settingsBox.put('today_average_date', today);
    notifyListeners();
  }

  // -----------------------------
  // Entry CRUD
  // -----------------------------

  void addEntry(double cash, double hours) {
    final entry = Entry(
      id: _box.length + 1,
      date: DateTime.now(),
      cash: cash,
      hours: hours,
    );

    _box.add(entry);
    notifyListeners();
  }

  void deleteEntry(Entry entry) {
    entry.delete();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _box.clear();
    notifyListeners();
  }

  void updateEntryDate(Entry entry, DateTime newDate) {
    entry.date = newDate;
    entry.save();
    notifyListeners();
  }

  void updateEntryCash(Entry entry, double newCash) {
    entry.cash = newCash;
    entry.save();
    notifyListeners();
  }

  void updateEntryHours(Entry entry, double newHours) {
    entry.hours = newHours;
    entry.save();
    notifyListeners();
  }

  Future<void> renumberIds() async {
    final list = _box.values.toList();

    // Sort by date (newest → oldest)
    list.sort((a, b) => b.date.compareTo(a.date));

    // Highest ID goes to the first (newest) entry
    for (int i = 0; i < list.length; i++) {
      list[i].id = list.length - i;
      await list[i].save();
    }

    notifyListeners();
  }




  // -----------------------------
  // Stats Helpers
  // -----------------------------

  List<Entry> get todayEntries => entries
      .where(
        (e) =>
            e.date.year == DateTime.now().year &&
            e.date.month == DateTime.now().month &&
            e.date.day == DateTime.now().day,
      )
      .toList();

  List<Entry> get weekEntries {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return entries.where((e) => e.date.isAfter(weekStart)).toList();
  }

  List<Entry> get monthEntries => entries
      .where(
        (e) =>
            e.date.year == DateTime.now().year &&
            e.date.month == DateTime.now().month,
      )
      .toList();

  double sum(List<Entry> list) => list.fold(0, (sum, e) => sum + e.cash);

  double avg(List<Entry> list) => list.isEmpty ? 0 : sum(list) / list.length;
}
