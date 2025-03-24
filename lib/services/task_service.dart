import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  // Obtenir le flux des tâches
  Stream<QuerySnapshot> getTasks() {
    try {
      return tasks.snapshots();
    } catch (e) {
      print("Erreur dans getTasks: $e");
      rethrow;
    }
  }

  // Ajouter une tâche
  Future<void> addTask(String title, String description, bool isDone) async {
    try {
      await tasks.add({
        'title': title,
        'description': description,
        'isDone': isDone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Tâche ajoutée avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de l'ajout : ${e.message}");
      throw e;
    } catch (e) {
      print("Erreur lors de l'ajout : $e");
      throw e;
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(
      String taskId, String title, String description) async {
    try {
      await tasks.doc(taskId).update({
        'title': title,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Tâche mise à jour avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la mise à jour : ${e.message}");
      throw e;
    } catch (e) {
      print("Erreur lors de la mise à jour : $e");
      throw e;
    }
  }

  // Mettre à jour le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, bool isDone) async {
    try {
      await tasks.doc(taskId).update({
        'isDone': isDone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Statut de la tâche mis à jour avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la mise à jour du statut : ${e.message}");
      throw e;
    } catch (e) {
      print("Erreur lors de la mise à jour du statut : $e");
      throw e;
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      await tasks.doc(taskId).delete();
      print("Tâche supprimée avec succès !");
    } on FirebaseException catch (e) {
      print("Erreur Firebase lors de la suppression : ${e.message}");
      throw e;
    } catch (e) {
      print("Erreur lors de la suppression : $e");
      throw e;
    }
  }
}
