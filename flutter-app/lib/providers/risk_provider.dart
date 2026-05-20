import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';

class RiskNotifier extends ChangeNotifier {
  double _capital = 10000;
  double _leverage = 5;
  double _riskPercent = 2;
  double _entryPrice = 97420;
  double _stopLoss = 95000;

  double get capital => _capital;
  double get leverage => _leverage;
  double get riskPercent => _riskPercent;
  double get entryPrice => _entryPrice;
  double get stopLoss => _stopLoss;

  // Computed values — derived from state, no extra notifyListeners needed
  double get positionSize => _capital * _riskPercent / 100;
  double get liquidationDistance => 100 / _leverage;
  double get liquidationPrice => _entryPrice - (_entryPrice * liquidationDistance / 100);
  double get riskInDollars => _capital * _riskPercent / 100;
  String get riskLevel =>
      _leverage <= 3 ? 'Conservative' : _leverage <= 7 ? 'Moderate' : 'High Risk';
  Color get riskColor => _leverage <= 3
      ? AppColors.brandGreen
      : _leverage <= 7
          ? AppColors.brandAmber
          : AppColors.brandRed;

  void setCapital(double v) {
    if (_capital == v) return;
    _capital = v;
    notifyListeners();
  }

  void setLeverage(double v) {
    if (_leverage == v) return;
    _leverage = v;
    notifyListeners();
  }

  void setRiskPercent(double v) {
    if (_riskPercent == v) return;
    _riskPercent = v;
    notifyListeners();
  }

  void setEntryPrice(double v) {
    if (_entryPrice == v) return;
    _entryPrice = v;
    notifyListeners();
  }

  void setStopLoss(double v) {
    if (_stopLoss == v) return;
    _stopLoss = v;
    notifyListeners();
  }
}

final riskProvider = ChangeNotifierProvider.autoDispose(
  (ref) => RiskNotifier(),
);
