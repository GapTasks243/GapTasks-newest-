import 'package:flutter/material.dart';
import 'package:gap_tasks/task.dart';

class TaskDetailsSheet extends StatelessWidget {
  final Task task;

  const TaskDetailsSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (task.desc.isNotEmpty) ...[
            Text(
              task.desc,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.low_priority, 'Priority', task.priority),
          _buildInfoRow(Icons.label_outline, 'Category', task.tag),
          if (task.estimatedMinutes > 0)
            _buildInfoRow(Icons.timer_outlined, 'Estimated Time', '${task.estimatedMinutes} min'),
          if (task.deadline != null)
            _buildInfoRow(Icons.calendar_today_outlined, 'Deadline',
                '${task.deadline!.year}-${task.deadline!.month.toString().padLeft(2, '0')}-${task.deadline!.day.toString().padLeft(2, '0')}'),
          if (task.recurring != null && task.recurring != 'Never')
            _buildInfoRow(Icons.refresh, 'Recurring', task.recurring!),
          if (task.recurringDays != null && task.recurringDays!.isNotEmpty)
            _buildInfoRow(Icons.date_range, 'On Days', _recurringDaysString(task.recurringDays!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _recurringDaysString(List<int> days) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    days.sort();
    return days.map((d) => names[d - 1]).join(', ');
  }
} 