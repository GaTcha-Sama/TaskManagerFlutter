import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  Stream<QuerySnapshot> getTasks() {
    try {
      return tasks.orderBy('priority', descending: false).snapshots();
    } catch (e) {
      print("Erreur dans getTasks: $e");
      rethrow;
    }
  }

  Future<void> addTask(
      String title, String description, bool isDone, String priority) async {
    try {
      await tasks.add({
        'title': title,
        'description': description,
        'isDone': isDone,
        'priority': priority,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Tâche ajoutée avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de l'ajout : ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur lors de l'ajout : $e");
      rethrow;
    }
  }

  Future<void> updateTask(
      String taskId, String title, String description, String priority) async {
    try {
      await tasks.doc(taskId).update({
        'title': title,
        'description': description,
        'priority': priority,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Tâche mise à jour avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la mise à jour : ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur lors de la mise à jour : $e");
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, bool isDone) async {
    try {
      await tasks.doc(taskId).update({
        'isDone': isDone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Statut de la tâche mis à jour avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la mise à jour du statut : ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur lors de la mise à jour du statut : $e");
      rethrow;
    }
  }

  Future<void> updateTaskPriority(String taskId, String priority) async {
    try {
      await tasks.doc(taskId).update({
        'priority': priority,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Priorité mise à jour avec succès !");
    } catch (e) {
      print("Erreur lors de la mise à jour de la priorité : $e");
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await tasks.doc(taskId).delete();
      print("Tâche supprimée avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la suppression : ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur lors de la suppression : $e");
      rethrow;
    }
  }
}
