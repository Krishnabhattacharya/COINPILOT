
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/coin_selector.dart';
import '../../providers/charts_provider.dart';

const _timeframes = ['1m', '5m', '15m', '1H', '4H', '1D', '1W'];
const _indicators = ['RSI', 'MACD', 'EMA', 'Volume', 'Bollinger'];

List<Candle> _buildCandles() {
  final rng = math.Random(42);
  var price = 97000.0;
  final now = DateTime.now();
  final candles = List.generate(60, (i) {
    price += (rng.nextDouble() - 0.48) * 500;
    price = price.clamp(88000.0, 108000.0);
    final open = price;
    final close = (price + (rng.nextDouble() - 0.48) * 400).clamp(88000.0, 108000.0);
    final high = math.max(open, close) + rng.nextDouble() * 300;
    final low = (math.min(open, close) - rng.nextDouble() * 300).clamp(85000.0, 112000.0);
    price = close;
    return Candle(
      date: now.subtract(Duration(hours: (59 - i) * 4)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 800 + rng.nextDouble() * 4000,
    );
  });
  // candlesticks package expects newest first
  return candles.reversed.toList();
}

final _candles = _buildCandles();

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  String _selectedCoin = 'BTC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin selector + timeframe header
            Consumer(
              builder: (_, ref, __) {
                final n = ref.watch(chartsProvider);
                return _ChartHeader(
                  selectedCoin: _selectedCoin,
                  onCoinChanged: (c) => setState(() => _selectedCoin = c),
                  timeframe: n.timeframe,
                  timeframes: _timeframes,
                  onTimeframeChanged: (t) => ref.read(chartsProvider).setTimeframe(t),
                  indicator: n.indicator,
                  indicators: _indicators,
                  onIndicatorChanged: (i) => ref.read(chartsProvider).setIndicator(i),
                );
              },
            ),
            const SizedBox(height: 16),
            // Chart card is fully static — candle data never changes
            Expanded(
              flex: 3,
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    const _ChartToolbar(),
                    const Expanded(child: _CandlestickChart()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Indicator panel rebuilds ONLY when indicator changes, not timeframe
            Expanded(
              flex: 1,
              child: GlassCard(
                child: Consumer(
                  builder: (_, ref, __) {
                    final indicator = ref.watch(
                      chartsProvider.select((n) => n.indicator),
                    );
                    return _IndicatorPanel(indicator: indicator);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String selectedCoin;
  final ValueChanged<String> onCoinChanged;
  final String timeframe;
  final List<String> timeframes;
  final ValueChanged<String> onTimeframeChanged;
  final String indicator;
  final List<String> indicators;
  final ValueChanged<String> onIndicatorChanged;

  const _ChartHeader({
    required this.selectedCoin,
    required this.onCoinChanged,
    required this.timeframe,
    required this.timeframes,
    required this.onTimeframeChanged,
    required this.indicator,
    required this.indicators,
    required this.onIndicatorChanged,
  });

  Widget _timeframeButtons() => Row(
    mainAxisSize: MainAxisSize.min,
    children: timeframes.map((t) => GestureDetector(
      onTap: () => onTimeframeChanged(t),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: timeframe == t ? AppColors.brandGreen.withAlpha(20) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: timeframe == t
                ? AppColors.brandGreen.withAlpha(60)
                : AppColors.borderSubtle,
          ),
        ),
        child: Text(t, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: timeframe == t ? AppColors.brandGreen : AppColors.textMuted,
        )),
      ),
    )).toList(),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < 700;
      final coinSelector = CoinSelector(selected: selectedCoin, onChanged: onCoinChanged);

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            coinSelector,
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _timeframeButtons(),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(flex: 2, child: coinSelector),
          const SizedBox(width: 16),
          _timeframeButtons(),
        ],
      );
    });
  }
}

class _ChartToolbar extends StatelessWidget {
  const _ChartToolbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Left tool buttons — scroll horizontally if screen is narrow
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolBtn(Icons.show_chart_rounded, 'Line'),
                  _ToolBtn(Icons.candlestick_chart_rounded, 'Candle', active: true),
                  _ToolBtn(Icons.bar_chart_rounded, 'Bar'),
                  const SizedBox(width: 16),
                  _ToolBtn(Icons.draw_rounded, 'Draw'),
                  _ToolBtn(Icons.horizontal_rule_rounded, 'Trend'),
                  _ToolBtn(Icons.grid_on_rounded, 'Fib'),
                ],
              ),
            ),
          ),
          NeonBadge(
            label: 'AI Overlay ON',
            color: AppColors.brandGreen,
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(width: 8),
          _ToolBtn(Icons.fullscreen_rounded, 'Full'),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _ToolBtn(this.icon, this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.brandGreen.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14,
            color: active ? AppColors.brandGreen : AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500,
            color: active ? AppColors.brandGreen : AppColors.textMuted,
          )),
        ],
      ),
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  const _CandlestickChart();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Candlesticks(
          candles: _candles,
          style: CandleSticksStyle.dark(
            chartBackgroundColor: AppColors.bgCard,
            gridLineColor: AppColors.borderSubtle,
            axisTextColor: AppColors.textMuted,
            candleBullColor: AppColors.brandGreen,
            candleBearColor: AppColors.brandRed,
            volumeBullColor: AppColors.brandGreen.withAlpha(80),
            volumeBearColor: AppColors.brandRed.withAlpha(80),
          ),
        ),
        // AI pattern overlay
        Positioned(
          left: 16, top: 16,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgCard.withAlpha(220),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandGreen.withAlpha(30)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Pattern Detected', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.brandGreen, letterSpacing: 0.5,
                )),
                SizedBox(height: 4),
                Text('Bull flag forming · 78% probability', style: TextStyle(
                  fontSize: 11, color: Colors.white,
                )),
                SizedBox(height: 2),
                Text('Target: \$100,400 · Stop: \$95,800', style: TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IndicatorPanel extends StatelessWidget {
  final String indicator;
  const _IndicatorPanel({required this.indicator});

  static List<FlSpot> _spots(String type) {
    final rng = math.Random(12);
    return List.generate(60, (i) {
      final y = type == 'RSI'
          ? 30.0 + rng.nextDouble() * 50  // 30–80 range
          : rng.nextDouble();
      return FlSpot(i.toDouble(), y);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRsi = indicator == 'RSI';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$indicator Indicator', style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted,
        )),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              minY: isRsi ? 0 : null,
              maxY: isRsi ? 100 : null,
              extraLinesData: isRsi
                  ? ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 70,
                          color: AppColors.brandRed.withAlpha(80),
                          strokeWidth: 0.8,
                          dashArray: [4, 4],
                        ),
                        HorizontalLine(
                          y: 30,
                          color: AppColors.brandGreen.withAlpha(80),
                          strokeWidth: 0.8,
                          dashArray: [4, 4],
                        ),
                      ],
                    )
                  : const ExtraLinesData(),
              lineBarsData: [
                LineChartBarData(
                  spots: _spots(indicator),
                  isCurved: true,
                  color: AppColors.brandPurple,
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.brandPurple.withAlpha(15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
