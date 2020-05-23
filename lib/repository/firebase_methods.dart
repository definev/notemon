import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/models/today_task.dart';
import 'dart:async';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future<void> updateHabitToFirebase(Habit habit) async {
    FirebaseUser _user = await _auth.currentUser();
    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('habits')
        .document(habit.id.toString())
        .setData(
          habit.toMap(),
          merge: true,
        );
  }

  Future<void> uploadAllHabitToFirebase(List<Habit> habitList) async {
    FirebaseUser _user = await _auth.currentUser();
    habitList.forEach((habit) async {
      await _firestore
          .collection('databases')
          .document(_user.uid)
          .collection('habits')
          .document(habit.id.toString())
          .setData(
            habit.toMap(),
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

  Future<void> updateTodoToFirebase(TodayTask todo) async {
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

  Future<void> uploadAllTodoToFirebase(List<TodayTask> todoList) async {
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

  Future<List<TodayTask>> getAllTodoOnCloud() async {
    FirebaseUser _user = await _auth.currentUser();
    List<TodayTask> todoList = [];
    QuerySnapshot _snapshot = await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('todos')
        .getDocuments();
    _snapshot.documents.forEach((doc) {
      // doc.data
    });
    
  }
}
