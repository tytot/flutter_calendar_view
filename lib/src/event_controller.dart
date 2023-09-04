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
  EventController({
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
  }) : _eventFilter = eventFilter;

  //#region Private Fields
  EventFilter<T>? _eventFilter;

  // Store all calendar event data
  final CalendarData<T> _calendarData = CalendarData();

  //#endregion

  //#region Public Fields

  // TODO: change the type from List<CalendarEventData>
  //  to UnmodifiableListView provided in dart:collection.

  // Note: Do not use this getter inside of EventController class.
  // use _eventList instead.
  /// Returns list of [CalendarEventData<T>] stored in this controller.
  List<CalendarEventData<T>> get events =>
      _calendarData.eventList.toList(growable: false);

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
    final date = event.date.withoutTime;

    // Removes the event from single event map.
    if (_calendarData.events[date] != null) {
      if (_calendarData.events[date]!.remove(event)) {
        final endDate = event.endDate.withoutTime;
        if (endDate.isAfter(date)) {
          _calendarData.events[endDate]?.remove(event);
        }
        _calendarData.eventList.remove(event);
        notifyListeners();
      }
    }
  }

  /// Removes multiple [event] from this controller.
  void removeWhere(bool Function(CalendarEventData<T> element) test) {
    for (final e in _calendarData.events.values) {
      e.removeWhere(test);
    }
    _calendarData.eventList.removeWhere(test);
    notifyListeners();
  }

  /// Returns events on given day.
  ///
  /// To overwrite default behaviour of this function,
  /// provide [_eventFilter] argument in [EventController] constructor.
  List<CalendarEventData<T>> getEventsOnDay(DateTime date) {
    final events = <CalendarEventData<T>>[];

    if (_calendarData.events[date] != null) {
      events.addAll(_calendarData.events[date]!);
    }

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
    if (_calendarData.eventList.contains(event)) return;

    var dayDifference = event.endDate.difference(event.date).inDays;
    if (!event.endTime!.isDayStart) {
      dayDifference++;
    }
    for (var dayOffset = 0; dayOffset < dayDifference; dayOffset++) {
      final date = event.date.add(Duration(days: dayOffset));
      if (_calendarData.events[date] == null) {
        _calendarData.events.addAll({
          date: [event],
        });
      } else {
        _calendarData.events[date]!.add(event);
      }
    }

    _calendarData.eventList.add(event);

    notifyListeners();
  }

//#endregion
}

class CalendarData<T> {
  // Stores events that occurs only once in a map.
  final events = <DateTime, List<CalendarEventData<T>>>{};

  // Stores all the events in a list.
  final eventList = <CalendarEventData<T>>[];
}
