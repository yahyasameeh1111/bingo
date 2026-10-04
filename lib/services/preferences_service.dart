import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyOnboarding = 'bingo_onboarding_completed';
  static const String _keyReadNotifications = 'bingo_read_notifications';
  static const String _keyThemeMode = 'bingo_theme_mode';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  static Future<PreferencesService> init() => create();

  bool get isOnboardingCompleted => _prefs.getBool(_keyOnboarding) ?? false;

  Future<void> setOnboardingCompleted(bool val) async {
    await _prefs.setBool(_keyOnboarding, val);
  }

  Set<String> getReadNotifications() {
    final list = _prefs.getStringList(_keyReadNotifications) ?? [];
    return list.toSet();
  }

  Future<void> markNotificationRead(String id) async {
    final current = getReadNotifications();
    current.add(id);
    await _prefs.setStringList(_keyReadNotifications, current.toList());
  }

  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'light';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }
}
