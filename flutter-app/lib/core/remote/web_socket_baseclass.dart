import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import '../end_points.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ticker model  (market:miniTicker payload)
// ─────────────────────────────────────────────────────────────────────────────

class TickerUpdate {
  final String symbol;
  final double close;
  final double open;
  final double high;
  final double low;
  final double baseVolume;
  final double quoteVolume;

  const TickerUpdate({
    required this.symbol,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.baseVolume,
    required this.quoteVolume,
  });

  double get priceChangePercent =>
      open > 0 ? ((close - open) / open) * 100 : 0;

  factory TickerUpdate.fromJson(Map<String, dynamic> j) => TickerUpdate(
        symbol: j['symbol']?.toString() ?? '',
        close: (j['close'] as num?)?.toDouble() ?? 0,
        open: (j['open'] as num?)?.toDouble() ?? 0,
        high: (j['high'] as num?)?.toDouble() ?? 0,
        low: (j['low'] as num?)?.toDouble() ?? 0,
        baseVolume: (j['baseVolume'] as num?)?.toDouble() ?? 0,
        quoteVolume: (j['quoteVolume'] as num?)?.toDouble() ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardSocket  — Socket.IO client for live dashboard data
// ─────────────────────────────────────────────────────────────────────────────

class DashboardSocket {
  DashboardSocket._();
  static final DashboardSocket instance = DashboardSocket._();

  sio.Socket? _socket;

  // Broadcast streams — widgets subscribe to these
  final _tickerCtrl = StreamController<List<TickerUpdate>>.broadcast();
  final _snapshotCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<TickerUpdate>> get tickerStream => _tickerCtrl.stream;
  Stream<Map<String, dynamic>> get snapshotStream => _snapshotCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null) return; // already connecting / connected

    _socket = sio.io(
      EndPoints.socketUrl,
      sio.OptionBuilder()
          .setPath(EndPoints.socketPath)
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        log('[DashboardSocket] connected');
        _subscribe();
      })
      ..on('socket:connected', (data) {
        log('[DashboardSocket] server ready: $data');
      })
      ..on('dashboard:snapshot', (data) {
        if (data is Map<String, dynamic>) {
          _snapshotCtrl.add(data);
        }
      })
      ..on('market:miniTicker', (data) {
        if (data is List) {
          final tickers = data
              .whereType<Map<String, dynamic>>()
              .map(TickerUpdate.fromJson)
              .toList();
          if (tickers.isNotEmpty) _tickerCtrl.add(tickers);
        }
      })
      ..onDisconnect((_) => log('[DashboardSocket] disconnected'))
      ..onError((e) => log('[DashboardSocket] error: $e'))
      ..connect();
  }

  void _subscribe() {
    _socket?.emit('dashboard:subscribe', {
      'symbols': ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT'],
      'klineInterval': '1m',
      'includeSnapshot': true,
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _tickerCtrl.close();
    _snapshotCtrl.close();
  }
}