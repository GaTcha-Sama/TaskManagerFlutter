import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_task_screen.dart';
import '../services/task_service.dart';
import 'details_screen.dart';
import '../widgets/progress_indicator.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

enum TaskFilter { all, completed, todo } // Enum pour les filtres

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    // Ajout de l'écoute des tâches non terminées
    FirebaseFirestore.instance
        .collection('tasks')
        .where('isDone', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((doc) {
        print(doc['title']); // Affiche les titres des tâches non terminées
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des tâches"),
        centerTitle: true,
        actions: [
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (TaskFilter filter) {
              setState(() {
                _currentFilter = filter;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Text('Toutes les tâches'),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Text('Tâches terminées'),
              ),
              const PopupMenuItem(
                value: TaskFilter.todo,
                child: Text('Tâches à faire'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
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
          final completedTasks =
              tasks.where((doc) => doc['isDone'] == true).length;
          final filteredTasks = switch (_currentFilter) {
            TaskFilter.completed =>
              tasks.where((doc) => doc['isDone'] == true).toList(),
            TaskFilter.todo =>
              tasks.where((doc) => doc['isDone'] == false).toList(),
            TaskFilter.all => tasks,
          };

          return Column(
            children: [
              TaskProgressIndicator(
                totalTasks: tasks.length,
                completedTasks: completedTasks,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task =
                        filteredTasks[index].data() as Map<String, dynamic>;
                    final taskId = filteredTasks[index].id;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              _getPriorityColor(task['priority'] ?? 'medium'),
                          width: 2,
                        ),
                      ),
                      child: Dismissible(
                        key: Key(taskId),
                        onDismissed: (direction) async {
                          bool shouldDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text(
                                        'Êtes-vous sûr de vouloir supprimer cette tâche ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (shouldDelete) {
                            _taskService.deleteTask(taskId);
                          }
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
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getPriorityIcon(task['priority'] ?? 'medium'),
                                color: _getPriorityColor(
                                    task['priority'] ?? 'medium'),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.task_alt,
                                color: task['isDone'] ?? false
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
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
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmation'),
                                        content: const Text(
                                            'Êtes-vous sûr de vouloir supprimer cette tâche ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Ferme la boîte de dialogue
                                            },
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _taskService.deleteTask(taskId);
                                              Navigator.of(context)
                                                  .pop(); // Ferme la boîte de dialogue
                                            },
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Checkbox(
                                value: task['isDone'] ?? false,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                onChanged: (bool? value) {
                                  _taskService.updateTaskStatus(
                                      taskId, value ?? false);
                                },
                              ),
                            ],
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
                ),
              ),
            ],
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.help_outline;
    }
  }
}
