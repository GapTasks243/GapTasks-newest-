import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String desc;

  @HiveField(2)
  String priority;

  @HiveField(3)
  String tag;

  @HiveField(4)
  int estimatedMinutes;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  DateTime? scheduled;

  @HiveField(7)
  bool completed;

  @HiveField(8)
  List<Map<String, dynamic>>? dependencies;

  @HiveField(9)
  List<String>? attachments;

  @HiveField(10)
  String? feedback;

  @HiveField(11)
  DateTime? startTime;

  @HiveField(12)
  DateTime? completedTime;

  @HiveField(13)
  List<Map<String, dynamic>>? logs;

  @HiveField(14)
  String? recurring;

  @HiveField(15)
  List<int>? recurringDays;

  Task({
    required this.title,
    required this.desc,
    required this.priority,
    required this.tag,
    required this.estimatedMinutes,
    this.deadline,
    this.scheduled,
    this.completed = false,
    this.dependencies,
    this.attachments,
    this.feedback,
    this.recurring,
    this.recurringDays,
  });

  static int feedbackScore(String? feedback) {
    switch (feedback) {
      case 'Super Productive':
        return 2;
      case 'Productive':
        return 1;
      case 'Okay':
        return 0;
      case 'Neutral':
        return -1;
      case 'Unfocused':
        return -2;
      case 'Tired':
        return -3;
      default:
        return 0;
    }
  }

  static String bucketTime(DateTime? dt) {
    if (dt == null) return 'Unknown';
    final hour = dt.hour;
    if (hour >= 6 && hour < 10) return 'Morning';
    if (hour >= 10 && hour < 12) return 'Late Morning';
    if (hour >= 12 && hour < 15) return 'Early Afternoon';
    if (hour >= 15 && hour < 18) return 'Late Afternoon';
    if (hour >= 18 && hour < 21) return 'Evening';
    if (hour >= 21 || hour < 1) return 'Night';
    return 'Night';
  }

  static int _priorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  void logCompletion() {
    final logEntry = {
      'startTime': startTime?.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'priority': priority,
      'priorityValue': _priorityValue(priority),
      'estimatedMinutes': estimatedMinutes,
      'feedback': feedback,
      'feedbackScore': feedbackScore(feedback),
      'startTimeBucket': bucketTime(startTime),
    };
    logs = (logs ?? [])..add(logEntry);
    save();
    print('Task completed:');
    print('Start time: \\${startTime?.toIso8601String()} (Bucket: \\${bucketTime(startTime)})');
    print('Priority: \\${priority}');
    print('Estimated time: \\${estimatedMinutes} min');
    print('Feedback: \\${feedback} (Score: \\${feedbackScore(feedback)})');
  }

  static Map<String, Map<String, dynamic>> aggregateLogs(List<Task> tasks) {
    final Map<String, List<Map<String, dynamic>>> bucketed = {};
    for (final task in tasks) {
      if (task.logs == null) continue;
      for (final log in task.logs!) {
        final bucket = log['startTimeBucket'] ?? 'Unknown';
        bucketed.putIfAbsent(bucket, () => []).add(log);
      }
    }
    final Map<String, Map<String, dynamic>> result = {};
    bucketed.forEach((bucket, logs) {
      final total = logs.length;
      final avgFeedback = logs.isNotEmpty ? logs.map((l) => (l['feedbackScore'] ?? 0) as num).reduce((a, b) => a + b) / total : 0.0;
      final avgPriority = logs.isNotEmpty ? logs.map((l) => (l['priorityValue'] ?? 0) as num).reduce((a, b) => a + b) / total : 0.0;
      final avgDuration = logs.isNotEmpty ? logs.map((l) => (l['estimatedMinutes'] ?? 0) as num).reduce((a, b) => a + b) / total : 0.0;
      result[bucket] = {
        'total_tasks': total,
        'avg_feedback_score': double.parse(avgFeedback.toStringAsFixed(2)),
        'avg_priority': double.parse(avgPriority.toStringAsFixed(2)),
        'avg_duration': double.parse(avgDuration.toStringAsFixed(2)),
      };
    });
    return result;
  }

  /// Returns a map with the best time bucket for each category:
  /// - 'high_priority': best time for high-priority tasks
  /// - 'long_task': best time for long tasks (>=30 min)
  /// - 'any': best time for any task
  /// Each value is a map: { 'bucket': String, 'score': double }
  static Map<String, Map<String, dynamic>> learnBestTimes(List<Task> tasks) {
    final Map<String, List<Map<String, dynamic>>> bucketed = {};
    for (final task in tasks) {
      if (task.logs == null) continue;
      for (final log in task.logs!) {
        final bucket = log['startTimeBucket'] ?? 'Unknown';
        bucketed.putIfAbsent(bucket, () => []).add(log);
      }
    }
    // Helper to get best bucket by filter
    Map<String, dynamic> bestBucket(bool Function(Map<String, dynamic>) filter) {
      String? best;
      double bestScore = double.negativeInfinity;
      bucketed.forEach((bucket, logs) {
        final filtered = logs.where(filter).toList();
        if (filtered.isEmpty) return;
        final avg = filtered.map((l) => (l['feedbackScore'] ?? 0) as num).reduce((a, b) => a + b) / filtered.length;
        if (avg > bestScore) {
          bestScore = avg.toDouble();
          best = bucket;
        }
      });
      return {'bucket': best, 'score': bestScore.isFinite ? bestScore : null};
    }
    return {
      'high_priority': bestBucket((l) => (l['priorityValue'] ?? 0) == 3),
      'long_task': bestBucket((l) => (l['estimatedMinutes'] ?? 0) >= 30),
      'any': bestBucket((l) => true),
    };
  }

  /// Returns a score for this task based on best times and current time.
  /// bestTimes: map from SharedPreferences (decoded JSON)
  /// now: current DateTime (default: DateTime.now())
  /// freeMinutes: optional, the length of the user's current free time block
  double score(Map<String, dynamic> bestTimes, {DateTime? now, int? freeMinutes}) {
    now ??= DateTime.now();
    final bucket = bucketTime(now);
    final isHigh = _priorityValue(priority) == 3;
    final isLong = estimatedMinutes >= 30;
    double base = 0;
    // Prefer best time for high-priority, then long, then any
    if (isHigh && bestTimes['high_priority'] != null && bestTimes['high_priority']['bucket'] == bucket) {
      base = (bestTimes['high_priority']['score'] ?? 0).toDouble();
    } else if (isLong && bestTimes['long_task'] != null && bestTimes['long_task']['bucket'] == bucket) {
      base = (bestTimes['long_task']['score'] ?? 0).toDouble();
    } else if (bestTimes['any'] != null && bestTimes['any']['bucket'] == bucket) {
      base = (bestTimes['any']['score'] ?? 0).toDouble();
    }

    // --- IMPROVEMENTS ---
    double score = base;

    // 1. Deadline urgency (sooner deadline = higher score)
    if (deadline != null) {
      final daysLeft = deadline!.difference(now).inDays;
      if (daysLeft <= 0) {
        score += 2.5; // Overdue or due today: big boost
      } else if (daysLeft == 1) {
        score += 1.5;
      } else if (daysLeft <= 3) {
        score += 1.0;
      } else if (daysLeft <= 7) {
        score += 0.5;
      }
      // --- Last-Minute Boost ---
      final minutesLeft = deadline!.difference(now).inMinutes;
      if (minutesLeft > 0 && minutesLeft <= 720) {
        score += 5.0; // Big boost for last-12-hour tasks
      }
    }

    // 2. Priority boost
    score += 0.5 * _priorityValue(priority);

    // 3. Fit to free time block (if provided)
    if (freeMinutes != null) {
      if (estimatedMinutes <= freeMinutes) {
        score += 0.5;
        // If it fits perfectly (within 10 min), give a bigger boost
        if ((freeMinutes - estimatedMinutes).abs() <= 10) {
          score += 0.5;
        }
      } else {
        score -= 1.0; // Penalize if it doesn't fit
      }
    }

    // 4. Recent negative feedback in this time bucket (deprioritize)
    if (logs != null && logs!.isNotEmpty) {
      final recent = logs!.lastWhere(
        (l) => l['startTimeBucket'] == bucket,
        orElse: () => {},
      );
      if (recent.isNotEmpty && (recent['feedbackScore'] ?? 0) < 0) {
        score -= 1.0;
      }
    }

    // 5. Task age (older tasks get a small boost)
    if (this is HiveObject && (this as HiveObject).key != null) {
      // If using Hive, we can get the key as a proxy for age
      // But better: use logs or created time if available
      // For now, boost if no logs (old and never done)
      if (logs == null || logs!.isEmpty) {
        score += 0.25;
      }
    }

    return score;
  }
} 