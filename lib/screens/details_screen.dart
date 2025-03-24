import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/task_service.dart';

class DetailsScreen extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> task;
  static final TaskService _taskService = TaskService();

  const DetailsScreen({
    required this.taskId,
    required this.task,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Gérer le cas où createdAt est null ou n'est pas un Timestamp
    DateTime? createdAt;
    try {
      createdAt = task['createdAt'] != null
          ? (task['createdAt'] as Timestamp).toDate()
          : null;
    } catch (e) {
      print('Erreur de conversion de la date: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la tâche"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text(
                      'Voulez-vous vraiment supprimer cette tâche ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _taskService.deleteTask(taskId);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] ?? 'Sans titre',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    text: createdAt != null
                        ? 'Créée le : ${createdAt.day}/${createdAt.month}/${createdAt.year}'
                        : 'Date de création non disponible',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.description,
                    text: task['description'] ?? 'Aucune description',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      const Text('Statut : '),
                      Checkbox(
                        value: task['isDone'],
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (bool? value) {
                          _taskService.updateTaskStatus(taskId, value ?? false);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
