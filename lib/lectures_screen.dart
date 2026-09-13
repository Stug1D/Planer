import 'package:flutter/material.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  // Liste mit deinen Fächern
  final List<String> lectures = [
    'Mathematik 1',
    'Physik',
    'Informatik',
    'Elektrotechnik',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meine Fächer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // GridView (Kacheln) muss wie ListView in ein Expanded gewickelt werden
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 Kacheln nebeneinander
                crossAxisSpacing: 12, // Abstand waagerecht zwischen Kacheln
                mainAxisSpacing: 12, // Abstand senkrecht zwischen Kacheln
                childAspectRatio: 1.2, // Seitenverhältnis der Kacheln (Breite / Höhe)
                children: [
                  for (var lecture in lectures)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // TODO: Klick auf Kachel verarbeiten
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lecture,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}