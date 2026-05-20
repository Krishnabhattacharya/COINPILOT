import 'models/dashboard_models.dart';

abstract class DashboardRepo {
  Future<DashboardSummary> fetchSummary();
  Future<List<MarketCoin>> fetchMarketCoins();
  Future<FearGreedData> fetchFearGreed();
  Future<List<TrendingCoin>> fetchTrending();
  Future<List<FundingRate>> fetchFundingRates();
}