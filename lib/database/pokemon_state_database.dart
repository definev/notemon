import 'package:gottask/database/pokemon_state_table.dart';
import 'package:gottask/utils/utils.dart';
import 'package:gottask/models/pokemon_state.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PokemonStateDatabase {
  static const DB_NAME = 'pokemonstatedb.db';
  static const DB_VERSION = 1;
  static Database _database;

  PokemonStateDatabase._internal();
  static final PokemonStateDatabase instance = PokemonStateDatabase._internal();

  Database get database => _database;

  static const initScripts = [PokemonStateTable.CREATE_TABLE_QUERY];
  static const migrationScripts = [];

  init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) {
        initScripts.forEach((script) async => await db.execute(script));
      },
      onUpgrade: (db, oldVersion, newVersion) {
        migrationScripts.forEach((script) async => await db.execute(script));
      },
      version: DB_VERSION,
    );
    if (await isInitDatabase() == false) {
      for (int i = 0; i < pokedex.length; i++) {
        PokemonStateTable.insertPokemonState(
          PokemonState(
            name: pokedex[i]['name'],
            state: 0,
          ),
        );
      }
    }
  }
}
