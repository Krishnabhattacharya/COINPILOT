import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../providers/ai_analysis_provider.dart';

class _CoinData {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool positive;
  final Color color;
  final List<double> sparkline;

  const _CoinData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.positive,
    required this.color,
    required this.sparkline,
  });
}

const _coins = [
  _CoinData(
    symbol: 'BTC',
    name: 'Bitcoin',
    price: '\$97,420',
    change: '+2.4%',
    positive: true,
    color: Color(0xFFF7931A),
    sparkline: [42, 45, 43, 48, 52, 49, 55, 58, 54, 60, 64],
  ),
  _CoinData(
    symbol: 'ETH',
    name: 'Ethereum',
    price: '\$3,842',
    change: '+1.8%',
    positive: true,
    color: Color(0xFF627EEA),
    sparkline: [30, 33, 35, 31, 38, 40, 37, 42, 45, 44, 48],
  ),
  _CoinData(
    symbol: 'SOL',
    name: 'Solana',
    price: '\$184',
    change: '-0.9%',
    positive: false,
    color: Color(0xFF9945FF),
    sparkline: [55, 52, 58, 54, 50, 48, 51, 49, 47, 46, 44],
  ),
  _CoinData(
    symbol: 'BNB',
    name: 'BNB',
    price: '\$612',
    change: '+3.1%',
    positive: true,
    color: Color(0xFFF3BA2F),
    sparkline: [20, 22, 24, 21, 26, 28, 25, 30, 32, 31, 35],
  ),
];

class MarketOverviewCards extends ConsumerWidget {
  const MarketOverviewCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width >= 1200 ? 4 : width >= 768 ? 2 : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: _coins.map((coin) => _CoinCard(
        coin: coin,
        onTap: () {
          ref.read(aiAnalysisProvider).selectCoin(coin.symbol);
          context.go('/analysis');
        },
      )).toList(),
    );
  }
}

class _CoinCard extends StatelessWidget {
  final _CoinData coin;
  final VoidCallback onTap;
  const _CoinCard({super.key, required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // Coin icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: coin.color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                coin.symbol[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: coin.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(coin.symbol, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
                )),
                Text(coin.name, style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                coin.price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (coin.positive ? AppColors.brandGreen : AppColors.brandRed)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  coin.change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: coin.positive ? AppColors.brandGreen : AppColors.brandRed,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Sparkline
          SizedBox(
            width: 60,
            height: 30,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: coin.sparkline
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: coin.positive ? AppColors.brandGreen : AppColors.brandRed,
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (coin.positive ? AppColors.brandGreen : AppColors.brandRed)
                          .withAlpha(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

