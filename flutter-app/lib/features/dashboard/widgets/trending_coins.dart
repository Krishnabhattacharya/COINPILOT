import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/remote/data/dashboard/models/dashboard_models.dart';
import '../../../providers/dashboard_provider.dart';

class TrendingCoins extends ConsumerWidget {
  const TrendingCoins({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendingProvider);
    return async.when(
      loading: _buildShimmer,
      error: (_, __) => _buildContent(_fallback),
      data: (coins) => _buildContent(coins.isNotEmpty ? coins : _fallback),
    );
  }

  static Widget _buildShimmer() => Shimmer.fromColors(
    baseColor: AppColors.bgCard,
    highlightColor: AppColors.bgTertiary,
    child: Container(
      height: 200,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    ),
  );

  static Widget _buildContent(List<TrendingCoin> coins) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Trending', subtitle: 'Most searched · Last 24h'),
          const SizedBox(height: 12),
          ...coins.take(6).toList().asMap().entries.map((e) =>
            _TrendingRow(rank: e.key + 1, coin: e.value)),
        ],
      ),
    );
  }

  static final _fallback = [
    const TrendingCoin(id: 'bitcoin',  symbol: 'BTC',  name: 'Bitcoin',     priceChange24h: 2.4),
    const TrendingCoin(id: 'solana',   symbol: 'SOL',  name: 'Solana',      priceChange24h: -0.9),
    const TrendingCoin(id: 'pepe',     symbol: 'PEPE', name: 'Pepe',        priceChange24h: 18.2),
    const TrendingCoin(id: 'arweave',  symbol: 'AR',   name: 'Arweave',     priceChange24h: 42.0),
    const TrendingCoin(id: 'ondo',     symbol: 'ONDO', name: 'Ondo Finance', priceChange24h: 8.7),
    const TrendingCoin(id: 'dogwifhat',symbol: 'WIF',  name: 'Dogwifhat',   priceChange24h: -3.2),
  ];
}

class _TrendingRow extends StatelessWidget {
  final int rank;
  final TrendingCoin coin;
  const _TrendingRow({super.key, required this.rank, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text('#$rank',
              style: const TextStyle(
                fontSize: 10, color: AppColors.textDisabled, fontFamily: 'JetBrainsMono')),
          ),
          const SizedBox(width: 8),
          Text(coin.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coin.symbol,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(coin.name,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (coin.positive ? AppColors.brandGreen : AppColors.brandRed).withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(coin.formattedChange,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'JetBrainsMono',
                color: coin.positive ? AppColors.brandGreen : AppColors.brandRed,
              )),
          ),
        ],
      ),
    );
  }
}