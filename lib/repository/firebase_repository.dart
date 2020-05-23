import 'package:firebase_auth/firebase_auth.dart';
import 'package:gottask/models/habit.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:gottask/models/today_task.dart';
import 'package:gottask/repository/repository.dart';

class FirebaseRepository {
  final FirebaseMethods _firebaseMethods = FirebaseMethods();
  final AuthServices _authServices = AuthServices();

  /// [Auth services]
  Future<FirebaseUser> googleSignIn() => _authServices.googleSignIn();

  ///

  /// [Database uploadAll methods]
  Future<void> uploadAllHabitToFirebase(List<Habit> habitList) =>
      _firebaseMethods.uploadAllHabitToFirebase(habitList);
  Future<void> uploadAllPokemonStateToFirebase(
          List<PokemonState> pokemonStateList) =>
      _firebaseMethods.uploadAllPokemonStateToFirebase(pokemonStateList);
  Future<void> uploadAllTodoToFirebase(List<TodayTask> todoList) =>
      _firebaseMethods.uploadAllTodoToFirebase(todoList);

  /// [Upload single table]
  Future<void> updateTodoToFirebase(TodayTask todo) =>
      _firebaseMethods.updateTodoToFirebase(todo);
  Future<void> updateHabitToFirebase(Habit habit) =>
      _firebaseMethods.updateHabitToFirebase(habit);
  Future<void> updatePokemonStateToFirebase(PokemonState pokemonState) =>
      _firebaseMethods.updatePokemonStateToFirebase(pokemonState);
}
