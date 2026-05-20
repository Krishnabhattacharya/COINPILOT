import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartsNotifier extends ChangeNotifier {
  String _timeframe = '4H';
  String _indicator = 'RSI';

  String get timeframe => _timeframe;
  String get indicator => _indicator;

  void setTimeframe(String t) {
    if (_timeframe == t) return;
    _timeframe = t;
    notifyListeners();
  }

  void setIndicator(String i) {
    if (_indicator == i) return;
    _indicator = i;
    notifyListeners();
  }
}

final chartsProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ChartsNotifier(),
);
