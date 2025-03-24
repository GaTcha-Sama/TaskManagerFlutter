import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_task_screen.dart';
import '../services/task_service.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  bool _showOnlyCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des tâches"),
        actions: [
          IconButton(
            icon: Icon(_showOnlyCompleted
                ? Icons.check_box
                : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                _showOnlyCompleted = !_showOnlyCompleted;
              });
            },
            tooltip: 'Filtrer les tâches terminées',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data?.docs ?? [];
          final filteredTasks = _showOnlyCompleted
              ? tasks
                  .where((doc) =>
                      (doc.data() as Map<String, dynamic>)['isDone'] == true)
                  .toList()
              : tasks;

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index].data() as Map<String, dynamic>;
              final taskId = filteredTasks[index].id;

              return Card(
                elevation: 4,
                child: Dismissible(
                  key: Key(taskId),
                  onDismissed: (direction) {
                    _taskService.deleteTask(taskId);
                  },
                  background: Container(
                    color: Colors.red.shade400,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(
                      task['title'] ?? '',
                      style: TextStyle(
                        fontWeight: task['isDone'] ?? false
                            ? FontWeight.normal
                            : FontWeight.bold,
                        decoration: task['isDone'] ?? false
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(task['description'] ?? ''),
                    leading: Icon(
                      Icons.task_alt,
                      color:
                          task['isDone'] ?? false ? Colors.green : Colors.grey,
                    ),
                    trailing: Checkbox(
                      value: task['isDone'] ?? false,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (bool? value) {
                        _taskService.updateTaskStatus(taskId, value ?? false);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            taskId: taskId,
                            task: task,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
