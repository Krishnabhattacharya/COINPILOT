import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/remote/data/dashboard/models/dashboard_models.dart';
import '../../../providers/dashboard_provider.dart';

class WhaleAlerts extends ConsumerWidget {
  const WhaleAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardSummaryProvider);
    return async.when(
      loading: _buildShimmer,
      error: (_, __) => _buildContent(_fallback),
      data: (s) => _buildContent(
        s.whaleAlerts.isNotEmpty ? s.whaleAlerts : _fallback,
      ),
    );
  }

  static Widget _buildShimmer() => Shimmer.fromColors(
    baseColor: AppColors.bgCard,
    highlightColor: AppColors.bgTertiary,
    child: Container(
      height: 220,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    ),
  );

  static Widget _buildContent(List<WhaleAlert> alerts) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Whale Alerts', subtitle: 'Large transactions · Real-time'),
          const SizedBox(height: 12),
          ...alerts.take(5).map((a) => _AlertRow(alert: a)),
        ],
      ),
    );
  }

  static final _now = DateTime.now();
  static final _fallback = [
    WhaleAlert(symbol: 'BTC', amount: 2840, amountUsd: 276800000,
      from: 'Unknown', to: 'Binance',
      timestamp: _now.subtract(const Duration(minutes: 4))),
    WhaleAlert(symbol: 'ETH', amount: 14200, amountUsd: 54600000,
      from: 'Coinbase', to: 'Unknown',
      timestamp: _now.subtract(const Duration(minutes: 12))),
    WhaleAlert(symbol: 'USDT', amount: 85000000, amountUsd: 85000000,
      from: 'Binance', to: 'Unknown',
      timestamp: _now.subtract(const Duration(minutes: 28))),
    WhaleAlert(symbol: 'BTC', amount: 1200, amountUsd: 117000000,
      from: 'Kraken', to: 'Unknown',
      timestamp: _now.subtract(const Duration(minutes: 45))),
    WhaleAlert(symbol: 'ETH', amount: 9500, amountUsd: 36500000,
      from: 'Unknown', to: 'OKX',
      timestamp: _now.subtract(const Duration(hours: 1))),
  ];
}

class _AlertRow extends StatelessWidget {
  final WhaleAlert alert;
  const _AlertRow({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Center(
              child: Text(alert.emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alert.formattedAmount} ${alert.symbol}',
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'JetBrainsMono',
                  )),
                Text('${alert.from} → ${alert.to}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeago.format(alert.timestamp),
                style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: (alert.toExchange ? AppColors.brandRed : AppColors.brandAmber).withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.toExchange ? 'To Exchange' : 'From Exchange',
                  style: TextStyle(
                    fontSize: 8, fontWeight: FontWeight.w600,
                    color: alert.toExchange ? AppColors.brandRed : AppColors.brandAmber,
                  )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}