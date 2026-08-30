import 'package:shared_preferences/shared_preferences.dart';

const _displayNameKey = 'display_name';
const _defaultDisplayName = 'there';

/// Persists the name the user entered when creating their account, so it can
/// replace the placeholder name shown across Home, Profile, etc.
class UserProfile {
  Future<String> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey) ?? _defaultDisplayName;
  }

  Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
  }
}
