import 'package:shared_preferences/shared_preferences.dart';

import 'tracks_catalog.dart';

const _activeTrackIdsKey = 'active_track_ids';

/// Persists which tracks the user has added to "Your Tracks" beyond the defaults.
class TracksRepository {
  Future<List<String>> getActiveTrackIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_activeTrackIdsKey) ?? defaultActiveTrackIds;
  }

  Future<void> addTrack(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_activeTrackIdsKey) ?? defaultActiveTrackIds;
    if (current.contains(id)) return;
    await prefs.setStringList(_activeTrackIdsKey, [...current, id]);
  }
}
