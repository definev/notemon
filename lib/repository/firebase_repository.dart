import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/bloc/bloc.dart';
import 'package:gottask/models/model.dart';
import 'package:gottask/repository/repository.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();
  final AuthServices _authServices = AuthServices();
  Firestore firestore = Firestore.instance;
  FirebaseUser get user => _firebaseMethods.user;

  FirebaseAuth get firebaseAuthInstance => FirebaseAuth.instance;

  Firestore get firestoreInstance => Firestore.instance;

  /// [init] methods
  Future<void> initUser() => _firebaseMethods.initUser();

  /// [Auth services] methods
  Future<FirebaseUser> googleSignIn() => _authServices.googleSignIn();

  /// [Task] methods
  Future<void> uploadAllTaskToFirebase(List<Task> taskList) =>
      _firebaseMethods.uploadAllTaskToFirebase(taskList);
  Future<void> updateTaskToFirebase(Task task) =>
      _firebaseMethods.updateTaskToFirebase(task);
  Future<void> deleteTaskOnFirebase(Task task) async {
    await _firebaseMethods.deleteTaskOnFirebase(task);
    await _firebaseMethods.addDeleteTaskKey(task.id);
  }

  Future<void> getAllTaskAndLoadToDb(TaskBloc taskBloc) =>
      _firebaseMethods.getAllTaskAndLoadToDb(taskBloc);
  Future<List<Task>> getAllTask() => _firebaseMethods.getAllTask();
  Future<void> setDeleteTaskKey(List<String> data) =>
      _firebaseMethods.setDeleteTaskKey(data);

  Future<List<String>> getDeleteTaskKey() =>
      _firebaseMethods.getDeleteTaskKey();

  /// [Todo] methods
  Future<void> uploadAllTodoToFirebase(List<Todo> todoList) =>
      _firebaseMethods.uploadAllTodoToFirebase(todoList);
  Future<void> updateTodoToFirebase(Todo todo) =>
      _firebaseMethods.updateTodoToFirebase(todo);
  Future<List<Todo>> getAllTodo() => _firebaseMethods.getAllTodo();
  Future<void> deleteTodoOnFirebase(Todo todo) async {
    await _firebaseMethods.deleteTodoOnFirebase(todo);
    await _firebaseMethods.addDeleteTodoKey(todo.id);
  }

  Future<void> deleteTodoOnFirebaseNotAddDeleteKey(Todo todo) =>
      _firebaseMethods.deleteTodoOnFirebase(todo);

  Future<void> setDeleteTodoKey(List<String> data) =>
      _firebaseMethods.setDeleteTodoKey(data);

  Future<List<String>> getDeleteTodoKey() =>
      _firebaseMethods.getDeleteTodoKey();
  Future<void> getAllTodoAndLoadToDb(TodoBloc todoBloc) =>
      _firebaseMethods.getAllTodoAndLoadToDb(todoBloc);

  /// [PokemonState] methods
  Future<void> getAllPokemonStateAndLoadToDb(AllPokemonBloc allPokemonBloc) =>
      _firebaseMethods.getAllPokemonStateAndLoadToDb(allPokemonBloc);
  Future<void> uploadAllPokemonStateToFirebase(
          List<PokemonState> pokemonStateList) =>
      _firebaseMethods.uploadAllPokemonStateToFirebase(pokemonStateList);
  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) =>
      _firebaseMethods.updatePokemonStateToFirebase(pokemonState);

  /// [Favourite pokemon] methods
  Future<void> getFavouritePokemonStateAndLoadToDb(
          FavouritePokemonBloc favouritePokemonBloc) =>
      _firebaseMethods
          .getFavouritePokemonStateAndLoadToDb(favouritePokemonBloc);
  Future<void> updateFavouritePokemon(int pokemon) =>
      _firebaseMethods.updateFavouritePokemon(pokemon);

  /// [Starpoint] methods
  Future<void> getStarpoint(StarBloc starBloc) =>
      _firebaseMethods.getStarpoint(starBloc);
  Future<void> updateStarpoint(int currentStar) =>
      _firebaseMethods.updateStarpoint(currentStar);
}
