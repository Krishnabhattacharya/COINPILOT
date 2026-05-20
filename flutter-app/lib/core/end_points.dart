class EndPoints {
  EndPoints._();

  // ─────────────────────────────────────────────────────────────
  // Backend Base URLs
  // ─────────────────────────────────────────────────────────────

  static const String baseUrl = 'https://had-pampers-haste.ngrok-free.dev';
  static const String apiBaseUrl = '$baseUrl/api/v1';
  static const String dashboardBaseUrl = '$apiBaseUrl/dashboard';

  // Socket.IO
  static const String socketUrl = baseUrl;
  static const String socketPath = '/socket.io';

  // ─────────────────────────────────────────────────────────────
  // Auth / Token
  // ─────────────────────────────────────────────────────────────

  static const String generateNewToken = '$apiBaseUrl/token/generate';

  // ─────────────────────────────────────────────────────────────
  // Dashboard REST APIs
  // ─────────────────────────────────────────────────────────────

  static const String dashboardSummary = '$dashboardBaseUrl/summary';

  static const String marketCoins = '$dashboardBaseUrl/markets';

  static const String trendingCoins = '$dashboardBaseUrl/trending';

  static const String globalMarket = '$dashboardBaseUrl/global';

  static const String fearGreedIndex = '$dashboardBaseUrl/fear-greed';

  static const String klines = '$dashboardBaseUrl/klines';

  static const String orderBook = '$dashboardBaseUrl/order-book';

  static const String ticker24hr = '$dashboardBaseUrl/ticker-24hr';

  static const String exchangeInfo = '$dashboardBaseUrl/exchange-info';

  static const String fundingRates = '$dashboardBaseUrl/funding-rates';

  // ─────────────────────────────────────────────────────────────
  // Dynamic Dashboard APIs
  // ─────────────────────────────────────────────────────────────

  static String coinDetails(String coinId) {
    return '$dashboardBaseUrl/coins/$coinId';
  }

  static String coinOhlc(String coinId) {
    return '$dashboardBaseUrl/coins/$coinId/ohlc';
  }

  // ─────────────────────────────────────────────────────────────
  // Query Helpers
  // ─────────────────────────────────────────────────────────────

  static String dashboardSummaryWithParams({
    String coinIds = 'bitcoin,ethereum,solana,binancecoin',
    String symbols = 'BTCUSDT,ETHUSDT,SOLUSDT,BNBUSDT',
  }) {
    return '$dashboardSummary?coinIds=$coinIds&symbols=$symbols';
  }

  static String marketCoinsWithParams({
    String? ids,
    String vsCurrency = 'usd',
    int perPage = 20,
    int page = 1,
    bool sparkline = true,
  }) {
    final query = <String, String>{
      if (ids != null && ids.isNotEmpty) 'ids': ids,
      'vsCurrency': vsCurrency,
      'perPage': perPage.toString(),
      'page': page.toString(),
      'sparkline': sparkline.toString(),
    };

    return Uri.parse(marketCoins).replace(queryParameters: query).toString();
  }

  static String klinesWithParams({
    required String symbol,
    String interval = '1h',
    int limit = 100,
  }) {
    return Uri.parse(klines).replace(
      queryParameters: {
        'symbol': symbol,
        'interval': interval,
        'limit': limit.toString(),
      },
    ).toString();
  }

  static String orderBookWithParams({
    required String symbol,
    int limit = 50,
  }) {
    return Uri.parse(orderBook).replace(
      queryParameters: {
        'symbol': symbol,
        'limit': limit.toString(),
      },
    ).toString();
  }

  static String ticker24hrWithParams({
    String? symbol,
  }) {
    return Uri.parse(ticker24hr).replace(
      queryParameters: {
        if (symbol != null && symbol.isNotEmpty) 'symbol': symbol,
      },
    ).toString();
  }

  static String exchangeInfoWithParams({
    String? symbol,
  }) {
    return Uri.parse(exchangeInfo).replace(
      queryParameters: {
        if (symbol != null && symbol.isNotEmpty) 'symbol': symbol,
      },
    ).toString();
  }

  static String fundingRatesWithSymbol({
    required String symbol,
    int limit = 10,
  }) {
    return Uri.parse(fundingRates).replace(
      queryParameters: {
        'symbol': symbol,
        'limit': limit.toString(),
      },
    ).toString();
  }

  static String fundingRatesWithSymbols({
    required List<String> symbols,
  }) {
    return Uri.parse(fundingRates).replace(
      queryParameters: {
        'symbols': symbols.join(','),
      },
    ).toString();
  }

  static String fearGreedWithParams({
    int limit = 30,
  }) {
    return Uri.parse(fearGreedIndex).replace(
      queryParameters: {
        'limit': limit.toString(),
      },
    ).toString();
  }

  static String coinOhlcWithParams({
    required String coinId,
    String vsCurrency = 'usd',
    int days = 1,
  }) {
    return Uri.parse(coinOhlc(coinId)).replace(
      queryParameters: {
        'vsCurrency': vsCurrency,
        'days': days.toString(),
      },
    ).toString();
  }
}
