import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/Models/models.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Box<TimeTableEvent> _timetableBox = Hive.box<TimeTableEvent>('timetable_box');
  final TextEditingController _titleController = TextEditingController();

  // Dialog zum Hinzufügen von Terminen
  void _showAddEventDialog({required bool isWeekly}) async {
    DateTime selectedStart = DateTime.now();
    DateTime selectedEnd = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isWeekly ? 'Neuer Serientermin' : 'Einmaliger Termin'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titel (z. B. Mathe 1)'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('Start: ${selectedStart.day}.${selectedStart.month}.${selectedStart.year} ${selectedStart.hour}:${selectedStart.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedStart,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedStart),
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedStart = DateTime(
                              date.year, date.month, date.day, time.hour, time.minute);
                            selectedEnd = selectedStart.add(const Duration(hours: 2));
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      // In Hive speichern
                      _timetableBox.add(
                        TimeTableEvent(
                          title: _titleController.text,
                          startTime: selectedStart,
                          endTime: selectedEnd,
                          colorValue: Colors.deepPurple.value,
                          isWeekly: isWeekly,
                        ),
                      );
                      _titleController.clear();
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

  @override
  Widget build(BuildContext context) {
    // Falls Scaffold in main.dart vorhanden ist, reicht hier eine SafeArea / Column
    return SafeArea(
      child: Column(
        children: [
          // BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEventDialog(isWeekly: true),
                    icon: const Icon(Icons.repeat, size: 18),
                    label: const Text('Serientermin'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEventDialog(isWeekly: false),
                    icon: const Icon(Icons.event, size: 18),
                    label: const Text('Einmalig'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // KALENDER MIT HIVE-ANBINDUNG
          Expanded(
            child: ValueListenableBuilder<Box<TimeTableEvent>>(
              valueListenable: _timetableBox.listenable(),
              builder: (context, box, _) {
                final appointments = box.values.map((e) {
                  return Appointment(
                    startTime: e.startTime,
                    endTime: e.endTime,
                    subject: e.title,
                    color: e.color,
                    recurrenceRule: e.isWeekly ? 'FREQ=WEEKLY' : null, // Regelmäßige Wiederholung
                  );
                }).toList();

                return SfCalendar(
                  view: CalendarView.week,
                  firstDayOfWeek: DateTime.monday,
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 6,
                    endHour: 20,
                    timeIntervalHeight: 60,
                  ),
                  dataSource: MeetingDataSource(appointments),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}