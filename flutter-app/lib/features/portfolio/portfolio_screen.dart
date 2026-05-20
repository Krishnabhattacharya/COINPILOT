import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class _Holding {
  final String symbol, name, emoji;
  final double amount, avgBuy, currentPrice;
  final Color color;

  const _Holding({
    required this.symbol, required this.name, required this.emoji,
    required this.amount, required this.avgBuy, required this.currentPrice,
    required this.color,
  });

  double get value => amount * currentPrice;
  double get pnl => (currentPrice - avgBuy) * amount;
  double get pnlPct => ((currentPrice - avgBuy) / avgBuy) * 100;
  bool get positive => pnl >= 0;
}

const _holdings = [
  _Holding(symbol: 'BTC', name: 'Bitcoin', emoji: '₿', amount: 0.42, avgBuy: 84000, currentPrice: 97420, color: Color(0xFFF7931A)),
  _Holding(symbol: 'ETH', name: 'Ethereum', emoji: 'Ξ', amount: 4.8, avgBuy: 3200, currentPrice: 3842, color: Color(0xFF627EEA)),
  _Holding(symbol: 'SOL', name: 'Solana', emoji: '◎', amount: 62.0, avgBuy: 145, currentPrice: 184, color: Color(0xFF9945FF)),
  _Holding(symbol: 'BNB', name: 'BNB', emoji: 'B', amount: 8.5, avgBuy: 490, currentPrice: 612, color: Color(0xFFF3BA2F)),
  _Holding(symbol: 'ARB', name: 'Arbitrum', emoji: 'A', amount: 2200.0, avgBuy: 1.8, currentPrice: 1.31, color: Color(0xFF12AAFF)),
];

List<FlSpot> _equityCurve() {
  final rng = math.Random(3);
  double val = 28000;
  return List.generate(30, (i) {
    val += (rng.nextDouble() - 0.38) * 1200;
    val = val.clamp(22000.0, 60000.0);
    return FlSpot(i.toDouble(), val);
  });
}

final _equitySpots = _equityCurve();

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalValue = _holdings.fold(0.0, (s, h) => s + h.value);
    final totalPnl = _holdings.fold(0.0, (s, h) => s + h.pnl);
    final totalPnlPct = (totalPnl / (totalValue - totalPnl)) * 100;

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
                  const SizedBox(height: 20),
                  _buildPortfolioValue(totalValue, totalPnl, totalPnlPct),
                  const SizedBox(height: 16),
                  _buildEquityCurve(),
                  const SizedBox(height: 20),
                  LayoutBuilder(builder: (_, c) {
                    if (c.maxWidth < 700) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHoldingsList(),
                          const SizedBox(height: 16),
                          _buildAllocation(totalValue),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildHoldingsList()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildAllocation(totalValue)),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildConnectCard(),
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
              Text('Portfolio', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5,
              )),
              Text('Holdings · P&L · Equity curve · Allocation',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.gradientGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 14, color: Colors.black),
              SizedBox(width: 4),
              Text('Add Trade', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioValue(double total, double pnl, double pnlPct) {
    final positive = pnl >= 0;
    return GlassCard(
      borderColor: positive ? AppColors.brandGreen.withAlpha(30) : AppColors.brandRed.withAlpha(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Portfolio Value', style: TextStyle(
            fontSize: 11, color: AppColors.textMuted,
          )),
          const SizedBox(height: 8),
          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(
            fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,
            fontFamily: 'JetBrainsMono', letterSpacing: -1,
          )),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14, color: positive ? AppColors.brandGreen : AppColors.brandRed,
              ),
              const SizedBox(width: 4),
              Text(
                '${positive ? '+' : ''}\$${pnl.toStringAsFixed(2)} (${positive ? '+' : ''}${pnlPct.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: positive ? AppColors.brandGreen : AppColors.brandRed,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const SizedBox(width: 8),
              const Text('All time', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquityCurve() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equity Curve (30d)', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.borderSubtle, strokeWidth: 0.5,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _equitySpots,
                    isCurved: true,
                    color: AppColors.brandGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.brandGreen.withAlpha(20),
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

  Widget _buildHoldingsList() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Holdings', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          const SizedBox(height: 14),
          ..._holdings.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: h.color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(h.emoji, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: h.color,
                    )),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.symbol, style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                      Text('${h.amount} · Avg \$${h.avgBuy.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${h.value.toStringAsFixed(0)}', style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'JetBrainsMono',
                    )),
                    Text(
                      '${h.positive ? '+' : ''}\$${h.pnl.toStringAsFixed(0)} (${h.positive ? '+' : ''}${h.pnlPct.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: h.positive ? AppColors.brandGreen : AppColors.brandRed,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAllocation(double totalValue) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Allocation', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          const SizedBox(height: 16),
          ..._holdings.map((h) {
            final pct = h.value / totalValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: h.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(h.symbol, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      const Spacer(),
                      Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: h.color,
                        fontFamily: 'JetBrainsMono',
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.borderSubtle,
                      valueColor: AlwaysStoppedAnimation(h.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              const Text('5 assets · Mock data only',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              NeonBadge(label: 'Connect exchange', color: AppColors.brandBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectCard() {
    return GlassCard(
      borderColor: AppColors.brandBlue.withAlpha(30),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link_rounded, color: AppColors.brandBlue, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connect Your Exchange', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                )),
                SizedBox(height: 2),
                Text('Sync real portfolio data from Binance, Bybit, or OKX via read-only API',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Connect', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }
}