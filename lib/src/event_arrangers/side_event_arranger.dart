// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of 'event_arrangers.dart';

class SideEventArranger<T extends Object?> extends EventArranger<T> {
  /// This class will provide method that will arrange
  /// all the events side by side.

  final Map<DateTime, List<CalendarEventData<T>>> _additionalEventMap;

  SideEventArranger({List<CalendarEventData<T>>? additionalEvents})
      : _additionalEventMap = additionalEvents
                ?.fold<Map<DateTime, List<CalendarEventData<T>>>>({},
                    (map, event) {
              final startDay = event.startTime.withoutTime;
              final dayDifference =
                  event.endTime.getDayDifference(event.startTime);
              for (var i = 0; i <= dayDifference; i++) {
                final day = startDay.add(Duration(days: i));
                map[day] = (map[day]?..add(event)) ?? [event];
              }
              return map;
            }) ??
            {};

  @override
  List<OrganizedCalendarEventData<T>> arrange({
    required DateTime day,
    required List<CalendarEventData<T>> events,
    required double height,
    required double width,
    required double heightPerMinute,
  }) {
    final additionalEvents = _additionalEventMap[day];

    final mergedEvents =
        MergeEventArranger<T>(mergeBackToBackEvents: false).arrange(
      day: day,
      events: additionalEvents == null ? events : events
        ..addAll(additionalEvents!),
      height: height,
      width: width,
      heightPerMinute: heightPerMinute,
    );

    final arrangedEvents = <OrganizedCalendarEventData<T>>[];

    for (final mergedEvent in mergedEvents) {
      final concurrentEvents = mergedEvent.events;
      if (concurrentEvents.isEmpty) {
        continue;
      }
      if (concurrentEvents.length == 1) {
        arrangedEvents.add(mergedEvent);
        continue;
      }

      final columns = <List<_SideEventData<T>>>[];

      for (final event in concurrentEvents) {
        final startTime = event.startTime;
        final endTime = event.endTime;
        final eventStart =
            DateUtils.isSameDay(day, startTime) ? startTime.getTotalMinutes : 0;
        final eventEnd = DateUtils.isSameDay(day, endTime)
            ? endTime.getTotalMinutes
            : Constants.minutesADay;
        final sideEvent =
            _SideEventData(start: eventStart, end: eventEnd, event: event);

        var column = columns.indexWhere((sideEvents) => sideEvents
            .every((otherSideEvent) => !otherSideEvent.overlaps(sideEvent)));
        if (column == -1) {
          column = columns.length;
          columns.add([sideEvent]);
        } else {
          columns[column].add(sideEvent);
        }
      }

      final slotWidth = width / columns.length;

      for (var column = 0; column < columns.length; column++) {
        final sideEvents = columns[column];
        for (final sideEvent in sideEvents) {
          final top = sideEvent.start * heightPerMinute;
          final bottom = sideEvent.end * heightPerMinute == height
              ? 0.0
              : height - sideEvent.end * heightPerMinute;

          arrangedEvents.add(OrganizedCalendarEventData<T>(
            left: slotWidth * column,
            right: slotWidth * (columns.length - (column + 1)),
            top: top,
            bottom: bottom,
            startDuration: day.copyFromMinutes(sideEvent.start),
            endDuration: day.copyFromMinutes(sideEvent.end),
            events: [sideEvent.event],
          ));
        }
      }
    }

    return arrangedEvents;
  }
}

class _SideEventData<T> {
  final int start;
  final int end;
  final CalendarEventData<T> event;

  const _SideEventData({
    required this.start,
    required this.end,
    required this.event,
  });

  bool overlaps(_SideEventData other) {
    return (start >= other.start && start < other.end) ||
        (end > other.start && end <= other.end) ||
        (other.start >= start && other.start < end) ||
        (other.end > start && other.end <= end);
  }
}
