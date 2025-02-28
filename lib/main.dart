import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

class Tasks {
  final String title;
  final String description;
  final bool isDone;

  Tasks({required this.title, required this.description, required this.isDone});
}

// Fonction pour ajouter une nouvelle tâche
Future<void> addTask(String title, String description, bool isDone) async {
  try {
    CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
    await tasks.add({
      'title': title,
      'description': description,
      'isDone': isDone,
    });
    print("Tâche ajoutée avec succès !");
  } catch (e) {
    print("Erreur lors de l'ajout : $e");
  }
}

// Fonction pour supprimer une tâche
Future<void> deleteTask(String taskId) async {
  try {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    print("Tâche supprimée avec succès !");
  } catch (e) {
    print("Erreur lors de la suppression : $e");
  }
}

// Fonction pour modifier une tâche
Future<void> updateTask(String taskId, String title, String description) async {
  try {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'title': title,
      'description': description,
    });
    print("Tâche mise à jour avec succès !");
  } catch (e) {
    print("Erreur lors de la mise à jour : $e");
  }
}

// Point d'entrée de l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialisé avec succès");
  } catch (e) {
    print("Erreur d'initialisation Firebase: $e");
  }
  runApp(const MyApp());
}

// Widget racine de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Task Manager'),
    );
  }
}

// Page principale de l'application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// État de la page principale
class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Fonction pour ajouter une nouvelle tâche
  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une tâche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              addTask(
                  _titleController.text, _descriptionController.text, false);
              _titleController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  // Fonction pour modifier une tâche
  void _editTask(
      String taskId, String currentTitle, String currentDescription) {
    _titleController.text = currentTitle;
    _descriptionController.text = currentDescription;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la tâche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              updateTask(
                taskId,
                _titleController.text,
                _descriptionController.text,
              );
              _titleController.clear();
              _descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ma Liste de Tâches'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Erreur Firestore: ${snapshot.error}");
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune tâche pour le moment'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final task = snapshot.data!.docs[index];
              return Dismissible(
                key: Key(task.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  deleteTask(task.id);
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Text(task['description']),
                    onTap: () => _editTask(
                      task.id,
                      task['title'],
                      task['description'],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task['isDone'],
                          onChanged: (bool? value) {
                            task.reference.update({'isDone': value});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(
                            task.id,
                            task['title'],
                            task['description'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        tooltip: 'Ajouter une tâche',
        child: const Icon(Icons.add),
      ),
    );
  }
}
