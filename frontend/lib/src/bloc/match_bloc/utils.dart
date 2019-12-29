

import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:flutter/material.dart';

extension on DateTime {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: this.hour, minute: this.minute);
  }
}

extension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (this.hour != other.hour) {
      return this.hour - other.hour;
    }
    return this.minute - other.minute;
  }
}


// by design we query matches from the server by providing two dates: timeFrom, timeTo
// both of them include dates and hours (from, to) which indicate that we want only matches in range
// additionally in the app we want to display matches matching not only date span but time span as well
// so right now we filter out those matches that fit date span but fail to fit time span
List<Match> filterMatches(List<Match> matches, MatchFilter filter) {
  final timeFrom = filter.timeFrom.toTimeOfDay();
  final timeTo = filter.timeTo.toTimeOfDay();

  return matches.where((match) {
    return match.startTime.toTimeOfDay().compareTo(timeFrom) >= 0 && match.endTime.toTimeOfDay().compareTo(timeTo) <= 0;
  }).toList();
}
