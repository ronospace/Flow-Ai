import 'package:shared_preferences/shared_preferences.dart';

class PendingInviteStore {
  static const _kKey = 'pending_invite_code';

  Future<void> set(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, code);
  }

  Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kKey);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
