import 'package:flutter/material.dart';

class Event {
  String day;
  String title;
  DateTime startTime;
  DateTime endTime;
  Color color;

  Event({
    required this.day,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

class EventBlock extends StatelessWidget {
  final Event event;
  final double height;

  const EventBlock({super.key, required this.event, required this.height});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
