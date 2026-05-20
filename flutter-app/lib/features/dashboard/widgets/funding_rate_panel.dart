import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/remote/data/dashboard/models/dashboard_models.dart';
import '../../../providers/dashboard_provider.dart';

class FundingRatePanel extends ConsumerWidget {
  const FundingRatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(fundingRatesProvider);
    return async.when(
      loading: _buildShimmer,
      error: (_, __) => _buildContent(_fallback),
      data: (rates) => _buildContent(rates.isNotEmpty ? rates : _fallback),
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

  static Widget _buildContent(List<FundingRate> rates) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Funding Rates',
            subtitle: 'Perpetual futures · 8h intervals',
          ),
          const SizedBox(height: 16),
          ...rates.map((r) => _FundingRow(rate: r)),
        ],
      ),
    );
  }

  static final _fallback = [
    FundingRate(symbol: 'BTCUSDT', rate: 0.00023),
    FundingRate(symbol: 'ETHUSDT', rate: 0.00018),
    FundingRate(symbol: 'SOLUSDT', rate: -0.00008),
    FundingRate(symbol: 'BNBUSDT', rate: 0.00031),
    FundingRate(symbol: 'ARBUSDT', rate: 0.00045),
  ];
}

class _FundingRow extends StatelessWidget {
  final FundingRate rate;
  const _FundingRow({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate.positive ? AppColors.brandGreen : AppColors.brandRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(rate.symbol,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    if (rate.isHigh) ...[
                      const SizedBox(width: 6),
                      NeonBadge(label: 'HIGH', color: AppColors.brandAmber),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(rate.interpretation,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(rate.formatted,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: color, fontFamily: 'JetBrainsMono',
            )),
        ],
      ),
    );
  }
}