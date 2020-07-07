import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/database/todo_table.dart';
import 'package:gottask/models/model.dart';

import 'dart:async';

class FirebaseMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  FirebaseUser user;

  Future<FirebaseUser> initUser() async {
    user = await _auth.currentUser();
    return user;
  }

  void setUser(FirebaseUser user) => this.user = user;

  /// Method of [In-app purchase]
  Future<void> setRemoveAdsState(bool state) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('inapp')
        .document('remove_ads')
        .setData(
      {"buy": state},
      merge: true,
    );
  }

  Future<bool> getRemoveAdsState() async {
    DocumentSnapshot document = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('inapp')
        .document('remove_ads')
        .get();

    if (document.data == null) {
      setRemoveAdsState(false);
      return false;
    }

    return document.data["buy"];
  }

  /// Method of [Save todo delete key]
  Future<void> addDeleteTodoKey(String id) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('deleteTodos')
        .document(id)
        .setData(
      {'id': id},
      merge: true,
    );
  }

  Future<void> setDeleteTodoKey(List<String> data) async {
    data.forEach((element) async {
      await _firestore
          .collection('databases')
          .document(user.uid)
          .collection('deleteTodos')
          .document(element)
          .setData(
        {'id': element},
        merge: true,
      );
    });
  }

  Future<List<String>> getDeleteTodoKey() async {
    QuerySnapshot _snapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('deleteTodos')
        .getDocuments();
    List<String> deleteKey = [];
    _snapshot.documents.forEach((map) => deleteKey.add(map.data['id']));
    return deleteKey;
  }

  /// Method of [Todo]
  Future<void> updateTodoToFirebase(Todo todo) async {
    await TodoTable.updateOrInsertNewTodo(todo);

    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('todos')
        .document(todo.id)
        .setData(
          todo.toFirebaseMap(),
          merge: true,
        );
  }

  Future<void> uploadAllTodoToFirebase(List<Todo> todoList) async {
    todoList.forEach((todo) async {
      await _firestore
          .collection('databases')
          .document(user.uid)
          .collection('todos')
          .document(todo.id)
          .setData(
            todo.toFirebaseMap(),
            merge: true,
          );
    });
  }

  Future<void> deleteTodoOnFirebase(Todo todo) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('todos')
        .document(todo.id)
        .delete();
  }

  Future<List<Todo>> getAllTodo() async {
    QuerySnapshot _snapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('todos')
        .getDocuments();
    List<Todo> todoList = [];
    _snapshot.documents
        .forEach((map) => todoList.add(Todo.fromFirebaseMap(map.data)));
    return todoList;
  }

  Future<void> getAllTodoAndLoadToDb(TodoBloc todoBloc) async {
    QuerySnapshot _taskSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('todos')
        .getDocuments();

    todoBloc.add(InitTodoEvent());
    _taskSnapshots.documents.forEach((map) =>
        todoBloc.add(AddTodoEvent(todo: Todo.fromFirebaseMap(map.data))));
  }

  /// Method of [Save task delete key]
  Future<void> saveDeleteTaskKey(Task task) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('deleteTasks')
        .document(task.id)
        .setData(
      {'id': task.id},
      merge: true,
    );
  }

  /// Method of [Save task delete key]
  Future<void> addDeleteTaskKey(String id) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('deleteTasks')
        .document(id)
        .setData(
      {'id': id},
      merge: true,
    );
  }

  Future<void> setDeleteTaskKey(List<String> data) async {
    data.forEach((element) async {
      await _firestore
          .collection('databases')
          .document(user.uid)
          .collection('deleteTasks')
          .document(element)
          .setData(
        {'id': element},
        merge: true,
      );
    });
  }

  Future<List<String>> getDeleteTaskKey() async {
    QuerySnapshot _snapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('deleteTasks')
        .getDocuments();
    List<String> deleteKey = [];
    _snapshot.documents.forEach((map) => deleteKey.add(map.data['id']));
    return deleteKey;
  }

  /// Method of [Task]
  Future<List<Task>> getAllTask() async {
    QuerySnapshot _snapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('tasks')
        .getDocuments();
    List<Task> taskList = [];
    _snapshot.documents
        .forEach((map) => taskList.add(Task.fromFirebaseMap(map.data)));
    return taskList;
  }

  Future<void> getAllTaskAndLoadToDb(TaskBloc taskBloc) async {
    QuerySnapshot _taskSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('tasks')
        .getDocuments();

    taskBloc.add(InitTaskEvent());
    _taskSnapshots.documents.forEach((map) {
      Task task = Task.fromFirebaseMap(map.data);
      taskBloc.add(AddTaskEvent(task: task));
    });
  }

  Future<void> updateTaskToFirebase(Task task) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('tasks')
        .document(task.id)
        .setData(
          task.toFirebaseMap(),
          merge: true,
        );
  }

  Future<void> uploadAllTaskToFirebase(List<Task> taskList) async {
    taskList.forEach((task) async {
      await _firestore
          .collection('databases')
          .document(user.uid)
          .collection('tasks')
          .document(task.id)
          .setData(
            task.toFirebaseMap(),
            merge: true,
          );
    });
  }

  Future<void> deleteTaskOnFirebase(Task task) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('tasks')
        .document(task.id)
        .delete();
  }

  /// Method of [PokemonState]
  Future<void> getAllPokemonStateAndLoadToDb(
      AllPokemonBloc allPokemonBloc) async {
    QuerySnapshot _pokemonStateSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('pokemonStates')
        .getDocuments();
    allPokemonBloc.add(InitAllPokemonEvent());
    _pokemonStateSnapshots.documents.forEach((map) {
      PokemonState pokemonState = PokemonState.fromMap(map.data);
      allPokemonBloc.add(UpdatePokemonStateEvent(pokemonState: pokemonState));
    });
  }

  Future<List<PokemonState>> getAllPokemonState() async {
    QuerySnapshot _pokemonStateSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('pokemonStates')
        .getDocuments();

    List<PokemonState> res = [];

    _pokemonStateSnapshots.documents.forEach((map) {
      PokemonState pokemonState = PokemonState.fromMap(map.data);
      res.add(pokemonState);
    });

    return res;
  }

  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('pokemonStates')
        .document(pokemonState.name.toString())
        .setData(
          pokemonState.toMap(),
          merge: true,
        );
  }

  Future<void> uploadAllPokemonStateToFirebase(
      List<PokemonState> pokemonStateList) async {
    pokemonStateList.forEach((pokemonState) async {
      await _firestore
          .collection('databases')
          .document(user.uid)
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
    QuerySnapshot _favouritePokemonSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('favouritePokemon')
        .getDocuments();
    favouritePokemonBloc.add(InitFavouritePokemonEvent());
    _favouritePokemonSnapshots.documents?.forEach((map) {
      FavouritePokemon favouritePokemon = FavouritePokemon.fromMap(map.data);
      favouritePokemonBloc
          .add(UpdateFavouritePokemonEvent(favouritePokemon.pokemon));
    });
  }

  Future<FavouritePokemon> getFavouritePokemon() async {
    QuerySnapshot _favouritePokemonSnapshots = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('favouritePokemon')
        .getDocuments();

    FavouritePokemon res;

    _favouritePokemonSnapshots.documents?.forEach((map) {
      res = FavouritePokemon.fromMap(map.data);
    });

    return res;
  }

  Future<void> updateFavouritePokemon(int pokemon) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('favouritePokemon')
        .document('id')
        .setData(
      {'pokemon': pokemon},
      merge: true,
    );
  }

  /// Method of [Starpoint]
  Future<void> getStarpoint(StarBloc starBloc) async {
    DocumentSnapshot _starSnapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('starPoint')
        .document('star')
        .get();

    if (_starSnapshot.data != null)
      starBloc.add(
        SetStarEvent(
          starMap: {
            "addStar": _starSnapshot.data['addStar'] ?? 0,
            "loseStar": _starSnapshot.data['loseStar'] ?? 0,
          },
        ),
      );
  }

  Future<Map<String, int>> getOnlineStarpoint() async {
    Map<String, int> res = {
      "addStar": 0,
      "loseStar": 0,
    };
    DocumentSnapshot snapshot = await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('starPoint')
        .document('star')
        .get();

    if (snapshot.data == null) {
      updateStarpoint({"addStar": 0, "loseStar": 0});
    }
    try {
      snapshot.data.forEach((key, value) {
        res[key] = value;
      });
      return res;
    } catch (e) {
      return {"addStar": 0, "loseStar": 0};
    }
  }

  Future<void> updateStarpoint(Map<String, int> starMap) async {
    await _firestore
        .collection('databases')
        .document(user.uid)
        .collection('starPoint')
        .document('star')
        .setData(
          starMap,
          merge: true,
        );
  }
}
