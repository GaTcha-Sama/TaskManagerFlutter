import 'package:flutter/material.dart';

class TaskProgressIndicator extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const TaskProgressIndicator({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progressPercentage {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$completedTasks tâches sur $totalTasks complétées (${progressPercentage.toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
