import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertsNotifier extends ChangeNotifier {
  final Map<String, bool> _switches = {
    'Funding Rate Spikes': true,
    'Whale Alerts (\$5M+)': true,
    'Volatility Burst': false,
    'Sentiment Change': true,
    'New Listings': true,
    'Price Targets': true,
  };

  Map<String, bool> get switches => Map.unmodifiable(_switches);

  void toggle(String key, bool value) {
    if (_switches[key] == value) return;
    _switches[key] = value;
    notifyListeners();
  }
}

final alertsProvider = ChangeNotifierProvider.autoDispose(
  (ref) => AlertsNotifier(),
);
