// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../calendar_view.dart';
import '../components/_internal_components.dart';
import '../components/event_scroll_notifier.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';

/// A single page for week view.
class InternalWeekViewPage<T extends Object?> extends StatefulWidget {
  /// Width of the page.
  final double width;

  /// Height of the page.
  final double height;

  /// Dates to display on page.
  final List<DateTime> dates;

  /// Builds tile for a single event.
  final EventTileBuilder<T> eventTileBuilder;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T> controller;

  /// A builder to build time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Flag to display live line.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  ///  Height occupied by one minute time span.
  final double heightPerMinute;

  /// Width of timeline.
  final double timeLineWidth;

  /// Offset of timeline.
  final double timeLineOffset;

  /// Height occupied by one hour time span.
  final double hourHeight;

  /// Arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line or not.
  final bool showVerticalLine;

  /// Offset for vertical line offset.
  final double verticalLineOffset;

  /// Builder for week day title.
  final DateWidgetBuilder weekDayBuilder;

  /// Builder for week number.
  final WeekNumberBuilder weekNumberBuilder;

  /// Builds custom PressDetector widget
  final DetectorBuilder weekDetectorBuilder;

  /// Height of week title.
  final double weekTitleHeight;

  /// Width of week title.
  final double weekTitleWidth;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  final List<WeekDays> weekDays;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  final EventScrollConfiguration scrollConfiguration;

  /// Display full day events.
  final FullDayEventBuilder<T> fullDayEventBuilder;

  final double Function(int) fullDayEventHeightCalculator;

  final ScrollController scrollController;

  /// A single page for week view.
  const InternalWeekViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.weekTitleHeight,
    required this.weekDayBuilder,
    required this.weekNumberBuilder,
    required this.width,
    required this.dates,
    required this.eventTileBuilder,
    required this.controller,
    required this.timeLineBuilder,
    required this.hourIndicatorSettings,
    required this.showLiveLine,
    required this.liveTimeIndicatorSettings,
    required this.heightPerMinute,
    required this.timeLineWidth,
    required this.timeLineOffset,
    required this.height,
    required this.hourHeight,
    required this.eventArranger,
    required this.verticalLineOffset,
    required this.weekTitleWidth,
    required this.onTileTap,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.weekDays,
    required this.minuteSlotSize,
    required this.scrollConfiguration,
    required this.fullDayEventBuilder,
    required this.fullDayEventHeightCalculator,
    required this.scrollController,
    required this.weekDetectorBuilder,
  }) : super(key: key);

  @override
  State<InternalWeekViewPage> createState() => _InternalWeekViewPageState();
}

class _InternalWeekViewPageState<T extends Object?>
    extends State<InternalWeekViewPage<T>> {
  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDates = _filteredDate();
    final maxFullDayEventCount = filteredDates
        .map((date) => widget.controller.getFullDayEvents(date).length)
        .reduce(max);

    return Container(
      height: widget.height + widget.weekTitleHeight,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: widget.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: widget.weekTitleHeight,
                  width: widget.timeLineWidth +
                      widget.hourIndicatorSettings.offset,
                  child: widget.weekNumberBuilder.call(filteredDates[0]),
                ),
                ...List.generate(
                  filteredDates.length,
                  (index) => SizedBox(
                    height: widget.weekTitleHeight,
                    width: widget.weekTitleWidth,
                    child: widget.weekDayBuilder(
                      filteredDates[index],
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(
            thickness: 1,
            height: 1,
          ),
          if (maxFullDayEventCount > 0)
            SizedBox(
              width: widget.width,
              child: Row(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  color: widget.hourIndicatorSettings.color),
                              bottom: BorderSide(
                                  color: widget.hourIndicatorSettings.color))),
                      width: widget.timeLineWidth +
                          widget.hourIndicatorSettings.offset,
                      height: widget
                          .fullDayEventHeightCalculator(maxFullDayEventCount)),
                  ...List.generate(filteredDates.length, (index) {
                    final fullDayEvents = widget.controller
                        .getFullDayEvents(filteredDates[index]);
                    return Container(
                      decoration: BoxDecoration(
                          border: Border(
                        right: BorderSide(
                            color: widget.hourIndicatorSettings.color),
                        bottom: BorderSide(
                            color: widget.hourIndicatorSettings.color),
                      )),
                      width: widget.weekTitleWidth,
                      height: widget
                          .fullDayEventHeightCalculator(maxFullDayEventCount),
                      child: fullDayEvents.isNotEmpty
                          ? widget.fullDayEventBuilder.call(
                              fullDayEvents,
                              filteredDates[index],
                            )
                          : null,
                    );
                  })
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: ClampingScrollPhysics(),
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: HourLinePainter(
                        lineColor: widget.hourIndicatorSettings.color,
                        lineHeight: widget.hourIndicatorSettings.height,
                        offset: widget.timeLineWidth +
                            widget.hourIndicatorSettings.offset,
                        minuteHeight: widget.heightPerMinute,
                        verticalLineOffset: widget.verticalLineOffset,
                        showVerticalLine: widget.showVerticalLine,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: widget.weekTitleWidth * filteredDates.length,
                        height: widget.height,
                        child: Row(
                          children: [
                            ...List.generate(
                              filteredDates.length,
                              (index) => Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: widget.hourIndicatorSettings.color,
                                      width:
                                          widget.hourIndicatorSettings.height,
                                    ),
                                  ),
                                ),
                                height: widget.height,
                                width: widget.weekTitleWidth,
                                child: Stack(
                                  children: [
                                    EventGenerator<T>(
                                      height: widget.height,
                                      date: filteredDates[index],
                                      onTileTap: widget.onTileTap,
                                      width: widget.weekTitleWidth,
                                      eventArranger: widget.eventArranger,
                                      eventTileBuilder: widget.eventTileBuilder,
                                      scrollNotifier:
                                          widget.scrollConfiguration,
                                      events: widget.controller
                                          .getEventsOnDay(filteredDates[index]),
                                      heightPerMinute: widget.heightPerMinute,
                                    ),
                                    widget.weekDetectorBuilder(
                                      width: widget.weekTitleWidth,
                                      height: widget.height,
                                      heightPerMinute: widget.heightPerMinute,
                                      date: widget.dates[index],
                                      minuteSlotSize: widget.minuteSlotSize,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    TimeLine(
                      timeLineWidth: widget.timeLineWidth,
                      hourHeight: widget.hourHeight,
                      height: widget.height,
                      timeLineOffset: widget.timeLineOffset,
                      timeLineBuilder: widget.timeLineBuilder,
                    ),
                    if (widget.showLiveLine &&
                        widget.liveTimeIndicatorSettings.height > 0)
                      LiveTimeIndicator(
                        liveTimeIndicatorSettings:
                            widget.liveTimeIndicatorSettings,
                        width: widget.width,
                        height: widget.height,
                        heightPerMinute: widget.heightPerMinute,
                        timeLineWidth: widget.timeLineWidth,
                        indicatorOffset: (date) =>
                            filteredDates.indexOf(date.withoutTime) *
                            widget.weekTitleWidth,
                        indicatorWidth: widget.weekTitleWidth,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _filteredDate() {
    final output = <DateTime>[];

    final weekDays = widget.weekDays.toList();

    for (final date in widget.dates) {
      if (weekDays.any((weekDay) => weekDay.index + 1 == date.weekday)) {
        output.add(date);
      }
    }

    return output;
  }
}
