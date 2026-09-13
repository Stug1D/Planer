import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Wochenplan'),
      centerTitle: true,
    ),
    body: Column(
      children: [
        // --- BUTTONS BEREICH ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // 1. Knopf: Regelmäßiger Termin
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Dialog für regelmäßigen Termin öffnen
                  },
                  icon: const Icon(Icons.repeat, size: 18),
                  label: const Text('Serientermin'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 2. Knopf: Einmaliger Termin
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Dialog für einmaligen Termin öffnen
                  },
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

        // --- KALENDER (Muss in Expanded stehen!) ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            firstDayOfWeek: DateTime.monday, // Startet die Woche mit Montag
            timeSlotViewSettings: const TimeSlotViewSettings(
              startHour: 6,
              endHour: 20,
              timeIntervalHeight: 60,
            ),
            dataSource: MeetingDataSource(_getTimetableData()),
          ),
        ),
      ],
    ),
  );
}

  // Beispieldaten für Vorlesungen mit Start- und Endzeit
  List<Appointment> _getTimetableData() {
    final List<Appointment> meetings = <Appointment>[];
    final DateTime today = DateTime.now();

    meetings.add(
      Appointment(
        startTime: DateTime(today.year, today.month, today.day, 10, 0), // 10:00 Uhr
        endTime: DateTime(today.year, today.month, today.day, 12, 0),   // 12:00 Uhr
        subject: 'Mathematik 1',
        color: Colors.deepPurple,
      ),
    );

    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}