# availability_scheduling

A Flutter widget for creating and managing a weekly availability schedule with drag-and-drop functionality.

[![Pub Version](https://img.shields.io/pub/v/availability_scheduling)](https://pub.dev/packages/availability_scheduling)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<img src="https://github.com/user-attachments/assets/54fa180c-6293-4f29-bf1a-dc813a841d08" style="width:50%; height:50%;">

The `availability_scheduling` package provides a customizable weekly schedule widget for Flutter applications. Users can visualize, create, edit, and move availability events across a 7-day grid with half-hour time slots. It’s ideal for applications requiring time management, such as booking systems, personal planners, or availability trackers.

---

## Features

- **Weekly Grid View**: Displays a 7-day schedule (Monday to Sunday) with half-hour increments.
- **Drag-and-Drop**: Create new events by dragging on the grid or move existing events to new time slots.
- **Event Editing**: Tap an event to edit its title, time, or availability status via a dialog.
- **Availability Indicators**: Mark events as "Available" (green) or "Unavailable" (red).
- **Customizable Layout**: Adjust the height of time slots and width of day columns.
- **Overlap Prevention**: Automatically prevents overlapping events on the same day.
- **Smooth Scrolling**: Synchronized horizontal and vertical scrolling for a seamless experience.

---

## Installation

Add the `availability_scheduling` package to your `pubspec.yaml`:

```yaml
dependencies:
  availability_scheduling: ^1.0.0
Then, run the following command to fetch the package:
flutter pub get
Alternatively, if you’re using a specific version or a local path during development:
dependencies:
  availability_scheduling:
    path: ../availability_scheduling
Usage
Import the package in your Dart file:
import 'package:availability_scheduling/availability_scheduling.dart';
Add the WeeklySchedule widget to your app, optionally providing initial events:
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const WeeklySchedule(
        initialEvents: [
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
        ],
        halfHourHeight: 30.0,
        dayWidth: 120.0,
      ),
    );
  }
}
