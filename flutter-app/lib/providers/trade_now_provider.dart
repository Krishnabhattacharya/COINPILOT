import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/remote/data/trade_now/trade_now_repo_impl.dart';
import '../core/remote/data/trade_now/models/trade_now_models.dart';

final _repo = TradeNowRepoImpl();

/// Fetches all 6 Trade Now endpoints in parallel for [symbol] (e.g. "BTC").
/// Keyed by symbol so each coin caches independently.
final tradeNowProvider =
    FutureProvider.family<TradeNowData, String>((ref, symbol) async {
  final results = await Future.wait([
    _repo.fetchSignal(symbol),
    _repo.fetchSentiment(symbol),
    _repo.fetchOpenInterest(symbol),
    _repo.fetchLongShort(symbol),
    _repo.fetchLiquidations(symbol),
    _repo.fetchFundingRate(symbol),
    _repo.fetchHistory(symbol),
  ]);

  return TradeNowData(
    signal: results[0] as SignalData,
    sentiment: results[1] as SentimentData,
    openInterest: results[2] as OpenInterestData,
    longShort: results[3] as LongShortData,
    liquidations: results[4] as LiquidationData,
    funding: results[5] as FundingRateInfo,
    history: results[6] as List<HistoricalSetup>,
  );
});