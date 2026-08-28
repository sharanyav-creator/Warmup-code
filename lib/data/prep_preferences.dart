import 'package:shared_preferences/shared_preferences.dart';

const _skipPrepKey = 'skip_prep';

/// Whether the user has chosen to skip the "think time" prep step and go
/// straight to the speech recording. Persisted so the choice sticks across
/// sessions once set.
class PrepPreferences {
  Future<bool> getSkipPrep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skipPrepKey) ?? false;
  }

  Future<void> setSkipPrep(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skipPrepKey, value);
  }
}
