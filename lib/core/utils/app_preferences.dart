import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._(this._prefs, this._userId);

  static const String _migratedUsersKey = '_migrated_legacy_users';
  static const List<String> _legacyUserKeys = [
    'userName',
    'userEmail',
    'userPhone',
    'userGender',
    'userBirthDate',
    'userCurrency',
    'userStartDate',
    'parcela',
    'seguro',
    'ipva',
    'manutencao',
    'outros',
    'lancamentos',
    'metaDiaria',
    'metaSemanal',
    'metaMensal',
  ];

  final SharedPreferences _prefs;
  final String? _userId;

  static Future<AppPreferences> load({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedPrefs = AppPreferences._(
      prefs,
      userId ?? _currentUserIdOrNull(),
    );
    await scopedPrefs._migrateLegacyDataIfNeeded();
    return scopedPrefs;
  }

  static String? _currentUserIdOrNull() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> _migrateLegacyDataIfNeeded() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    final migratedUsers = _prefs.getStringList(_migratedUsersKey) ?? const [];
    if (migratedUsers.contains(userId)) {
      return;
    }

    final hasScopedData = _legacyUserKeys.any(containsKey);
    final hasLegacyData = _legacyUserKeys.any(_prefs.containsKey);

    if (!hasScopedData && hasLegacyData) {
      for (final key in _legacyUserKeys) {
        if (!_prefs.containsKey(key)) {
          continue;
        }

        final value = _prefs.get(key);
        if (value is String) {
          await setString(key, value);
        } else if (value is bool) {
          await setBool(key, value);
        } else if (value is int) {
          await setInt(key, value);
        } else if (value is double) {
          await setDouble(key, value);
        } else if (value is List<Object?>) {
          await setStringList(
            key,
            value.whereType<String>().toList(growable: false),
          );
        }
      }
    }

    await _prefs.setStringList(_migratedUsersKey, [...migratedUsers, userId]);
  }

  String _scopeKey(String key) {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return key;
    }

    return 'user:$userId:$key';
  }

  bool containsKey(String key) => _prefs.containsKey(_scopeKey(key));

  bool? getBool(String key) => _prefs.getBool(_scopeKey(key));

  double? getDouble(String key) => _prefs.getDouble(_scopeKey(key));

  int? getInt(String key) => _prefs.getInt(_scopeKey(key));

  Object? get(String key) => _prefs.get(_scopeKey(key));

  String? getString(String key) => _prefs.getString(_scopeKey(key));

  List<String>? getStringList(String key) =>
      _prefs.getStringList(_scopeKey(key));

  Future<bool> remove(String key) => _prefs.remove(_scopeKey(key));

  Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(_scopeKey(key), value);

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(_scopeKey(key), value);

  Future<bool> setInt(String key, int value) =>
      _prefs.setInt(_scopeKey(key), value);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(_scopeKey(key), value);

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(_scopeKey(key), value);
}
