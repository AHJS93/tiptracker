import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double cash;

  @HiveField(3)
  double hours;

  Entry({
    required this.id,
    required this.date,
    required this.cash,
    required this.hours,
  });

  double get average => hours == 0 ? 0 : cash / hours;
}
