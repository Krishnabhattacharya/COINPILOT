import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends ChangeNotifier {
  bool _darkMode = true;
  bool _notifications = true;
  bool _twoFA = false;
  String _aiPersonality = 'Direct';

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get twoFA => _twoFA;
  String get aiPersonality => _aiPersonality;

  void setDarkMode(bool v) {
    if (_darkMode == v) return;
    _darkMode = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    if (_notifications == v) return;
    _notifications = v;
    notifyListeners();
  }

  void setTwoFA(bool v) {
    if (_twoFA == v) return;
    _twoFA = v;
    notifyListeners();
  }

  void setAiPersonality(String v) {
    if (_aiPersonality == v) return;
    _aiPersonality = v;
    notifyListeners();
  }
}

// Not autoDispose — settings persist across navigation
final profileProvider = ChangeNotifierProvider(
  (ref) => ProfileNotifier(),
);
