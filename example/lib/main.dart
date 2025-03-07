import 'package:flutter/material.dart';
import 'package:availability_scheduling/availability_scheduling.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AvailabilitySchedulingExample(),
    );
  }
}

class AvailabilitySchedulingExample extends StatefulWidget {
  const AvailabilitySchedulingExample({super.key});

  @override
  _AvailabilitySchedulingExampleState createState() =>
      _AvailabilitySchedulingExampleState();
}

class _AvailabilitySchedulingExampleState
    extends State<AvailabilitySchedulingExample> {
  List<Event> _events = [
    Event(
      day: 'Mon',
      title: 'Team Meeting\n9:00 – 10:00',
      startTime: DateTime(2025, 3, 3, 9, 0),
      endTime: DateTime(2025, 3, 3, 10, 0),
      color: Colors.green,
    ),
    Event(
      day: 'Wed',
      title: 'Lunch Break\n12:00 – 13:00',
      startTime: DateTime(2025, 3, 5, 12, 0),
      endTime: DateTime(2025, 3, 5, 13, 0),
      color: Colors.red,
    ),
  ];

  void _printEvents() {
    print('Current Schedule Events:');
    for (var event in _events) {
      print(
          'Day: ${event.day}, Title: ${event.title}, Start: ${event.startTime}, End: ${event.endTime}, Color: ${event.color}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeeklySchedule(
        initialEvents: _events,
        halfHourHeight: 30.0,
        dayWidth: 120.0,
        onEventsUpdated: (updatedEvents) {
          setState(() {
            _events = updatedEvents;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _printEvents,
        tooltip: 'Print Events',
        child: const Icon(Icons.print),
      ),
    );
  }
}
