import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Time Left Calculation Logic Tests', () {
    test('Time calculation logic works correctly', () {
      // Test the time calculation logic that's used in _formatTimeLeft
      final now = const TimeOfDay(hour: 10, minute: 0); // 10:00 AM
      final bed = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
      
      final nowMinutes = now.hour * 60 + now.minute;
      final bedMinutes = bed.hour * 60 + bed.minute;
      int diff = bedMinutes - nowMinutes;
      if (diff < 0) diff += 24 * 60;
      
      // Expected: 22*60 - 10*60 = 720 minutes (12 hours)
      expect(diff, equals(720));
      
      // Test with scheduled tasks
      int scheduledMinutes = 120; // 2 hours of scheduled tasks
      diff -= scheduledMinutes;
      
      // Expected: 720 - 120 = 600 minutes (10 hours)
      expect(diff, equals(600));
    });

    test('Time formatting works correctly', () {
      // Test the time formatting logic
      int minutes = 600; // 10 hours
      final h = minutes ~/ 60;
      final m = minutes % 60;
      
      expect(h, equals(10));
      expect(m, equals(0));
      
      minutes = 90; // 1 hour 30 minutes
      final h2 = minutes ~/ 60;
      final m2 = minutes % 60;
      
      expect(h2, equals(1));
      expect(m2, equals(30));
    });

    test('Scheduled task overlap calculation', () {
      // Test the logic for calculating overlap between scheduled tasks and available time
      final nowDateTime = DateTime(2024, 1, 1, 10, 0); // 10:00 AM
      final bedDateTime = DateTime(2024, 1, 1, 22, 0); // 10:00 PM
      
      // Case 1: Task starts after now and ends before bedtime
      final scheduledStart1 = DateTime(2024, 1, 1, 14, 0); // 2:00 PM
      final scheduledEnd1 = DateTime(2024, 1, 1, 16, 0); // 4:00 PM
      
      int scheduledMinutes = 0;
      if (scheduledStart1.isAfter(nowDateTime) && scheduledEnd1.isBefore(bedDateTime)) {
        scheduledMinutes += scheduledEnd1.difference(scheduledStart1).inMinutes;
      }
      
      expect(scheduledMinutes, equals(120)); // 2 hours
      
      // Case 2: Task starts after now but ends after bedtime
      final scheduledStart2 = DateTime(2024, 1, 1, 20, 0); // 8:00 PM
      final scheduledEnd2 = DateTime(2024, 1, 1, 23, 0); // 11:00 PM
      
      if (scheduledStart2.isAfter(nowDateTime) && scheduledStart2.isBefore(bedDateTime)) {
        scheduledMinutes += bedDateTime.difference(scheduledStart2).inMinutes;
      }
      
      expect(scheduledMinutes, equals(200)); // 120 + 80 = 200 minutes
    });
  });
} 