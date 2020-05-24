import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/database/todo_table.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'dart:async';

import 'package:gottask/models/todo.dart';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  /// Method of [Todo]
  Future<void> updateTodoToFirebase(Todo todo) async {
    final FirebaseUser _user = await _auth.currentUser();
    await TodoTable.updateOrInsertNewTodo(todo);

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
    final FirebaseUser _user = await _auth.currentUser();
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
    final FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('todos')
        .document(todo.id.toString())
        .delete();
  }

  /// Method of [Task]
  Future<void> updateTaskToFirebase(Task task) async {
    final FirebaseUser _user = await _auth.currentUser();

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
    final FirebaseUser _user = await _auth.currentUser();
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

  Future<void> deleteTaskOnFirebase(Task task) async {
    final FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('tasks')
        .document(task.id.toString())
        .delete();
  }

  /// Method of [PokemonState]
  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) async {
    final FirebaseUser _user = await _auth.currentUser();
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
    final FirebaseUser _user = await _auth.currentUser();
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

  /// Method of [FavouritePokemon]
  Future<void> updateFavouritePokemon(int pokemon) async {
    final FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('favouritePokemon')
        .document('id')
        .setData(
      {'pokemon': pokemon},
      merge: true,
    );
  }
}
