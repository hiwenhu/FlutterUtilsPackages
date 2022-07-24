// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A value representing a time during the day, independent of the date that
/// day might fall on or the time zone.
///
/// The time is represented by [hour] and [minute] pair. Once created, both
/// values cannot be changed.
///
/// You can create TimeOfDayWithSec using the constructor which requires both hour and
/// minute or using [DateTime] object.
/// Hours are specified between 0 and 23, as in a 24-hour clock.
///
/// {@tool snippet}
///
/// ```dart
/// TimeOfDayWithSec now = TimeOfDayWithSec.now();
/// const TimeOfDayWithSec releaseTime = TimeOfDayWithSec(hour: 15, minute: 0); // 3:00pm
/// TimeOfDayWithSec roomBooked = TimeOfDayWithSec.fromDateTime(DateTime.parse('2018-10-20 16:30:04Z')); // 4:30pm
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [showTimePicker], which returns this type.
///  * [MaterialLocalizations], which provides methods for formatting values of
///    this type according to the chosen [Locale].
///  * [DateTime], which represents date and time, and is subject to eras and
///    time zones.
@immutable
class TimeOfDayWithSec {
  /// Creates a time of day.
  ///
  /// The [hour] argument must be between 0 and 23, inclusive. The [minute]
  /// argument must be between 0 and 59, inclusive.The [second]
  /// argument must be between 0 and 59, inclusive.
  const TimeOfDayWithSec({
    required this.hour,
    required this.minute,
    required this.second,
  });

  /// Creates a time of day based on the given time.
  ///
  /// The [hour] is set to the time's hour and the [minute] is set to the time's
  /// minute and the [second] is set to the time's
  /// second in the timezone of the given [DateTime].
  TimeOfDayWithSec.fromDateTime(DateTime time)
      : hour = time.hour,
        minute = time.minute,
        second = time.second;

  /// Creates a time of day based on the current time.
  ///
  /// The [hour] is set to the current hour and the [minute] is set to the
  /// current minute in the local time zone.
  factory TimeOfDayWithSec.now() {
    return TimeOfDayWithSec.fromDateTime(DateTime.now());
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// The number of hours in one day, i.e. 24.
  static const int hoursPerDay = 24;

  /// The number of hours in one day period (see also [DayPeriod]), i.e. 12.
  static const int hoursPerPeriod = 12;

  /// The number of minutes in one hour, i.e. 60.
  static const int minutesPerHour = 60;

  /// The number of seconds in one minute, i.e. 60.
  static const int secondsPerMinute = 60;

  /// Returns a new TimeOfDayWithSec with the hour and/or minute and/or second replaced.
  TimeOfDayWithSec replacing({int? hour, int? minute, int? second}) {
    assert(hour == null || (hour >= 0 && hour < hoursPerDay));
    assert(minute == null || (minute >= 0 && minute < minutesPerHour));
    assert(second == null || (second >= 0 && second < secondsPerMinute));
    return TimeOfDayWithSec(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  /// The selected hour, in 24 hour time from 0..23.
  final int hour;

  /// The selected minute.
  final int minute;

  /// The selected second.
  final int second;

  /// Whether this time of day is before or after noon.
  DayPeriod get period => hour < hoursPerPeriod ? DayPeriod.am : DayPeriod.pm;

  /// Which hour of the current period (e.g., am or pm) this time is.
  ///
  /// For 12AM (midnight) and 12PM (noon) this returns 12.
  int get hourOfPeriod => hour == 0 || hour == 12 ? 12 : hour - periodOffset;

  /// The hour at which the current period starts.
  int get periodOffset => period == DayPeriod.am ? 0 : hoursPerPeriod;

  /// Returns the localized string representation of this time of day.
  ///
  /// This is a shortcut for [MaterialLocalizations.formatTimeOfDayWithSec].
  String format(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(
          TimeOfDay(hour: hour, minute: minute),
          alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
        ) +
        ":$second";
  }

  @override
  bool operator ==(Object other) {
    return other is TimeOfDayWithSec &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);
    final String secondLabel = _addLeadingZeroIfNeeded(second);

    return '$hourLabel:$minuteLabel:$secondLabel';
  }
}

/// A [RestorableValue] that knows how to save and restore [TimeOfDayWithSec].
///
/// {@macro flutter.widgets.RestorableNum}.
class RestorableTimeOfDayWithSec extends RestorableValue<TimeOfDayWithSec> {
  /// Creates a [RestorableTimeOfDayWithSec].
  ///
  /// {@macro flutter.widgets.RestorableNum.constructor}
  RestorableTimeOfDayWithSec(TimeOfDayWithSec defaultValue)
      : _defaultValue = defaultValue;

  final TimeOfDayWithSec _defaultValue;

  @override
  TimeOfDayWithSec createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(TimeOfDayWithSec? oldValue) {
    assert(debugIsSerializableForRestoration(value.hour));
    assert(debugIsSerializableForRestoration(value.minute));
    assert(debugIsSerializableForRestoration(value.second));
    notifyListeners();
  }

  @override
  TimeOfDayWithSec fromPrimitives(Object? data) {
    final List<Object?> timeData = data! as List<Object?>;
    return TimeOfDayWithSec(
      minute: timeData[0]! as int,
      hour: timeData[1]! as int,
      second: timeData[2]! as int,
    );
  }

  @override
  Object? toPrimitives() => <int>[value.minute, value.hour, value.second];
}
