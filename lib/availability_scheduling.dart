library availability_scheduling;

import 'package:flutter/material.dart';
import 'src/event.dart';

export 'src/event.dart' show Event;

class WeeklySchedule extends StatefulWidget {
  final List<Event> initialEvents;
  final double halfHourHeight;
  final double dayWidth;
  final ValueChanged<List<Event>>? onEventsUpdated;

  const WeeklySchedule({
    super.key,
    this.initialEvents = const [],
    this.halfHourHeight = 30.0,
    this.dayWidth = 120.0,
    this.onEventsUpdated,
  });

  @override
  _WeeklyScheduleState createState() => _WeeklyScheduleState();
}

class _WeeklyScheduleState extends State<WeeklySchedule> {
  late List<Event> events;
  double? dragStartY;
  double? dragEndY;
  String? selectedDay;
  Event? draggedEvent;
  DateTime? originalStartTime;
  DateTime? originalEndTime;

  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final int halfHoursPerDay = 48;

  late ScrollController _headerScrollController;
  late ScrollController _gridScrollController;
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    events = List.from(widget.initialEvents);
    _headerScrollController = ScrollController();
    _gridScrollController = ScrollController();
    _verticalScrollController = ScrollController();

    // Synchronize header and grid scrolling
    _headerScrollController.addListener(() {
      if (_headerScrollController.hasClients && _gridScrollController.hasClients) {
        if (_gridScrollController.offset != _headerScrollController.offset) {
          _gridScrollController.jumpTo(_headerScrollController.offset);
        }
      }
    });
    _gridScrollController.addListener(() {
      if (_gridScrollController.hasClients && _headerScrollController.hasClients) {
        if (_headerScrollController.offset != _gridScrollController.offset) {
          _headerScrollController.jumpTo(_gridScrollController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _gridScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  bool _checkOverlap(Event draggedEvent, String day) {
    for (var event in events.where((e) => e.day == day && e != draggedEvent)) {
      if (draggedEvent.startTime.isBefore(event.endTime) &&
          draggedEvent.endTime.isAfter(event.startTime)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final totalGridHeight = halfHoursPerDay * widget.halfHourHeight;
    final availableWidth = MediaQuery.of(context).size.width - 60;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Weekly Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                events.clear();
                widget.onEventsUpdated?.call(events);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const SizedBox(width: 60),
                SizedBox(
                  width: availableWidth,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _headerScrollController,
                    physics: const FastScrollPhysics(),
                    child: Row(
                      children: weekdays.map((day) => Container(
                        width: widget.dayWidth,
                        height: 50,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: totalGridHeight,
                    width: 60,
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: halfHoursPerDay,
                      itemBuilder: (context, index) {
                        final hour = index ~/ 2;
                        final halfHour = index % 2 == 0 ? '00' : '30';
                        return Container(
                          height: widget.halfHourHeight,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '$hour:$halfHour',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: availableWidth,
                    height: totalGridHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _gridScrollController,
                      physics: const FastScrollPhysics(),
                      child: Row(
                        children: weekdays.map((day) {
                          return Container(
                            width: widget.dayWidth,
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.grey[300]!)),
                            ),
                            child: GestureDetector(
                              onVerticalDragStart: (details) {
                                setState(() {
                                  dragStartY = details.localPosition.dy;
                                  dragEndY = dragStartY;
                                  selectedDay = day;
                                  draggedEvent = null;
                                  for (var event in events.where((e) => e.day == day)) {
                                    double top = _calculateTopOffset(event.startTime);
                                    double height = _calculateHeight(event.startTime, event.endTime);
                                    if (dragStartY! >= top && dragStartY! <= top + height) {
                                      draggedEvent = event;
                                      originalStartTime = event.startTime;
                                      originalEndTime = event.endTime;
                                      break;
                                    }
                                  }
                                });
                              },
                              onVerticalDragUpdate: (details) {
                                setState(() {
                                  if (selectedDay == day) {
                                    dragEndY = details.localPosition.dy.clamp(0.0, halfHoursPerDay * widget.halfHourHeight);

                                    if (draggedEvent != null) {
                                      double delta = dragEndY! - dragStartY!;
                                      int halfHourDelta = (delta / widget.halfHourHeight).round();
                                      DateTime newStartTime = originalStartTime!.add(Duration(minutes: halfHourDelta * 30));
                                      DateTime newEndTime = originalEndTime!.add(Duration(minutes: halfHourDelta * 30));

                                      if (newStartTime.hour >= 0 && newEndTime.hour < 24) {
                                        draggedEvent!.startTime = newStartTime;
                                        draggedEvent!.endTime = newEndTime;
                                        if (!_checkOverlap(draggedEvent!, day)) {
                                          final startHour = newStartTime.hour;
                                          final startMinute = newStartTime.minute.toString().padLeft(2, '0');
                                          final endHour = newEndTime.hour;
                                          final endMinute = newEndTime.minute.toString().padLeft(2, '0');
                                          draggedEvent!.title = '${draggedEvent!.title.split('\n')[0]}\n$startHour:$startMinute – $endHour:$endMinute';
                                        } else {
                                          draggedEvent!.startTime = originalStartTime!;
                                          draggedEvent!.endTime = originalEndTime!;
                                        }
                                        widget.onEventsUpdated?.call(events);
                                      }
                                    }
                                  }
                                });
                              },
                              onVerticalDragEnd: (details) {
                                if (draggedEvent != null) {
                                  setState(() {
                                    dragStartY = null;
                                    dragEndY = null;
                                    selectedDay = null;
                                    draggedEvent = null;
                                    originalStartTime = null;
                                    originalEndTime = null;
                                    widget.onEventsUpdated?.call(events);
                                  });
                                } else if (dragStartY != null && dragEndY != null && selectedDay == day) {
                                  _showEventDialog(day, null);
                                }
                              },
                              child: Container(
                                height: totalGridHeight,
                                width: widget.dayWidth,
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    ...List.generate(halfHoursPerDay, (index) => Positioned(
                                      top: index * widget.halfHourHeight,
                                      left: 0,
                                      right: 0,
                                      child: Divider(height: 1, color: Colors.grey[200]),
                                    )),
                                    ...events.where((e) => e.day == day).map((event) {
                                      double top = _calculateTopOffset(event.startTime);
                                      double height = _calculateHeight(event.startTime, event.endTime);
                                      return Positioned(
                                        top: top,
                                        left: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _showEventDialog(day, event),
                                          child: EventBlock(event: event, height: height),
                                        ),
                                      );
                                    }),
                                    if (dragStartY != null && dragEndY != null && selectedDay == day && draggedEvent == null)
                                      Positioned(
                                        top: dragEndY! < dragStartY! ? dragEndY : dragStartY,
                                        left: 4,
                                        right: 4,
                                        height: (dragEndY! - dragStartY!).abs(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTopOffset(DateTime startTime) {
    return (startTime.hour * 2 + startTime.minute / 30) * widget.halfHourHeight;
  }

  double _calculateHeight(DateTime startTime, DateTime endTime) {
    final durationInMinutes = endTime.difference(startTime).inMinutes;
    return (durationInMinutes / 30.0) * widget.halfHourHeight;
  }

  void _showEventDialog(String day, Event? event) {
    final isEditing = event != null;
    late int startHalfHour;
    late int endHalfHour;

    if (isEditing) {
      startHalfHour = (event!.startTime.hour * 2 + event!.startTime.minute ~/ 30);
      endHalfHour = (event!.endTime.hour * 2 + event!.endTime.minute ~/ 30);
    } else {
      final startPos = dragStartY! / widget.halfHourHeight;
      final endPos = dragEndY! / widget.halfHourHeight;
      if (dragStartY! < dragEndY!) {
        startHalfHour = startPos.floor();
        endHalfHour = endPos.ceil();
      } else {
        startHalfHour = endPos.floor();
        endHalfHour = startPos.ceil();
      }
    }

    final displayStartHour = startHalfHour ~/ 2;
    final displayStartMinute = (startHalfHour % 2) * 30;
    final displayEndHour = endHalfHour ~/ 2;
    final displayEndMinute = (endHalfHour % 2) * 30;

    final eventStartHour = startHalfHour ~/ 2;
    final eventStartMinute = (startHalfHour % 2) * 30;
    final eventEndHour = endHalfHour ~/ 2;
    final eventEndMinute = (endHalfHour % 2) * 30;

    String title = isEditing ? event!.title.split('\n')[0] : '';
    TextEditingController controller = TextEditingController(text: title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Event' : 'New Event',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$day, $displayStartHour:${displayStartMinute.toString().padLeft(2, '0')} – '
                    '$displayEndHour:${displayEndMinute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Event Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (isEditing) {
                  setState(() => events.remove(event));
                }
                setState(() {
                  dragStartY = null;
                  dragEndY = null;
                  selectedDay = null;
                  widget.onEventsUpdated?.call(events);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isEditing) events.remove(event);
                      final newEvent = Event(
                        day: day,
                        title: '${controller.text}\n$displayStartHour:${displayStartMinute.toString().padLeft(2, '0')} – '
                            '$displayEndHour:${displayEndMinute.toString().padLeft(2, '0')}',
                        startTime: DateTime(2025, 3, 3, eventStartHour, eventStartMinute),
                        endTime: DateTime(2025, 3, 3, eventEndHour, eventEndMinute),
                        color: Colors.green,
                      );
                      if (!_checkOverlap(newEvent, day)) {
                        events.add(newEvent);
                      }
                      dragStartY = null;
                      dragEndY = null;
                      selectedDay = null;
                      widget.onEventsUpdated?.call(events);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Available'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isEditing) events.remove(event);
                      final newEvent = Event(
                        day: day,
                        title: '${controller.text}\n$displayStartHour:${displayStartMinute.toString().padLeft(2, '0')} – '
                            '$displayEndHour:${displayEndMinute.toString().padLeft(2, '0')}',
                        startTime: DateTime(2025, 3, 3, eventStartHour, eventStartMinute),
                        endTime: DateTime(2025, 3, 3, eventEndHour, eventEndMinute),
                        color: Colors.red,
                      );
                      if (!_checkOverlap(newEvent, day)) {
                        events.add(newEvent);
                      }
                      dragStartY = null;
                      dragEndY = null;
                      selectedDay = null;
                      widget.onEventsUpdated?.call(events);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Unavailable'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class FastScrollPhysics extends BouncingScrollPhysics {
  const FastScrollPhysics({super.parent});

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 1.5; // Matches original scrolling speed
  }

  @override
  double get dragStartDistanceMotionThreshold => 5.0; // Matches original threshold
}