// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../components/event_scroll_notifier.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';

/// Defines a single day page.
class InternalDayViewPage<T extends Object?> extends StatefulWidget {
  /// Width of the page
  final double width;

  /// Height of the page.
  final double height;

  /// Date for which we are displaying page.
  final DateTime date;

  /// A builder that returns a widget to show event on screen.
  final EventTileBuilder<T> eventTileBuilder;

  /// Controller for calendar
  final EventController<T> controller;

  /// A builder that builds time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Builds custom PressDetector widget
  final DetectorBuilder dayDetectorBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Flag to display live time indicator.
  /// If true then indicator will be displayed else not.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  /// Height occupied by one minute of time span.
  final double heightPerMinute;

  /// Width of time line.
  final double timeLineWidth;

  /// Offset for time line widgets.
  final double timeLineOffset;

  /// Height occupied by one hour of time span.
  final double hourHeight;

  /// event arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line.
  final bool showVerticalLine;

  /// Offset  of vertical line.
  final double verticalLineOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

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

  /// Notifies if there is any event that needs to be visible instantly.
  final EventScrollConfiguration scrollNotifier;

  /// Display full day events.
  final FullDayEventBuilder<T> fullDayEventBuilder;

  /// Flag to display half hours.
  final bool showHalfHours;

  /// Settings for half hour indicator lines.
  final HourIndicatorSettings halfHourIndicatorSettings;

  final ScrollController scrollController;

  /// Defines a single day page.
  const InternalDayViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.width,
    required this.date,
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
    required this.onTileTap,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.minuteSlotSize,
    required this.scrollNotifier,
    required this.fullDayEventBuilder,
    required this.scrollController,
    required this.dayDetectorBuilder,
    required this.showHalfHours,
    required this.halfHourIndicatorSettings,
  }) : super(key: key);

  @override
  State<InternalDayViewPage> createState() => _InternalDayViewPageState();
}

class _InternalDayViewPageState<T extends Object?>
    extends State<InternalDayViewPage<T>> {
  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullDayEvents = widget.controller.getFullDayEvents(widget.date);

    return Container(
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          if (fullDayEvents.isNotEmpty) ...[
            Container(
                margin: EdgeInsets.only(
                    left: widget.timeLineWidth +
                        widget.halfHourIndicatorSettings.offset +
                        widget.verticalLineOffset -
                        0.5),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: widget.hourIndicatorSettings.color))),
                child: widget.fullDayEventBuilder(fullDayEvents, widget.date)),
            Divider(height: 1, color: widget.hourIndicatorSettings.color)
          ],
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
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
                        lineStyle: widget.hourIndicatorSettings.lineStyle,
                        dashWidth: widget.hourIndicatorSettings.dashWidth,
                        dashSpaceWidth:
                            widget.hourIndicatorSettings.dashSpaceWidth,
                      ),
                    ),
                    if (widget.showHalfHours)
                      CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: HalfHourLinePainter(
                          lineColor: widget.halfHourIndicatorSettings.color,
                          lineHeight: widget.halfHourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.halfHourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          lineStyle: widget.halfHourIndicatorSettings.lineStyle,
                          dashWidth: widget.halfHourIndicatorSettings.dashWidth,
                          dashSpaceWidth:
                              widget.halfHourIndicatorSettings.dashSpaceWidth,
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: EventGenerator<T>(
                        height: widget.height,
                        date: widget.date,
                        onTileTap: widget.onTileTap,
                        eventArranger: widget.eventArranger,
                        events: widget.controller.getEventsOnDay(widget.date),
                        heightPerMinute: widget.heightPerMinute,
                        eventTileBuilder: widget.eventTileBuilder,
                        scrollNotifier: widget.scrollNotifier,
                        width: widget.width -
                            widget.timeLineWidth -
                            widget.hourIndicatorSettings.offset -
                            widget.verticalLineOffset,
                      ),
                    ),
                    widget.dayDetectorBuilder(
                      width: widget.width,
                      height: widget.height,
                      heightPerMinute: widget.heightPerMinute,
                      date: widget.date,
                      minuteSlotSize: widget.minuteSlotSize,
                    ),
                    TimeLine(
                      height: widget.height,
                      hourHeight: widget.hourHeight,
                      timeLineBuilder: widget.timeLineBuilder,
                      timeLineOffset: widget.timeLineOffset,
                      timeLineWidth: widget.timeLineWidth,
                      showHalfHours: widget.showHalfHours,
                      key: ValueKey(widget.heightPerMinute),
                    ),
                    if (widget.showLiveLine &&
                        widget.liveTimeIndicatorSettings.height > 0)
                      IgnorePointer(
                        child: LiveTimeIndicator(
                          liveTimeIndicatorSettings:
                              widget.liveTimeIndicatorSettings,
                          width: widget.width,
                          height: widget.height,
                          heightPerMinute: widget.heightPerMinute,
                          timeLineWidth: widget.timeLineWidth,
                        ),
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
}
