import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/coin_selector.dart';
import '../../providers/ai_analysis_provider.dart';
import '../../providers/charts_provider.dart';

class _OrderLevel {
  final double price;
  final double size;
  final double total;
  final bool isBid;
  const _OrderLevel(this.price, this.size, this.total, this.isBid);
}

List<_OrderLevel> _generateBids() {
  final rng = math.Random(5);
  double total = 0;
  return List.generate(12, (i) {
    final price = 97420.0 - (i + 1) * 80 - rng.nextDouble() * 30;
    final size = 0.5 + rng.nextDouble() * 4.5;
    total += size;
    return _OrderLevel(price, size, total, true);
  });
}

List<_OrderLevel> _generateAsks() {
  final rng = math.Random(7);
  double total = 0;
  return List.generate(12, (i) {
    final price = 97420.0 + (i + 1) * 80 + rng.nextDouble() * 30;
    final size = 0.5 + rng.nextDouble() * 4.5;
    total += size;
    return _OrderLevel(price, size, total, false);
  });
}

final _bids = _generateBids();
final _asks = _generateAsks();

class OrderbookScreen extends ConsumerStatefulWidget {
  const OrderbookScreen({super.key});

  @override
  ConsumerState<OrderbookScreen> createState() => _OrderbookScreenState();
}

class _OrderbookScreenState extends ConsumerState<OrderbookScreen> {
  String get _selectedCoin => ref.watch(aiAnalysisProvider.select((n) => n.selectedCoin));

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
                  _buildSpreadInfo(),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (_, c) {
                    if (c.maxWidth < 700) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderbook(),
                          const SizedBox(height: 16),
                          _buildDepthVisual(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildOrderbook()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDepthVisual()),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildKeyLevels(),
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
              Text('Order Book', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5,
              )),
              Text('Bid/ask walls · Depth · Key support & resistance',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        NeonBadge(label: 'LIVE', color: AppColors.brandGreen, icon: Icons.circle),
      ],
    );
  }

  Widget _buildCoinSelector() {
    return CoinSelector(
      selected: _selectedCoin,
      onChanged: (c) {
        ref.read(aiAnalysisProvider).selectCoin(c);
        ref.read(chartsProvider).setCoin(c);
      },
    );
  }

  Widget _buildSpreadInfo() {
    return Row(
      children: [
        _SpreadTile('\$97,420.00', 'Last Price', Colors.white),
        const SizedBox(width: 12),
        _SpreadTile('\$97,415.50', 'Best Bid', AppColors.brandGreen),
        const SizedBox(width: 12),
        _SpreadTile('\$97,428.00', 'Best Ask', AppColors.brandRed),
        const SizedBox(width: 12),
        _SpreadTile('\$12.50 (0.013%)', 'Spread', AppColors.brandAmber),
      ],
    );
  }

  Widget _buildOrderbook() {
    final maxTotal = math.max(_bids.last.total, _asks.last.total);

    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: const [
                Expanded(child: Text('Price (USDT)', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted,
                ))),
                SizedBox(width: 8),
                Text('Size (BTC)', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted,
                )),
                SizedBox(width: 8),
                SizedBox(width: 60, child: Text('Total', textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted,
                  ))),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),
          // Asks (reversed so lowest ask is closest to middle)
          ...(_asks.reversed.toList()).map((a) => _OrderRow(level: a, maxTotal: maxTotal)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppColors.bgTertiary,
            child: const Row(
              children: [
                Icon(Icons.horizontal_rule_rounded, size: 14, color: AppColors.textDisabled),
                SizedBox(width: 6),
                Text('\$97,420.00 · Spread \$12.50', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                  fontFamily: 'JetBrainsMono',
                )),
              ],
            ),
          ),
          // Bids
          ..._bids.map((b) => _OrderRow(level: b, maxTotal: maxTotal)),
        ],
      ),
    );
  }

  Widget _buildDepthVisual() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Cumulative Depth', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              const Spacer(),
              _LegendDot(AppColors.brandGreen, 'Bids'),
              const SizedBox(width: 12),
              _LegendDot(AppColors.brandRed, 'Asks'),
            ],
          ),
          const SizedBox(height: 20),
          ..._asks.reversed.take(8).toList().asMap().entries.map((e) {
            final pct = e.value.total / _asks.last.total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '\$${e.value.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 9, color: AppColors.brandRed,
                        fontFamily: 'JetBrainsMono'),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.brandRed.withAlpha(10),
                        valueColor: const AlwaysStoppedAnimation(AppColors.brandRed),
                        minHeight: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              height: 1,
              color: AppColors.brandAmber.withAlpha(60),
              child: const SizedBox(),
            ),
          ),
          ..._bids.take(8).toList().asMap().entries.map((e) {
            final pct = e.value.total / _bids.last.total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '\$${e.value.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 9, color: AppColors.brandGreen,
                        fontFamily: 'JetBrainsMono'),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.brandGreen.withAlpha(10),
                        valueColor: const AlwaysStoppedAnimation(AppColors.brandGreen),
                        minHeight: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKeyLevels() {
    const levels = [
      _KeyLevel('\$101,500', 'Major Resistance', 'Large ask wall · 420 BTC stacked', AppColors.brandRed, Icons.arrow_upward_rounded),
      _KeyLevel('\$99,000', 'Resistance', 'Round number psychology · 180 BTC asks', AppColors.brandRed, Icons.arrow_upward_rounded),
      _KeyLevel('\$97,420', 'Current Price', 'Last traded', Colors.white, Icons.circle),
      _KeyLevel('\$95,200', 'Support', 'High-volume node from prior consolidation', AppColors.brandGreen, Icons.arrow_downward_rounded),
      _KeyLevel('\$94,200', 'Major Support', 'Liquidation cluster · 580 BTC bids stacked', AppColors.brandGreen, Icons.arrow_downward_rounded),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Price Levels', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          const SizedBox(height: 14),
          ...levels.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(l.icon, size: 14, color: l.color),
                const SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: Text(l.price, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: l.color, fontFamily: 'JetBrainsMono',
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.label, style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: l.color,
                      )),
                      Text(l.note, style: const TextStyle(
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

class _KeyLevel {
  final String price, label, note;
  final Color color;
  final IconData icon;
  const _KeyLevel(this.price, this.label, this.note, this.color, this.icon);
}

class _OrderRow extends StatelessWidget {
  final _OrderLevel level;
  final double maxTotal;
  const _OrderRow({super.key, required this.level, required this.maxTotal});

  @override
  Widget build(BuildContext context) {
    final pct = level.total / maxTotal;
    final color = level.isBid ? AppColors.brandGreen : AppColors.brandRed;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: level.isBid ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: pct * 0.6,
              child: Container(color: color.withAlpha(12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '\$${level.price.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: color, fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                level.size.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 11, color: Colors.white, fontFamily: 'JetBrainsMono',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  level.total.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted, fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpreadTile extends StatelessWidget {
  final String value, label;
  final Color color;
  const _SpreadTile(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: color, fontFamily: 'JetBrainsMono',
            )),
          ],
        ),
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