import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/coin_selector.dart';

class _Signal {
  final String coin;
  final String price;
  final String funding;
  final String fundingLevel;
  final String oiChange;
  final String oiLevel;
  final String lsRatio;
  final String lsLevel;
  final String liqWall;
  final String liqSide;
  final int sentiment;
  final String verdict;
  final String verdictIcon;
  final Color verdictColor;
  final int confidence;
  final String entry;
  final String takeProfit;
  final String stopLoss;
  final String riskReward;
  final String reasoning;

  const _Signal({
    required this.coin, required this.price,
    required this.funding, required this.fundingLevel,
    required this.oiChange, required this.oiLevel,
    required this.lsRatio, required this.lsLevel,
    required this.liqWall, required this.liqSide,
    required this.sentiment, required this.verdict,
    required this.verdictIcon, required this.verdictColor,
    required this.confidence, required this.entry,
    required this.takeProfit, required this.stopLoss,
    required this.riskReward, required this.reasoning,
  });
}

const _signals = {
  'BTC': _Signal(
    coin: 'BTC', price: '\$97,420',
    funding: '+0.071%', fundingLevel: 'High',
    oiChange: '+12% (6h)', oiLevel: 'Rising',
    lsRatio: '1.82', lsLevel: 'Crowded Longs',
    liqWall: '\$94,200', liqSide: 'Below',
    sentiment: 58,
    verdict: 'CAUTION — Wait for Flush',
    verdictIcon: '⚠️',
    verdictColor: AppColors.brandAmber,
    confidence: 67,
    entry: '\$95,200 – \$96,000',
    takeProfit: '\$101,500',
    stopLoss: '\$93,800',
    riskReward: '2.8:1',
    reasoning: 'Funding at 0.071% signals overleveraged longs. OI rising into resistance with no breakout confirmation. Large liquidation cluster below at \$94,200 could cause a cascade. Wait for a flush below \$95,000 before entering long.',
  ),
  'ETH': _Signal(
    coin: 'ETH', price: '\$3,842',
    funding: '+0.023%', fundingLevel: 'Neutral',
    oiChange: '-3% (6h)', oiLevel: 'Decreasing',
    lsRatio: '1.21', lsLevel: 'Balanced',
    liqWall: '\$4,100', liqSide: 'Above',
    sentiment: 72,
    verdict: 'BULLISH — Good Entry Zone',
    verdictIcon: '✅',
    verdictColor: AppColors.brandGreen,
    confidence: 81,
    entry: '\$3,750 – \$3,820',
    takeProfit: '\$4,200',
    stopLoss: '\$3,580',
    riskReward: '2.4:1',
    reasoning: 'Neutral funding with declining OI suggests deleveraging is healthy. Long/short ratio near 1.2 means balanced positioning. Spot buying pressure visible. Strong support at \$3,750. Risk/reward favors longs.',
  ),
  'SOL': _Signal(
    coin: 'SOL', price: '\$184',
    funding: '-0.012%', fundingLevel: 'Slightly Negative',
    oiChange: '+5% (6h)', oiLevel: 'Rising',
    lsRatio: '0.89', lsLevel: 'Short-Heavy',
    liqWall: '\$195', liqSide: 'Above',
    sentiment: 65,
    verdict: 'BULLISH — Short Squeeze Setup',
    verdictIcon: '🚀',
    verdictColor: AppColors.brandGreen,
    confidence: 74,
    entry: '\$182 – \$186',
    takeProfit: '\$198',
    stopLoss: '\$175',
    riskReward: '3.1:1',
    reasoning: 'Negative funding + short-heavy positioning creates conditions for a short squeeze. Large liquidation wall at \$195 will accelerate the move. OI rising with price suggests new money entering. High-conviction long setup.',
  ),
  'BNB': _Signal(
    coin: 'BNB', price: '\$612',
    funding: '+0.051%', fundingLevel: 'Elevated',
    oiChange: '+8% (6h)', oiLevel: 'Rising',
    lsRatio: '1.54', lsLevel: 'Long-Biased',
    liqWall: '\$588', liqSide: 'Below',
    sentiment: 45,
    verdict: 'BEARISH — Overextended',
    verdictIcon: '🔴',
    verdictColor: AppColors.brandRed,
    confidence: 62,
    entry: 'Wait for \$590–\$598',
    takeProfit: '\$628',
    stopLoss: '\$580',
    riskReward: '2.2:1',
    reasoning: 'Elevated funding with rising OI into resistance. Long-biased L/S ratio exposes downside risk. Potential flush to \$588 liquidation wall before reversal. Watch for spot buying at \$590 before entering.',
  ),
  'XRP': _Signal(
    coin: 'XRP', price: '\$2.14',
    funding: '+0.015%', fundingLevel: 'Low',
    oiChange: '+2% (6h)', oiLevel: 'Stable',
    lsRatio: '1.10', lsLevel: 'Balanced',
    liqWall: '\$2.40', liqSide: 'Above',
    sentiment: 68,
    verdict: 'NEUTRAL — Range-Bound',
    verdictIcon: '⏸️',
    verdictColor: AppColors.textMuted,
    confidence: 55,
    entry: '\$2.08 – \$2.15',
    takeProfit: '\$2.45',
    stopLoss: '\$1.98',
    riskReward: '2.0:1',
    reasoning: 'Low funding with stable OI. No strong directional bias. Price consolidating in a range. Await breakout confirmation above \$2.25 or breakdown below \$2.05 before committing.',
  ),
  'DOGE': _Signal(
    coin: 'DOGE', price: '\$0.182',
    funding: '+0.098%', fundingLevel: 'Very High',
    oiChange: '+24% (6h)', oiLevel: 'Surging',
    lsRatio: '2.14', lsLevel: 'Extremely Crowded Longs',
    liqWall: '\$0.155', liqSide: 'Below',
    sentiment: 85,
    verdict: 'EXTREME CAUTION — Overheated',
    verdictIcon: '🚨',
    verdictColor: AppColors.brandRed,
    confidence: 88,
    entry: 'Avoid — Wait for Reset',
    takeProfit: 'N/A',
    stopLoss: 'N/A',
    riskReward: 'N/A',
    reasoning: 'Funding rate at 0.098% — one of the highest levels seen this cycle. OI surging +24% in 6 hours is unsustainable. L/S ratio of 2.14 means extreme crowding. High probability of violent liquidation cascade to \$0.155. Do not chase.',
  ),
};

