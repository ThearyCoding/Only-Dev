import 'package:intl/intl.dart';

enum TimeUnit {
  days,
  seconds,
}

class TimeUtils {
  static bool isNew(dynamic addedDate, int timeToCheck, TimeUnit timeUnit) {
    if (addedDate == null) return false;
    final DateTime? date = addedDate is DateTime
        ? addedDate
        : DateTime.tryParse(addedDate.toString());
    if (date == null) return false;

    DateTime now = DateTime.now();
    DateTime timeAgo;
    if (timeUnit == TimeUnit.days) {
      timeAgo = now.subtract(Duration(days: timeToCheck));
    } else {
      timeAgo = now.subtract(Duration(seconds: timeToCheck));
    }
    return date.isAfter(timeAgo);
  }

  static String formatDuration(int durationInSeconds) {
    int minutes = durationInSeconds ~/ 60;

    if (minutes >= 60) {
      int hours = minutes ~/ 60;
      minutes = minutes % 60;
      if (minutes > 0) {
        return '$hours hr $minutes min';
      } else {
        return '$hours hr';
      }
    } else {
      return '$minutes min';
    }
  }

  static String formatDurationShowSeconds(int durationInSeconds) {
    int minutes = durationInSeconds ~/ 60;
    int seconds = durationInSeconds % 60;

    if (minutes >= 60) {
      int hours = minutes ~/ 60;
      minutes = minutes % 60;
      if (minutes > 0 && seconds > 0) {
        return '$hours hr $minutes min $seconds sec';
      } else if (minutes > 0) {
        return '$hours hr $minutes min';
      } else {
        return '$hours hr';
      }
    } else if (seconds > 0) {
      return '$minutes min $seconds sec';
    } else {
      return '$minutes min';
    }
  }

  static String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is String && timestamp.isEmpty) return '';

    DateTime? dt;
    if (timestamp is DateTime) {
      dt = timestamp;
    } else if (timestamp is String) {
      dt = DateTime.tryParse(timestamp);
      // If backend already formatted it as a readable string, return as-is
      if (dt == null) return timestamp;
    } else {
      return timestamp.toString();
    }

    final now = DateTime.now();
    final difference = now.difference(dt.toUtc());

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      if (dt.year == now.year) {
        final formatter = DateFormat('MMM dd');
        return formatter.format(dt);
      } else {
        final formatter = DateFormat('MMM dd yyyy');
        return formatter.format(dt);
      }
    }
  }
}
