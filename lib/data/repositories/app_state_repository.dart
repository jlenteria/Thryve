import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_state.dart';

/// Loads and saves [AppState] as a single JSON document in
/// SharedPreferences. Writes are serialized so a slow write can never land
/// after (and overwrite) a newer one.
class AppStateRepository {
  Future<void> _pendingWrite = Future<void>.value();

  Future<AppState> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(AppConstants.stateKey);
    if (encoded == null) {
      return const AppState();
    }
    try {
      return AppState.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
    } on Object catch (error) {
      // Never crash on corrupt local data; start fresh but keep the raw
      // payload so it can be recovered manually if needed.
      debugPrint('Thryve: could not read saved state ($error).');
      await prefs.setString('${AppConstants.stateKey}.corrupt', encoded);
      return const AppState();
    }
  }

  Future<void> save(AppState state) {
    final String encoded = jsonEncode(state.toJson());
    return _pendingWrite = _pendingWrite.then((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.stateKey, encoded);
    });
  }

  /// Completes once every queued write has reached disk.
  Future<void> flush() => _pendingWrite;

  Future<void> clear() async {
    await _pendingWrite;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.stateKey);
  }
}
