// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'calendar_event_data.dart';
import 'extensions.dart';
import 'typedefs.dart';

class EventController<T extends Object?> extends ChangeNotifier {
  /// Calendar controller to control all the events related operations like,
  /// adding event, removing event, etc.
  EventController(
      {
      /// This method will provide list of events on particular date.
      ///
      /// This method is use full when you have recurring events.
      /// As of now this library does not support recurring events.
      /// You can implement same behaviour in this function.
      /// This function will overwrite default behaviour of [getEventsOnDay]
      /// function which will be used to display events on given day in
      /// [MonthView], [DayView] and [WeekView].
      ///
      EventFilter<T>? eventFilter,
      bool expandFullDayEvents = false})
      : _eventFilter = eventFilter,
        _expandFullDayEvents = expandFullDayEvents;

  //#region Private Fields
  EventFilter<T>? _eventFilter;
  final bool _expandFullDayEvents;

  // Store all calendar event data
  final CalendarData<T> _calendarData = CalendarData();

  //#endregion

  //#region Public Fields

  // Note: Do not use this getter inside of EventController class.
  // use _eventList instead.
  /// Returns list of [CalendarEventData<T>] stored in this controller.
  List<CalendarEventData<T>> get events =>
      _calendarData.daysOfEvent.keys.toList(growable: false);

  /// This method will provide list of events on particular date.
  ///
  /// This method is use full when you have recurring events.
  /// As of now this library does not support recurring events.
  /// You can implement same behaviour in this function.
  /// This function will overwrite default behaviour of [getEventsOnDay]
  /// function which will be used to display events on given day in
  /// [MonthView], [DayView] and [WeekView].
  ///
  EventFilter<T>? get eventFilter => _eventFilter;

  //#endregion

  //#region Public Methods
  /// Add all the events in the list
  /// If there is an event with same date then
  void addAll(List<CalendarEventData<T>> events) {
    for (final event in events) {
      _addEvent(event);
    }

    notifyListeners();
  }

  /// Adds a single event in [_events]
  void add(CalendarEventData<T> event) {
    _addEvent(event);

    notifyListeners();
  }

  /// Removes [event] from this controller.
  void remove(CalendarEventData<T> event) {
    final days = _calendarData.daysOfEvent.remove(event);
    if (days != null) {
      for (final day in days) {
        _calendarData.events[day]?.remove(event);
        _calendarData.fullDayEvents[day]?.remove(event);
      }
      notifyListeners();
    }
  }

  /// Removes multiple [event] from this controller.
  void removeWhere(bool Function(CalendarEventData<T> element) test) {
    final eventsToRemove = <CalendarEventData<T>>[];
    for (final entry in _calendarData.daysOfEvent.entries) {
      final event = entry.key;
      if (test(event)) {
        eventsToRemove.add(event);
        final days = entry.value;
        for (final day in days) {
          _calendarData.events[day]?.remove(event);
          _calendarData.fullDayEvents[day]?.remove(event);
        }
      }
    }
    for (final event in eventsToRemove) {
      _calendarData.daysOfEvent.remove(event);
    }
    notifyListeners();
  }

  /// Returns events on given day.
  ///
  /// To overwrite default behaviour of this function,
  /// provide [_eventFilter] argument in [EventController] constructor.
  List<CalendarEventData<T>> getEventsOnDay(DateTime date) {
    final events = _expandFullDayEvents
        ? [
            ...?_calendarData.events[date],
            ...?_calendarData.fullDayEvents[date]
          ]
        : (_calendarData.events[date] ?? []);
    return _eventFilter == null ? events : events.where(_eventFilter!).toList();
  }

  List<CalendarEventData<T>> getFullDayEvents(DateTime date) {
    if (_expandFullDayEvents) {
      return [];
    }
    final events = _calendarData.fullDayEvents[date] ?? [];
    return _eventFilter == null ? events : events.where(_eventFilter!).toList();
  }

  void updateFilter({required EventFilter<T> newFilter}) {
    if (newFilter != _eventFilter) {
      _eventFilter = newFilter;
      notifyListeners();
    }
  }

  //#endregion

  //#region Private Methods
  void _addEvent(CalendarEventData<T> event) {
    assert(event.endDate.difference(event.date).inDays >= 0,
        'The end date must be greater or equal to the start date');
    if (_calendarData.daysOfEvent.containsKey(event)) return;

    var dayDifference = event.endDate.difference(event.date).inDays;
    if (!event.endTime.isDayStart) {
      dayDifference++;
    }
    final days = <DateTime>[];
    for (var dayOffset = 0; dayOffset < dayDifference; dayOffset++) {
      final date = DateTime(
          event.date.year, event.date.month, event.date.day + dayOffset);
      days.add(date);

      final isFullDay = !event.startTime.isAfter(date) &&
          !event.endTime.isBefore(date.copyFromMinutes(Duration.minutesPerDay));
      final map =
          isFullDay ? _calendarData.fullDayEvents : _calendarData.events;

      if (map[date] == null) {
        map.addAll({
          date: [event],
        });
      } else {
        map[date]!.add(event);
      }
    }
    _calendarData.daysOfEvent[event] = days;

    notifyListeners();
  }

//#endregion
}

class CalendarData<T> {
  final events = <DateTime, List<CalendarEventData<T>>>{};
  final fullDayEvents = <DateTime, List<CalendarEventData<T>>>{};

  final daysOfEvent = <CalendarEventData<T>, List<DateTime>>{};
}
