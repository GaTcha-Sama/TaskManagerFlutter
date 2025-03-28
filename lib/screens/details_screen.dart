import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/task_service.dart';

class DetailsScreen extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> task;
  static final TaskService _taskService = TaskService();

  const DetailsScreen({
    required this.taskId,
    required this.task,
    super.key,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _selectedPriority = widget.task['priority'] ?? 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? createdAt;
    try {
      createdAt = widget.task['createdAt'] != null
          ? (widget.task['createdAt'] as Timestamp).toDate()
          : null;
    } catch (e) {
      print('Erreur de conversion de la date: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails de la tâche",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                await DetailsScreen._taskService.updateTask(
                  widget.taskId,
                  _titleController.text,
                  _descriptionController.text,
                  _selectedPriority,
                );
                setState(() => _isEditing = false);
                Navigator.pop(context);
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
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
                DetailsScreen._taskService.deleteTask(widget.taskId);
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
                  _isEditing
                      ? TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Titre'),
                        )
                      : Text(
                          widget.task['title'] ?? 'Sans titre',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
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
                  _isEditing
                      ? TextField(
                          controller: _descriptionController,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                        )
                      : _buildInfoRow(
                          context,
                          icon: Icons.description,
                          text: widget.task['description'] ??
                              'Aucune description',
                        ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.flag,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      const Text('Priorité : '),
                      _isEditing
                          ? DropdownButton<String>(
                              value: _selectedPriority,
                              items:
                                  ['low', 'medium', 'high'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedPriority = newValue;
                                  });
                                }
                              },
                            )
                          : Text(widget.task['priority'] ?? 'medium'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      const Text('Statut : '),
                      Checkbox(
                        value: widget.task['isDone'],
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (bool? value) {
                          DetailsScreen._taskService
                              .updateTaskStatus(widget.taskId, value ?? false);
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
