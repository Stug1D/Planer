import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

// Diese Datei wird im nächsten Schritt automatisch vom Generator erstellt
part 'models.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dueDate;

  @HiveField(2)
  bool isCompleted;

  Task({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  String get formattedTime {
    final hour = dueDate.hour.toString().padLeft(2, '0');
    final minute = dueDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

@HiveType(typeId: 1)
class Exam extends HiveObject {
  @HiveField(0)
  String module;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool isCompleted;

  Exam({
    required this.module,
    required this.date,
    this.isCompleted = false,
  });

  String get formattedTime {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

@HiveType(typeId: 2)
class TimeTableEvent extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  int colorValue; // Speichert Color als Integer

  @HiveField(4)
  bool isWeekly;

  TimeTableEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    this.isWeekly = false,
  });

  Color get color => Color(colorValue);
}