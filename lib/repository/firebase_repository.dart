import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/bloc/all_pokemon/bloc/all_pokemon_bloc.dart';
import 'package:gottask/bloc/favourite_pokemon/bloc/favourite_pokemon_bloc.dart';
import 'package:gottask/bloc/star/bloc/star_bloc.dart';
import 'package:gottask/bloc/task/bloc/task_bloc.dart';
import 'package:gottask/models/task.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/models/todo.dart';
import 'package:gottask/repository/repository.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();
  final AuthServices _authServices = AuthServices();
  FirebaseUser _user;

  FirebaseUser get user => _user;

  FirebaseAuth get firebaseAuthInstance => FirebaseAuth.instance;

  Firestore get firestoreInstance => Firestore.instance;

  /// [init] methods
  Future<void> initUser() async =>
      _user = await FirebaseAuth.instance.currentUser();

  /// [Auth services] methods
  Future<FirebaseUser> googleSignIn() => _authServices.googleSignIn();

  /// [Task] methods
  Future<void> uploadAllTaskToFirebase(List<Task> taskList) =>
      _firebaseMethods.uploadAllTaskToFirebase(taskList);
  Future<void> updateTaskToFirebase(Task task) =>
      _firebaseMethods.updateTaskToFirebase(task);
  Future<void> deleteTaskOnFirebase(Task task) =>
      _firebaseMethods.deleteTaskOnFirebase(task);
  Future<void> getAllTaskAndLoadToDb(TaskBloc taskBloc) =>
      _firebaseMethods.getAllTaskAndLoadToDb(taskBloc);

  /// [Todo] methods
  Future<void> uploadAllTodoToFirebase(List<Todo> todoList) =>
      _firebaseMethods.uploadAllTodoToFirebase(todoList);
  Future<void> updateTodoToFirebase(Todo todo) =>
      _firebaseMethods.updateTodoToFirebase(todo);
  Future<void> deleteTodoOnFirebase(Todo todo) =>
      _firebaseMethods.deleteTodoOnFirebase(todo);

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
