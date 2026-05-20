import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/coin_selector.dart';

List<FlSpot> _mockFlows(bool inflow) {
  final rng = math.Random(inflow ? 11 : 22);
  return List.generate(24, (i) {
    final base = inflow ? 2000.0 : 1500.0;
    return FlSpot(i.toDouble(), base + rng.nextDouble() * 1000 - 500);
  });
}

class OnchainScreen extends StatefulWidget {
  const OnchainScreen({super.key});

  @override
  State<OnchainScreen> createState() => _OnchainScreenState();
}

class _OnchainScreenState extends State<OnchainScreen> {
  String _selectedCoin = 'BTC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildCoinSelector(),
                  const SizedBox(height: 20),
                  _buildMetricsRow(),
                  const SizedBox(height: 16),
                  _buildFlowChart(),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (_, c) {
                    if (c.maxWidth < 700) {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OnChainMetricsCard(),
                          SizedBox(height: 16),
                          _WhaleTransactionsList(),
                        ],
                      );
                    }
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _OnChainMetricsCard()),
                        SizedBox(width: 16),
                        Expanded(child: _WhaleTransactionsList()),
                      ],
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('On-Chain Analytics', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5,
              )),
              Text('Exchange flows · Whale activity · SOPR · MVRV',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        NeonBadge(label: 'Glassnode', color: AppColors.brandBlue),
      ],
    );
  }

  Widget _buildCoinSelector() {
    return CoinSelector(
      selected: _selectedCoin,
      onChanged: (c) => setState(() => _selectedCoin = c),
    );
  }

  Widget _buildMetricsRow() {
    return LayoutBuilder(builder: (_, c) {
      final tiles = [
        _FlowTile('Exchange Inflow', '2,847 $_selectedCoin', '\$277.4M', false),
        _FlowTile('Exchange Outflow', '4,120 $_selectedCoin', '\$401.6M', true),
        _FlowTile('Net Flow', '-1,273 $_selectedCoin', '-\$124.2M', true),
        _FlowTile('Exchange Reserve', '2.31M $_selectedCoin', '12.4% supply', false),
      ];

      if (c.maxWidth < 700) {
        return Column(
          children: [
            Row(children: [Expanded(child: tiles[0]), const SizedBox(width: 12), Expanded(child: tiles[1])]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: tiles[2]), const SizedBox(width: 12), Expanded(child: tiles[3])]),
          ],
        );
      }
      return Row(
        children: tiles.expand((t) => [t, const SizedBox(width: 12)]).toList()..removeLast(),
      );
    });
  }

  Widget _buildFlowChart() {
    final inflowSpots = _mockFlows(true);
    final outflowSpots = _mockFlows(false);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Exchange Flows (24h)', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              const Spacer(),
              _LegendDot(AppColors.brandGreen, 'Outflow'),
              const SizedBox(width: 12),
              _LegendDot(AppColors.brandRed, 'Inflow'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.borderSubtle,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: outflowSpots,
                    isCurved: true,
                    color: AppColors.brandGreen,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.brandGreen.withAlpha(15),
                    ),
                  ),
                  LineChartBarData(
                    spots: inflowSpots,
                    isCurved: true,
                    color: AppColors.brandRed,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.brandRed.withAlpha(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('More outflow than inflow → Bullish signal (coins leaving exchanges)',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  final String label, value, sub;
  final bool positive;
  const _FlowTile(this.label, this.value, this.sub, this.positive);

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.brandGreen : AppColors.brandRed;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: color, fontFamily: 'JetBrainsMono',
          )),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

class _OnChainMetricsCard extends StatelessWidget {
  const _OnChainMetricsCard();

  static const _metrics = [
    _OnChainMetric('SOPR', '1.042', 'Profitable', AppColors.brandGreen,
      'Spent Output Profit Ratio > 1 means most coins moved are in profit. Bullish.'),
    _OnChainMetric('MVRV-Z', '2.8', 'Fair Value', AppColors.brandAmber,
      'Market Value to Realized Value. Below 3.5 = not overheated territory.'),
    _OnChainMetric('NVT Ratio', '84.2', 'Normal', AppColors.brandBlue,
      'Network Value to Transactions. Below 100 signals healthy transaction volume.'),
    _OnChainMetric('Puell Multiple', '1.21', 'Safe Zone', AppColors.brandGreen,
      'Miner revenue vs annual average. Red zone above 4. Currently healthy.'),
    _OnChainMetric('STH SOPR', '0.98', 'Slight Loss', AppColors.brandAmber,
      'Short-term holders in slight loss. Could indicate capitulation before reversal.'),
    _OnChainMetric('Reserve Risk', '0.0012', 'Opportunity', AppColors.brandGreen,
      'Low reserve risk suggests confident long-term holders. Historically bullish.'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('On-Chain Metrics', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 14),
          ..._metrics.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m.name, style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                    const Spacer(),
                    Text(m.value, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: m.color, fontFamily: 'JetBrainsMono',
                    )),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: m.color.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(m.signal, style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700, color: m.color,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(m.description, style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted, height: 1.4,
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _OnChainMetric {
  final String name, value, signal, description;
  final Color color;
  const _OnChainMetric(this.name, this.value, this.signal, this.color, this.description);
}

class _WhaleTransactionsList extends StatelessWidget {
  const _WhaleTransactionsList();

  static const _txns = [
    _WhaleTxn('BTC', '2,840', '\$276.8M', 'Unknown', 'Binance', '4m ago', true),
    _WhaleTxn('ETH', '18,420', '\$70.8M', 'Coinbase', 'Unknown', '12m ago', false),
    _WhaleTxn('BTC', '1,200', '\$117.0M', 'Kraken', 'Unknown', '28m ago', false),
    _WhaleTxn('USDT', '85M', '\$85.0M', 'Tether Treasury', 'Unknown', '45m ago', false),
    _WhaleTxn('ETH', '9,800', '\$37.7M', 'Unknown', 'Coinbase', '1h ago', true),
    _WhaleTxn('BTC', '680', '\$66.2M', 'Unknown', 'Bybit', '1.5h ago', true),
    _WhaleTxn('SOL', '220K', '\$40.5M', 'Unknown', 'OKX', '2h ago', true),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Whale Transactions', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              const Spacer(),
              NeonBadge(label: 'LIVE', color: AppColors.brandGreen, icon: Icons.circle),
            ],
          ),
          const SizedBox(height: 14),
          ..._txns.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: t.toExchange ? AppColors.brandRed : AppColors.brandGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${t.amount} ${t.symbol}', style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                          )),
                          const Spacer(),
                          Text(t.usdValue, style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: t.toExchange ? AppColors.brandRed : AppColors.brandGreen,
                            fontFamily: 'JetBrainsMono',
                          )),
                        ],
                      ),
                      Text('${t.from} → ${t.to} · ${t.time}', style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _WhaleTxn {
  final String symbol, amount, usdValue, from, to, time;
  final bool toExchange;
  const _WhaleTxn(this.symbol, this.amount, this.usdValue, this.from, this.to, this.time, this.toExchange);
}