class TradeNowScreen extends ConsumerStatefulWidget {
  const TradeNowScreen({super.key});

  @override
  ConsumerState<TradeNowScreen> createState() => _TradeNowScreenState();
}

class _TradeNowScreenState extends ConsumerState<TradeNowScreen> {
  String _selectedCoin = 'BTC';

  @override
  Widget build(BuildContext context) {
    final signal = _signals[_selectedCoin];

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
                  CoinSelector(
                    selected: _selectedCoin,
                    onChanged: (c) => setState(() => _selectedCoin = c),
                  ),
                  const SizedBox(height: 20),
                  if (signal == null) _buildNoSignalCard() else _buildVerdictCard(signal),
                  if (signal != null) ...[
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (_, c) {
                    if (c.maxWidth < 700) {
                      return Column(children: [
                        _buildMetricsGrid(signal),
                        const SizedBox(height: 16),
                        _buildLevelsCard(signal),
                      ]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildMetricsGrid(signal)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildLevelsCard(signal)),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildReasoningCard(signal),
                  const SizedBox(height: 16),
                  _buildHistoricalSetups(),
                  ],
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
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.gradientGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trade Now?', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5,
              )),
              Text('AI signal aggregator · Funding · OI · L/S Ratio · Sentiment',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        NeonBadge(label: 'LIVE', color: AppColors.brandGreen, icon: Icons.circle),
      ],
    );
  }

  Widget _buildNoSignalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded, size: 28, color: AppColors.textMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_selectedCoin signal coming soon', style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                )),
                const SizedBox(height: 4),
                const Text('Live AI analysis for this coin is not yet available.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictCard(_Signal s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.verdictColor.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.verdictColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.verdictIcon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s.verdict, style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: s.verdictColor,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${s.coin}/USDT ', style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted,
                    )),
                    Text(s.price, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'JetBrainsMono',
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _ConfidenceRing(confidence: s.confidence, color: s.verdictColor),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(_Signal s) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricTile(
              label: 'Funding Rate',
              value: s.funding,
              badge: s.fundingLevel,
              badgeColor: s.fundingLevel == 'High' || s.fundingLevel == 'Very High'
                  ? AppColors.brandRed
                  : s.fundingLevel == 'Elevated'
                      ? AppColors.brandAmber
                      : AppColors.brandGreen,
              icon: Icons.swap_horiz_rounded,
            )),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(
              label: 'OI Change',
              value: s.oiChange,
              badge: s.oiLevel,
              badgeColor: s.oiLevel == 'Surging' || s.oiLevel == 'Rising'
                  ? AppColors.brandAmber : AppColors.brandGreen,
              icon: Icons.trending_up_rounded,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricTile(
              label: 'Long/Short Ratio',
              value: s.lsRatio,
              badge: s.lsLevel,
              badgeColor: s.lsLevel.contains('Crowded') || s.lsLevel == 'Extremely Crowded Longs'
                  ? AppColors.brandRed
                  : s.lsLevel == 'Short-Heavy'
                      ? AppColors.brandGreen
                      : AppColors.textMuted,
              icon: Icons.people_rounded,
            )),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(
              label: 'Liq Wall ${s.liqSide}',
              value: s.liqWall,
              badge: s.liqSide,
              badgeColor: s.liqSide == 'Below' ? AppColors.brandAmber : AppColors.brandGreen,
              icon: Icons.local_fire_department_rounded,
            )),
          ],
        ),
        const SizedBox(height: 12),
        _SentimentBar(value: s.sentiment),
      ],
    );
  }

  Widget _buildLevelsCard(_Signal s) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trade Levels', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          const SizedBox(height: 16),
          _LevelRow('Entry Zone', s.entry, AppColors.brandBlue),
          const SizedBox(height: 10),
          _LevelRow('Take Profit', s.takeProfit, AppColors.brandGreen),
          const SizedBox(height: 10),
          _LevelRow('Stop Loss', s.stopLoss, AppColors.brandRed),
          const SizedBox(height: 10),
          _LevelRow('Risk/Reward', s.riskReward, AppColors.brandAmber),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textDisabled),
              SizedBox(width: 6),
              Expanded(
                child: Text('Levels based on mock data. Not financial advice.',
                  style: TextStyle(fontSize: 10, color: AppColors.textDisabled, height: 1.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningCard(_Signal s) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Reasoning', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brandGreen,
                )),
                const SizedBox(height: 6),
                Text(s.reasoning, style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted, height: 1.6,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSetups() {
    const setups = [
      _HistoricalSetup('BTC · Mar 2024', 'Similar funding spike to 0.08% before flush to \$59K, then rip to \$73K', '+24%', true),
      _HistoricalSetup('ETH · Nov 2023', 'Negative funding + short squeeze setup resolved with +18% gain in 5 days', '+18%', true),
      _HistoricalSetup('SOL · Jan 2024', 'Crowded longs + high OI led to -22% liquidation cascade', '-22%', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historical Setups Like This', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
        )),
        const SizedBox(height: 10),
        ...setups.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            child: Row(
              children: [
                Container(
                  width: 4, height: 40,
                  decoration: BoxDecoration(
                    color: s.positive ? AppColors.brandGreen : AppColors.brandRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
                      )),
                      const SizedBox(height: 3),
                      Text(s.description, style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted, height: 1.4,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(s.outcome, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: s.positive ? AppColors.brandGreen : AppColors.brandRed,
                  fontFamily: 'JetBrainsMono',
                )),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _HistoricalSetup {
  final String title, description, outcome;
  final bool positive;
  const _HistoricalSetup(this.title, this.description, this.outcome, this.positive);
}

class _ConfidenceRing extends StatelessWidget {
  final int confidence;
  final Color color;
  const _ConfidenceRing({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72, height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: confidence / 100,
            strokeWidth: 6,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation(color),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$confidence%', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900,
                color: color, fontFamily: 'JetBrainsMono',
              )),
              const Text('AI conf.', style: TextStyle(
                fontSize: 8, color: AppColors.textMuted,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value, badge;
  final Color badgeColor;
  final IconData icon;
  const _MetricTile({
    required this.label, required this.value,
    required this.badge, required this.badgeColor, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: Colors.white, fontFamily: 'JetBrainsMono',
          )),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(badge, style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: badgeColor, letterSpacing: 0.3,
            )),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final int value;
  const _SentimentBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value > 65 ? AppColors.brandGreen
        : value > 45 ? AppColors.brandAmber
        : AppColors.brandRed;
    final label = value > 65 ? 'Bullish' : value > 45 ? 'Neutral' : 'Bearish';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mood_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              const Text('News & Social Sentiment', style: TextStyle(
                fontSize: 10, color: AppColors.textMuted,
              )),
              const Spacer(),
              Text('$value / 100', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: color, fontFamily: 'JetBrainsMono',
              )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label, style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700, color: color,
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LevelRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(
            fontSize: 11, color: AppColors.textMuted,
          )),
        ),
        Text(value, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: color, fontFamily: 'JetBrainsMono',
        )),
      ],
    );
  }
}