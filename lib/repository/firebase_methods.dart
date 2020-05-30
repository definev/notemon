import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/database/todo_table.dart';
import 'package:gottask/models/favourite_pokemon.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'dart:async';

import 'package:gottask/models/todo.dart';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  /// Method of [Todo]
  Future<void> getAllTodoAndLoadToDb() async {}

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
  Future<void> getAllTaskAndLoadToDb(TaskBloc taskBloc) async {
    final FirebaseUser _user = await _auth.currentUser();

    QuerySnapshot _taskSnapshots = await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('tasks')
        .getDocuments();

    taskBloc.add(InitTaskEvent());
    _taskSnapshots.documents.forEach((map) {
      Task task = Task.fromMap(map.data);
      taskBloc.add(AddTaskEvent(task));
    });
  }

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
  Future<void> getAllPokemonStateAndLoadToDb(
      AllPokemonBloc allPokemonBloc) async {
    final FirebaseUser _user = await _auth.currentUser();

    QuerySnapshot _pokemonStateSnapshots = await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('pokemonStates')
        .getDocuments();
    allPokemonBloc.add(InitAllPokemonEvent());
    _pokemonStateSnapshots.documents.forEach((map) {
      PokemonState pokemonState = PokemonState.fromMap(map.data);
      allPokemonBloc.add(UpdatePokemonStateEvent(pokemonState: pokemonState));
    });
  }

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
  Future<void> getFavouritePokemonStateAndLoadToDb(
      FavouritePokemonBloc favouritePokemonBloc) async {
    final FirebaseUser _user = await _auth.currentUser();

    QuerySnapshot _favouritePokemonSnapshots = await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('pokemonStates')
        .getDocuments();
    favouritePokemonBloc.add(InitFavouritePokemonEvent());
    _favouritePokemonSnapshots.documents?.forEach((element) {});
    _favouritePokemonSnapshots.documents.forEach((map) {
      FavouritePokemon favouritePokemon = FavouritePokemon.fromMap(map.data);
      favouritePokemonBloc
          .add(UpdateFavouritePokemonEvent(favouritePokemon.pokemon));
    });
  }

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

  /// Method of [Starpoint]
  Future<void> getStarpoint(StarBloc starBloc) async {
    final FirebaseUser _user = await _auth.currentUser();
    DocumentSnapshot _starSnapshot = await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('starPoint')
        .document('star')
        .get();

    if (_starSnapshot.data != null)
      starBloc.add(SetStarEvent(point: _starSnapshot.data['star'] ?? 0));
  }

  Future<void> updateStarpoint(int currentStar) async {
    final FirebaseUser _user = await _auth.currentUser();
    Map<String, int> _star = {"star": currentStar};

    await _firestore
        .collection('databases')
        .document(_user.uid)
        .collection('starPoint')
        .document('star')
        .setData(
          _star,
          merge: true,
        );
  }
}
