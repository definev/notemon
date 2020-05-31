import 'package:gottask/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> currentStartState() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_start_key";
  final res = prefs.getBool(key) ?? false;
  return res;
}

Future<bool> updateStartState() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_start_key";
  prefs.setBool(key, true);
  return prefs.getBool(key);
}

Future<bool> currentLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_login_key";
  final res = prefs.getBool(key) ?? false;
  return res;
}

Future<bool> updateLoginState(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_login_key";
  prefs.setBool(key, value);
  return prefs.getBool(key);
}

Future<int> currentFavouritePokemon() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_favourite_pokemon_key";
  final res = prefs.getInt(key) ?? -1;
  return res;
}

Future<int> updateFavouritePokemon(int newPokemon) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_favourite_pokemon_key";
  prefs.setInt(key, newPokemon);
  return prefs.getInt(key);
}

Future<HandSide> currentHandSide() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_handside_key";
  final res = prefs.getInt(key) ?? 0;
  if (res == 0) return HandSide.Left;
  return HandSide.Right;
}

Future<int> updateHandSide(HandSide handSide) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_handside_key";
  handSide == HandSide.Left ? prefs.setInt(key, 0) : prefs.setInt(key, 1);
  return prefs.getInt(key);
}

Future<int> setStar(int star) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_star_key";
  prefs.setInt(key, star);
  return star;
}

Future<int> currentStar() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_star_key";
  if (prefs.getInt(key) == null) prefs.setInt(key, 0);
  final value = prefs.getInt(key);
  return value;
}

Future<int> getStar(int value) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_star_key";
  final res = prefs.getInt(key) + value;
  prefs.setInt(key, res);
  return value;
}

Future<int> loseStar(int value) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_star_key";
  final res = prefs.getInt(key) - value;
  prefs.setInt(key, res);
  return value;
}

Future<bool> isInitDatabase() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "is_init_database_key";
  if (prefs.getBool(key) == null) {
    prefs.setBool(key, true);
    return false;
  } else {
    return true;
  }
}

Future<int> savePetState(int value) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_pet_key";
  prefs.setInt(key, value);
  return value;
}

Future<int> readPetState() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_pet_key";
  final value = prefs.getInt(key) != null ? prefs.getInt(key) : -1;
  return value;
}

Future<void> setTime() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_time_open_app_key";
  final value = DateTime.now().toString();
  prefs.setString(key, value);
}

Future<String> readTime() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_time_open_app_key";
  final value = prefs.getString(key);
  return value;
}

Future<void> resetVideoReward() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_video_reward_key";
  final value = 0;
  prefs.setInt(key, value);
}

Future<void> updateVideoReward() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_video_reward_key";
  final value = prefs.getInt(key) ?? 0;
  prefs.setInt(key, value);
}

Future<int> getVideoReward() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_video_reward_key";
  final value = prefs.getInt(key) ?? 0;
  return value;
}

Future<void> setLoadAdsInfirst(bool val) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_load_ads_in_first_key";
  final value = prefs.getBool(key) ?? false;
  prefs.setBool(key, value);
}

Future<bool> getLoadAdsInfirst() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "my_load_ads_in_first_key";
  final value = prefs.getBool(key) ?? false;
  return value;
}
