import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'dart:async';

import 'package:gottask/models/todo.dart';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future<void> updateTaskToFirebase(Task task) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('tasks')
        .document(task.id.toString())
        .setData(
          task.toMap(),
          merge: true,
        );
  }

  Future<void> uploadAllTaskToFirebase(List<Task> taskList) async {
    FirebaseUser _user = await _auth.currentUser();
    taskList.forEach((task) async {
      await _firestore
          .collection('databases')
          .document(_user.uid)
          .collection('tasks')
          .document(task.id.toString())
          .setData(
            task.toMap(),
            merge: true,
          );
    });
  }

  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('pokemonStates')
        .document(pokemonState.name.toString())
        .setData(
          pokemonState.toMap(),
          merge: true,
        );
  }

  Future<void> uploadAllPokemonStateToFirebase(
      List<PokemonState> pokemonStateList) async {
    FirebaseUser _user = await _auth.currentUser();
    pokemonStateList.forEach((pokemonState) async {
      await _firestore
          .collection('databases')
          .document(_user.uid)
          .collection('pokemonStates')
          .document(pokemonState.name.toString())
          .setData(
            pokemonState.toMap(),
            merge: true,
          );
    });
  }

  Future<void> updateTodoToFirebase(Todo todo) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('todos')
        .document(todo.id.toString())
        .setData(
          todo.toMap(),
          merge: true,
        );
  }

  Future<void> uploadAllTodoToFirebase(List<Todo> todoList) async {
    FirebaseUser _user = await _auth.currentUser();
    todoList.forEach((todo) async {
      await _firestore
          .collection('databases')
          .document(_user.uid)
          .collection('todos')
          .document(todo.id.toString())
          .setData(
            todo.toMap(),
            merge: true,
          );
    });
  }

  Future<void> deleteTodoOnFirebase(Todo todo) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('todos')
        .document(todo.id.toString())
        .delete();
  }

  Future<void> deleteTaskOnFirebase(Task task) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('tasks')
        .document(task.id.toString())
        .delete();
  }

  // Future<List<Todo>> getAllTodoOnCloud() async {
  //   FirebaseUser _user = await _auth.currentUser();
  //   List<Todo> todoList = [];
  //   QuerySnapshot _snapshot = await _firestore
  //       .collection('databases')
  //       .document(_user.uid)
  //       .collection('todos')
  //       .getDocuments();
  //   _snapshot.documents.forEach((doc) {
  //     // doc.data
  //   });
  // }
}
