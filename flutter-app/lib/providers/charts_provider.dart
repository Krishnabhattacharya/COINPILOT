import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:candlesticks/candlesticks.dart';
import '../core/remote/api_client.dart';
import '../core/remote/web_socket_baseclass.dart';
import '../core/end_points.dart';

class ChartsNotifier extends ChangeNotifier {
  String _selectedCoin = 'BTC';
  String _timeframe = '4H';
  String _indicator = 'RSI';
  String _chartType = 'Candle'; // 'Candle', 'Line', 'Bar'
  
  bool _drawActive = false;
  bool _trendActive = false;
  bool _fibActive = false;
  bool _aiOverlayActive = true;
  bool _isFullscreen = false;

  List<Candle> _candles = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<KlineUpdate>? _klineSubscription;
  bool _tickToggle = false;

  ChartsNotifier() {
    _initSocketListener();
    loadCandles();
  }

  // Getters
  String get selectedCoin => _selectedCoin;
  String get timeframe => _timeframe;
  String get indicator => _indicator;
  String get chartType => _chartType;
  
  bool get drawActive => _drawActive;
  bool get trendActive => _trendActive;
  bool get fibActive => _fibActive;
  bool get aiOverlayActive => _aiOverlayActive;
  bool get isFullscreen => _isFullscreen;

  List<Candle> get candles => _candles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get tickToggle => _tickToggle;

  // Actions
  void setCoin(String coin) {
    debugPrint('ChartsNotifier: setCoin called with: $coin (previous: $_selectedCoin)');
    if (_selectedCoin == coin) return;
    _selectedCoin = coin;
    notifyListeners();
    loadCandles();
  }

  void setTimeframe(String t) {
    if (_timeframe == t) return;
    _timeframe = t;
    notifyListeners();
    loadCandles();
  }

  void setIndicator(String i) {
    if (_indicator == i) return;
    _indicator = i;
    notifyListeners();
  }

  void setChartType(String t) {
    if (_chartType == t) return;
    _chartType = t;
    notifyListeners();
  }

  void toggleDrawActive() {
    _drawActive = !_drawActive;
    if (_drawActive) {
      _trendActive = false;
      _fibActive = false;
    }
    notifyListeners();
  }

  void toggleTrendActive() {
    _trendActive = !_trendActive;
    if (_trendActive) {
      _drawActive = false;
      _fibActive = false;
    }
    notifyListeners();
  }

  void toggleFibActive() {
    _fibActive = !_fibActive;
    if (_fibActive) {
      _drawActive = false;
      _trendActive = false;
    }
    notifyListeners();
  }

  void toggleAiOverlayActive() {
    _aiOverlayActive = !_aiOverlayActive;
    notifyListeners();
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  // Fetch candlestick history
  Future<void> loadCandles() async {
    debugPrint('ChartsNotifier: loadCandles starting for $_selectedCoin on timeframe $_timeframe');
    _isLoading = true;
    _errorMessage = null;
    _candles = []; // Clear current candles to force a clean loading view in the UI
    notifyListeners();

    try {
      final symbol = '${_selectedCoin}USDT';
      final interval = _mapTimeframe(_timeframe);

      debugPrint('ChartsNotifier: Updating socket kline subscription to symbol: $symbol, interval: $interval');
      // Make sure socket subscription is updated for live ticks
      DashboardSocket.instance.subscribeWithInterval(symbol, interval);

      final url = EndPoints.klinesWithParams(
        symbol: symbol,
        interval: interval,
        limit: 100,
      );

      debugPrint('ChartsNotifier: Fetching candlestick data from: $url');
      final response = await ApiClient.instance.get(url);
      final raw = response.data;
      debugPrint('ChartsNotifier: Received response from backend for $_selectedCoin. Success: ${raw?['success']}');

      if (raw is Map<String, dynamic> && raw['success'] == true) {
        final list = raw['data'] as List? ?? [];
        _candles = list.map((k) {
          final row = k as List;
          return Candle(
            date: DateTime.fromMillisecondsSinceEpoch(row[0] as int),
            open: double.parse(row[1].toString()),
            high: double.parse(row[2].toString()),
            low: double.parse(row[3].toString()),
            close: double.parse(row[4].toString()),
            volume: double.parse(row[5].toString()),
          );
        }).toList().reversed.toList();
        debugPrint('ChartsNotifier: Successfully parsed ${_candles.length} candles for $_selectedCoin');
      } else {
        _errorMessage = 'Invalid data response from backend';
        debugPrint('ChartsNotifier: Error response from backend: $raw');
      }
    } catch (e, stack) {
      _errorMessage = 'Failed to load chart data: ${e.toString()}';
      debugPrint('ChartsNotifier: Exception in loadCandles: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initSocketListener() {
    // Safety check to ensure socket connection is running
    DashboardSocket.instance.connect();
    
    _klineSubscription = DashboardSocket.instance.klineStream.listen((update) {
      final activeSymbol = '${_selectedCoin}USDT';
      final activeInterval = _mapTimeframe(_timeframe);

      debugPrint('ChartsNotifier: klineStream received tick for ${update.symbol} (${update.interval}). Active: $activeSymbol ($activeInterval)');

      if (update.symbol == activeSymbol && update.interval == activeInterval) {
        _onKlineTick(update);
      }
    });
  }

  void _onKlineTick(KlineUpdate tick) {
    debugPrint('ChartsNotifier: _onKlineTick called. Candles length: ${_candles.length}');
    if (_candles.isEmpty) return;

    final dateMs = _candles.first.date.millisecondsSinceEpoch;
    debugPrint('ChartsNotifier: _onKlineTick - tick.openTime: ${tick.openTime}, dateMs: $dateMs');

    if (tick.openTime == dateMs) {
      debugPrint('ChartsNotifier: _onKlineTick - UPDATING existing candle at index 0');
      // Recreate list reference to force Flutter UI repaints on ticks!
      final newCandles = List<Candle>.from(_candles);
      newCandles[0] = Candle(
        date: _candles.first.date,
        open: tick.open,
        high: tick.high,
        low: tick.low,
        close: tick.close,
        volume: tick.volume,
      );
      _candles = newCandles;
      _tickToggle = !_tickToggle;
      notifyListeners();
    } else if (tick.openTime > dateMs) {
      debugPrint('ChartsNotifier: _onKlineTick - INSERTING new candle at index 0');
      // Recreate list reference to force Flutter UI repaints on new candles!
      final newCandles = List<Candle>.from(_candles);
      newCandles.insert(
        0,
        Candle(
          date: DateTime.fromMillisecondsSinceEpoch(tick.openTime),
          open: tick.open,
          high: tick.high,
          low: tick.low,
          close: tick.close,
          volume: tick.volume,
        ),
      );
      if (newCandles.length > 100) {
        newCandles.removeLast();
      }
      _candles = newCandles;
      _tickToggle = !_tickToggle;
      notifyListeners();
    } else {
      debugPrint('ChartsNotifier: _onKlineTick - tick.openTime (${tick.openTime}) is older than dateMs ($dateMs), ignoring.');
    }
  }

  String _mapTimeframe(String tf) {
    switch (tf) {
      case '1H': return '1h';
      case '4H': return '4h';
      case '1D': return '1d';
      case '1W': return '1w';
      default: return tf;
    }
  }

  @override
  void dispose() {
    _klineSubscription?.cancel();
    super.dispose();
  }
}

final chartsProvider = ChangeNotifierProvider(
  (ref) => ChartsNotifier(),
);
