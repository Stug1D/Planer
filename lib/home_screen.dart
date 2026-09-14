import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/Models/models.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Zugriff auf die in main.dart geöffneten Hive-Boxen
  final Box<Task> _taskBox = Hive.box<Task>('tasks_box');
  final Box<Exam> _examBox = Hive.box<Exam>('exams_box');

  bool _showAllTasks = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _examController = TextEditingController();

  // Theme-bewusste Hilfsfunktion für gut lesbare Warnfarben
  Color _getExamColor(
    DateTime examDate,
    Color defaultColor,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);

    final daysLeft = examDay.difference(today).inDays;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (daysLeft <= 10) {
      return isDark ? const Color(0xFF4A1515) : Colors.red.shade100;
    } else if (daysLeft <= 30) {
      return isDark ? const Color(0xFF4A3B15) : Colors.yellow.shade100;
    }
    return defaultColor;
  }

  // NEUE AUFGABE HINZUFÜGEN
  void _showAddTaskDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final formattedTime =
                '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}';

            return AlertDialog(
              title: const Text('Neue Aufgabe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Titel der Aufgabe',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Frist: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year} um $formattedTime Uhr',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            if (!context.mounted) return;
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );

                            setDialogState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime?.hour ?? selectedDate.hour,
                                pickedTime?.minute ?? selectedDate.minute,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      // Speichern in Hive!
                      _taskBox.add(
                        Task(
                          title: _taskController.text,
                          dueDate: selectedDate,
                        ),
                      );
                      _taskController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // NEUE KLAUSUR HINZUFÜGEN
  void _showAddExamDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final formattedTime =
                '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}';

            return AlertDialog(
              title: const Text('Neue Klausur'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _examController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Modulname (z. B. Mathe 1)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Datum: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year} um $formattedTime Uhr',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            if (!context.mounted) return;
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );

                            setDialogState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime?.hour ?? selectedDate.hour,
                                pickedTime?.minute ?? selectedDate.minute,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _examController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_examController.text.isNotEmpty) {
                      // Speichern in Hive!
                      _examBox.add(
                        Exam(
                          module: _examController.text,
                          date: selectedDate,
                        ),
                      );
                      _examController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _hasTaskOnDay(DateTime day, List<Task> tasks) {
    return tasks.any(
      (t) =>
          !t.isCompleted &&
          t.dueDate.year == day.year &&
          t.dueDate.month == day.month &&
          t.dueDate.day == day.day,
    );
  }

  bool _hasExamOnDay(DateTime day, List<Exam> exams) {
    return exams.any(
      (e) =>
          !e.isCompleted &&
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[200]!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit App-Titel & Darkmode Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uni Planner',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  onPressed: widget.onToggleTheme,
                  tooltip: 'Theme umschalten',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kalender mit Hive-Daten
            ValueListenableBuilder(
              valueListenable: _taskBox.listenable(),
              builder: (context, Box<Task> taskBox, _) {
                return ValueListenableBuilder(
                  valueListenable: _examBox.listenable(),
                  builder: (context, Box<Exam> examBox, _) {
                    final currentTasks = taskBox.values.toList();
                    final currentExams = examBox.values.toList();

                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            outsideDaysVisible: false,
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              final hasTask =
                                  _hasTaskOnDay(date, currentTasks);
                              final hasExam =
                                  _hasExamOnDay(date, currentExams);

                              if (!hasTask && !hasExam) {
                                return const SizedBox();
                              }

                              return Positioned(
                                bottom: 6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (hasTask)
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1.5,
                                        ),
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.blueAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (hasExam)
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1.5,
                                        ),
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Bereich 1: Aufgaben (Hive ValueListenableBuilder)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Deine Aufgaben',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _showAddTaskDialog,
                  tooltip: 'Aufgabe hinzufügen',
                ),
              ],
            ),
            const SizedBox(height: 8),

            ValueListenableBuilder<Box<Task>>(
              valueListenable: _taskBox.listenable(),
              builder: (context, box, _) {
                final tasks = box.values.toList();

                // Sortierung
                tasks.sort((a, b) {
                  if (a.isCompleted != b.isCompleted) {
                    return a.isCompleted ? 1 : -1;
                  }
                  return a.dueDate.compareTo(b.dueDate);
                });

                if (tasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Keine Aufgaben vorhanden.'),
                  );
                }

                final displayedTasks =
                    _showAllTasks ? tasks : tasks.take(5).toList();

                return Column(
                  children: [
                    for (var task in displayedTasks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          tileColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                task.isCompleted ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            'Frist: ${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year} um ${task.formattedTime} Uhr',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.grey),
                            onPressed: () => task.delete(), // Aus Hive löschen!
                          ),
                          onTap: () {
                            task.isCompleted = !task.isCompleted;
                            task.save(); // Änderung in Hive speichern!
                          },
                        ),
                      ),
                    if (tasks.length > 5)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllTasks = !_showAllTasks;
                          });
                        },
                        icon: Icon(
                          _showAllTasks
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        label: Text(
                          _showAllTasks
                              ? 'Weniger anzeigen'
                              : 'Alle ${tasks.length} Aufgaben anzeigen',
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Bereich 2: Klausuren (Hive ValueListenableBuilder)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Anstehende Klausuren',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.red),
                  onPressed: _showAddExamDialog,
                  tooltip: 'Klausur hinzufügen',
                ),
              ],
            ),
            const SizedBox(height: 8),

            ValueListenableBuilder<Box<Exam>>(
              valueListenable: _examBox.listenable(),
              builder: (context, box, _) {
                final exams = box.values.toList();

                // Sortierung
                exams.sort((a, b) {
                  if (a.isCompleted != b.isCompleted) {
                    return a.isCompleted ? 1 : -1;
                  }
                  return a.date.compareTo(b.date);
                });

                if (exams.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Keine Klausuren eingetragen.'),
                  );
                }

                return Column(
                  children: [
                    for (var exam in exams)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          tileColor: exam.isCompleted
                              ? cardColor
                              : _getExamColor(exam.date, cardColor, context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: Icon(
                            exam.isCompleted
                                ? Icons.check_circle
                                : Icons.school,
                            color:
                                exam.isCompleted ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            exam.module,
                            style: TextStyle(
                              decoration: exam.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            'Datum: ${exam.date.day}.${exam.date.month}.${exam.date.year} um ${exam.formattedTime} Uhr - Tage bis zur Klausur: ${exam.date.difference(DateTime.now()).inDays}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.grey),
                            onPressed: () => exam.delete(), // Aus Hive löschen!
                          ),
                          onTap: () {
                            exam.isCompleted = !exam.isCompleted;
                            exam.save(); // Änderung in Hive speichern!
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}