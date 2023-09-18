// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of 'event_arrangers.dart';

class MergeEventArranger<T extends Object?> extends EventArranger<T> {
  /// This class will provide method that will merge all the simultaneous
  /// events. and that will act like one single event.
  /// [OrganizedCalendarEventData.events] will gives
  /// list of all the combined events.
  const MergeEventArranger();

  @override
  List<OrganizedCalendarEventData<T>> arrange({
    required DateTime day,
    required List<CalendarEventData<T>> events,
    required double height,
    required double width,
    required double heightPerMinute,
  }) {
    final arrangedEvents = <OrganizedCalendarEventData<T>>[];

    final timedEvents = events
        .where((event) => event.startTime != null && event.endTime != null)
        .toList()
      ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

    for (final event in timedEvents) {
      final startTime = event.startTime!;
      final endTime = event.endTime!;

      final eventStart =
          DateUtils.isSameDay(day, startTime) ? startTime.getTotalMinutes : 0;
      final eventEnd = DateUtils.isSameDay(day, endTime)
          ? endTime.getTotalMinutes
          : Duration.minutesPerDay;

      var isOverlapping = false;
      if (arrangedEvents.isNotEmpty) {
        final lastArrangedEvent = arrangedEvents[arrangedEvents.length - 1];
        final arrangedEventStart =
            lastArrangedEvent.startDuration.getTotalMinutes;
        final arrangedEventEnd =
            lastArrangedEvent.endDuration.getTotalMinutes == 0
                ? Duration.minutesPerDay
                : lastArrangedEvent.endDuration.getTotalMinutes;

        isOverlapping = _isOverlapping(
            arrangedEventStart, arrangedEventEnd, eventStart, eventEnd);
        if (isOverlapping) {
          final startDuration = min(eventStart, arrangedEventStart);
          final endDuration = max(eventEnd, arrangedEventEnd);

          final top = startDuration * heightPerMinute;
          final bottom = endDuration * heightPerMinute == height
              ? 0.0
              : height - endDuration * heightPerMinute;

          final newEvent = OrganizedCalendarEventData<T>(
            top: top,
            bottom: bottom,
            left: 0,
            right: 0,
            startDuration: day.copyFromMinutes(startDuration),
            endDuration: day.copyFromMinutes(endDuration),
            events: lastArrangedEvent.events..add(event),
          );

          arrangedEvents[arrangedEvents.length - 1] = newEvent;
        }
      }

      if (!isOverlapping) {
        final top = eventStart * heightPerMinute;
        final bottom = eventEnd * heightPerMinute == height
            ? 0.0
            : height - eventEnd * heightPerMinute;

        final newEvent = OrganizedCalendarEventData<T>(
          top: top,
          bottom: bottom,
          left: 0,
          right: 0,
          startDuration: day.copyFromMinutes(eventStart),
          endDuration: day.copyFromMinutes(eventEnd),
          events: [event],
        );

        arrangedEvents.add(newEvent);
      }
    }

    return arrangedEvents;
  }

  bool _isOverlapping(int arrangedEventStart, int arrangedEventEnd,
      int eventStart, int eventEnd) {
    return (arrangedEventStart >= eventStart &&
            arrangedEventStart <= eventEnd) ||
        (arrangedEventEnd >= eventStart && arrangedEventEnd <= eventEnd) ||
        (eventStart >= arrangedEventStart && eventStart <= arrangedEventEnd) ||
        (eventEnd >= arrangedEventStart && eventEnd <= arrangedEventEnd);
  }
}
