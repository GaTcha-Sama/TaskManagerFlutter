import 'package:flutter/material.dart';
import 'package:task_manager_app/services/task_service.dart';
import '../widgets/custom_button.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();
  String _selectedPriority = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une tâche')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre de la tâche'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priorité',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'high',
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      const Text('Élevée'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Row(
                    children: [
                      Icon(Icons.remove, color: Colors.orange.shade400),
                      const SizedBox(width: 8),
                      const Text('Moyenne'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'low',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green.shade400),
                      const SizedBox(width: 8),
                      const Text('Faible'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Ajouter',
              onPressed: () {
                _taskService.addTask(
                  _titleController.text,
                  _descriptionController.text,
                  false,
                  _selectedPriority,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
