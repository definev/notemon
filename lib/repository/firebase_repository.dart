import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';

class FirebaseRepository {
  static final FirebaseMethods _firebaseMethods = FirebaseMethods();
  final AuthServices _authServices = AuthServices();
  FirebaseUser _user;

  FirebaseUser get user => _user;

  /// [init]
  Future<void> initUser() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  /// [Auth services]
  Future<FirebaseUser> googleSignIn() => _authServices.googleSignIn();

  /// [Database uploadAll methods]
  Future<void> uploadAllTaskToFirebase(List<Task> taskList) =>
      _firebaseMethods.uploadAllTaskToFirebase(taskList);
  Future<void> uploadAllPokemonStateToFirebase(
          List<PokemonState> pokemonStateList) =>
      _firebaseMethods.uploadAllPokemonStateToFirebase(pokemonStateList);
  Future<void> uploadAllTodoToFirebase(List<Todo> todoList) =>
      _firebaseMethods.uploadAllTodoToFirebase(todoList);

  /// [Upload single table]
  Future<void> updateTodoToFirebase(Todo todo) =>
      _firebaseMethods.updateTodoToFirebase(todo);
  Future<void> updateTaskToFirebase(Task task) =>
      _firebaseMethods.updateTaskToFirebase(task);
  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) =>
      _firebaseMethods.updatePokemonStateToFirebase(pokemonState);

  /// [Delete]
  Future<void> deleteTaskOnFirebase(Task task) =>
      _firebaseMethods.deleteTaskOnFirebase(task);
  Future<void> deleteTodoOnFirebase(Todo todo) =>
      _firebaseMethods.deleteTodoOnFirebase(todo);

  /// [Favourite pokemon]
  Future<void> updateFavouritePokemon(int pokemon) =>
      _firebaseMethods.updateFavouritePokemon(pokemon);
}
