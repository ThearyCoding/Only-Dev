import 'package:intl/intl.dart';

enum TimeUnit {
  days,
  seconds,
}

class TimeUtils {
  static bool isNew(DateTime? addedDate, int timeToCheck, TimeUnit timeUnit) {
    if (addedDate == null) return false;
    DateTime now = DateTime.now();
    DateTime timeAgo;
    if (timeUnit == TimeUnit.days) {
      timeAgo = now.subtract(Duration(days: timeToCheck));
    } else {
      timeAgo = now.subtract(Duration(seconds: timeToCheck));
    }
    return addedDate.isAfter(timeAgo);
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

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toUtc());

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      // Check if the timestamp is within the current year
      if (timestamp.year == now.year) {
        // Format the timestamp to only display month and day
        final formatter = DateFormat('MMM dd');
        return formatter.format(timestamp);
      } else {
        // Format the timestamp to display the full date including the year
        final formatter = DateFormat('MMM dd yyyy');
        return formatter.format(timestamp);
      }
    }
  }
}
