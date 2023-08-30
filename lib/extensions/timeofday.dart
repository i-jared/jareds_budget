import 'package:flutter/material.dart';

extension TimeOfDayX on TimeOfDay {
  // to date time with current date
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
