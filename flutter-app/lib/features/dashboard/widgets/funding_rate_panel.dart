import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/remote/data/dashboard/models/dashboard_models.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../core/remote/web_socket_baseclass.dart';

class FundingRatePanel extends ConsumerWidget {
  const FundingRatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveFundingAsync = ref.watch(liveFundingProvider);
    final restFundingAsync = ref.watch(fundingRatesProvider);

    // If live socket data is available, display it
    if (liveFundingAsync.hasValue && liveFundingAsync.value!.isNotEmpty) {
      final rates = liveFundingAsync.value!;
      return _buildContent(
        rates: rates,
        isLive: true,
        itemBuilder: (r) => _FundingRow(
          symbol: r.symbol,
          rate: r.rate,
          positive: r.positive,
          formatted: r.formatted,
          isHigh: r.isHigh,
          interpretation: r.interpretation,
        ),
      );
    }

    // Fallback to REST
    return restFundingAsync.when(
      loading: _buildShimmer,
      error: (_, __) => _buildFallbackContent(),
      data: (rates) {
        final list = rates.isNotEmpty ? rates : _fallback;
        return _buildContent(
          rates: list,
          isLive: false,
          itemBuilder: (r) => _FundingRow(
            symbol: r.symbol,
            rate: r.rate,
            positive: r.positive,
            formatted: r.formatted,
            isHigh: r.isHigh,
            interpretation: r.interpretation,
          ),
        );
      },
    );
  }

  Widget _buildFallbackContent() {
    return _buildContent(
      rates: _fallback,
      isLive: false,
      itemBuilder: (r) => _FundingRow(
        symbol: r.symbol,
        rate: r.rate,
        positive: r.positive,
        formatted: r.formatted,
        isHigh: r.isHigh,
        interpretation: r.interpretation,
      ),
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

  static Widget _buildContent<T>({
    required List<T> rates,
    required bool isLive,
    required Widget Function(T) itemBuilder,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Funding Rates',
                  subtitle: 'Perpetual futures · 8h intervals',
                ),
              ),
              if (isLive)
                const NeonBadge(label: 'LIVE', color: AppColors.brandGreen),
            ],
          ),
          const SizedBox(height: 16),
          ...rates.map(itemBuilder),
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
  final String symbol;
  final double rate;
  final bool positive;
  final String formatted;
  final bool isHigh;
  final String interpretation;

  const _FundingRow({
    required this.symbol,
    required this.rate,
    required this.positive,
    required this.formatted,
    required this.isHigh,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.brandGreen : AppColors.brandRed;
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
                    Text(symbol,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    if (isHigh) ...[
                      const SizedBox(width: 6),
                      NeonBadge(label: 'HIGH', color: AppColors.brandAmber),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(interpretation,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(formatted,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: color, fontFamily: 'JetBrainsMono',
            )),
        ],
      ),
    );
  }
}