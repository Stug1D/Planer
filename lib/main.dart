import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Importiere deine Datenmodelle und Screens
import '/Models/models.dart';
import 'home_screen.dart';
import 'timetable_screen.dart';
import 'lectures_screen.dart';

void main() async {
  // 1. Stellt sicher, dass die Flutter-Engine bereit ist
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive für Flutter initialisieren
  await Hive.initFlutter();

  // 3. Die vom Generator erzeugten Adapter registrieren
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(TimeTableEventAdapter());

  // 4. Die Schubladen ("Boxes") auf der Festplatte öffnen
  await Hive.openBox<TimeTableEvent>('timetable_box');
  await Hive.openBox<Task>('tasks_box');
  await Hive.openBox<Exam>('exams_box');

  runApp(const UniPlannerApp());
}

class UniPlannerApp extends StatefulWidget {
  const UniPlannerApp({super.key});

  @override
  State<UniPlannerApp> createState() => _UniPlannerAppState();
}

class _UniPlannerAppState extends State<UniPlannerApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Die drei Hauptseiten deiner App
    final List<Widget> screens = [
      HomeScreen(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
      ),
      const TimetableScreen(),
      const LecturesScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Stundenplan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Vorlesungen',
          ),
        ],
      ),
    );
  }
}