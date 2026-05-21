import 'package:ai_trading_copilot/core/remote/data/analysis/analysis_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/coin_selector.dart';
import '../../providers/ai_analysis_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/charts_provider.dart';

const _coins = ['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'DOGE'];

String _coinIdFromSymbol(String s) {
  const map = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'BNB': 'binancecoin',
    'XRP': 'ripple',
    'DOGE': 'dogecoin',
    'ADA': 'cardano',
    'AVAX': 'avalanche-2',
  };
  return map[s.toUpperCase()] ?? s.toLowerCase();
}

// ConsumerStatefulWidget — keeps TextEditingController, stateless coin selection
class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Row(
        children: [
          // Main analysis panel
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (coin selector) rebuilds on coin change
                  Consumer(
                    builder: (_, ref, __) {
                      final coin = ref.watch(
                        aiAnalysisProvider.select((n) => n.selectedCoin),
                      );
                      return _Header(
                        selectedCoin: coin,
                        coins: _coins,
                        onCoinChanged: (c) {
                          ref.read(aiAnalysisProvider).selectCoin(c);
                          ref.read(chartsProvider).setCoin(c);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // All dynamic cards in one scope to share coin state
                  Consumer(
                    builder: (_, ref, __) {
                      final coin = ref.watch(
                        aiAnalysisProvider.select((n) => n.selectedCoin),
                      );
                      final tickerAsync = ref.watch(tickerProvider);
                      final currentPrice = tickerAsync.maybeWhen(
                        data: (live) => live['${coin}USDT']?.close,
                        orElse: () => null,
                      );

                      return Column(
                        children: [
                          _MarketSummaryCard(coin: coin),
                          const SizedBox(height: 16),
                          // Dynamic cards with coin-specific AI analysis
                          Consumer(builder: (_, ref, __) {
                            final coinId = _coinIdFromSymbol(coin);
                            final async = ref.watch(coinAiProvider(coinId));
                            return async.when(
                              loading: () => Row(
                                children: [
                                  Expanded(
                                      child: _SupportResistanceCard(
                                          currentPrice: currentPrice)),
                                  const SizedBox(width: 16),
                                  const Expanded(child: _SentimentCard()),
                                ],
                              ),
                              error: (_, __) => Row(
                                children: [
                                  Expanded(
                                      child: _SupportResistanceCard(
                                          currentPrice: currentPrice)),
                                  const SizedBox(width: 16),
                                  const Expanded(child: _SentimentCard()),
                                ],
                              ),
                              data: (a) {
                                final displayPrice = currentPrice ??
                                    a.currentPriceUsd ??
                                    a.analysis.currentPriceUsd;
                                return Row(
                                  children: [
                                    Expanded(
                                        child: _SupportResistanceCard(
                                            keyLevels: a.analysis.keyLevels,
                                            currentPrice: displayPrice)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: _SentimentCard(
                                            sentiment:
                                                a.analysis.sentimentBreakdown)),
                                  ],
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                          Consumer(builder: (_, ref, __) {
                            final coinId = _coinIdFromSymbol(coin);
                            final async = ref.watch(coinAiProvider(coinId));
                            return async.when(
                              loading: () => const SizedBox(height: 120),
                              error: (_, __) => const _VolatilityCard(),
                              data: (a) => _VolatilityCard(
                                  volatilityAnalysis:
                                      a.analysis.volatilityAnalysis),
                            );
                          }),
                          const SizedBox(height: 16),
                          Consumer(builder: (_, ref, __) {
                            final coinId = _coinIdFromSymbol(coin);
                            final async = ref.watch(coinAiProvider(coinId));
                            return async.when(
                              loading: () => const SizedBox(height: 180),
                              error: (_, __) => const _KeyLevelsCard(),
                              data: (a) => _KeyLevelsCard(
                                  insights: a.analysis.keyInsights),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Sidebar chat panel — static, no state dependency
          Container(
            width: 340,
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(left: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _AiChatPanel(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String selectedCoin;
  final List<String> coins;
  final ValueChanged<String> onCoinChanged;

  const _Header({
    required this.selectedCoin,
    required this.coins,
    required this.onCoinChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Market Analysis',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
            Text('Deep market intelligence · Powered by GPT-4',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                )),
          ],
        ),
        const Spacer(),
        Flexible(
          fit: FlexFit.loose,
          child: CoinSelector(selected: selectedCoin, onChanged: onCoinChanged),
        ),
      ],
    );
  }
}

class _MarketSummaryCard extends StatelessWidget {
  final String coin;
  const _MarketSummaryCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.brandGreen.withAlpha(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.black, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Market Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text('$coin/USDT · Updated 30s ago',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      )),
                ],
              ),
              const Spacer(),
              NeonBadge(
                  label: 'Bullish',
                  color: AppColors.brandGreen,
                  icon: Icons.trending_up_rounded),
            ],
          ),
          const SizedBox(height: 16),
          // Use coin-specific AI analysis when available (resolve coinId slug)
          Consumer(builder: (_, ref, __) {
            final coinId = _coinIdFromSymbol(coin);
            final async = ref.watch(coinAiProvider(coinId));
            return async.when(
              loading: () => const Text('Loading AI analysis...',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xCCFFFFFF), height: 1.7)),
              error: (_, __) => const Text('Could not load AI analysis',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xCCFFFFFF), height: 1.7)),
              data: (a) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.analysis.summary,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xCCFFFFFF), height: 1.7)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatChip(
                          'Trend',
                          a.analysis.trendDirection,
                          a.analysis.trendDirection.toLowerCase() == 'bullish'
                              ? AppColors.brandGreen
                              : AppColors.brandRed),
                      const SizedBox(width: 8),
                      _StatChip('Confidence', '${a.analysis.confidenceScore}%',
                          AppColors.brandAmber),
                      const SizedBox(width: 8),
                      _StatChip('Volatility', a.analysis.volatilityAnalysis,
                          AppColors.brandBlue),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          Text(value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'JetBrainsMono',
              )),
        ],
      ),
    );
  }
}

class _SupportResistanceCard extends StatelessWidget {
  final KeyLevels? keyLevels;
  final double? currentPrice;
  const _SupportResistanceCard({this.keyLevels, this.currentPrice});

  @override
  Widget build(BuildContext context) {
    final levels = keyLevels;
    final hasResistance = levels != null && levels.resistance.isNotEmpty;
    final hasSupport = levels != null && levels.support.isNotEmpty;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Support / Resistance',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 16),
          if (hasResistance) ...[
            ...levels.resistance
                .map((r) => _Level(r.label, '\$${r.price.toStringAsFixed(2)}',
                    AppColors.brandRed, 0.6))
                .toList(),
          ] else ...[
            _Level('R3', '\$102,400', AppColors.brandRed, 0.9),
            _Level('R2', '\$100,000', AppColors.brandRed, 0.75),
            _Level('R1', '\$98,400', AppColors.brandRed, 0.6),
          ],
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandAmber.withAlpha(40)),
            ),
            child: Row(
              children: [
                const Text('CURRENT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandAmber,
                      letterSpacing: 0.5,
                    )),
                const Spacer(),
                _SupportPriceText(currentPrice: currentPrice),
              ],
            ),
          ),
          if (hasSupport) ...[
            ...levels.support
                .map((s) => _Level(s.label, '\$${s.price.toStringAsFixed(2)}',
                    AppColors.brandGreen, 0.55))
                .toList(),
          ] else ...[
            _Level('S1', '\$95,800', AppColors.brandGreen, 0.55),
            _Level('S2', '\$93,200', AppColors.brandGreen, 0.35),
            _Level('S3', '\$89,400', AppColors.brandGreen, 0.2),
          ],
        ],
      ),
    );
  }
}

class _SupportPriceText extends StatefulWidget {
  final double? currentPrice;
  const _SupportPriceText({super.key, required this.currentPrice});

  @override
  State<_SupportPriceText> createState() => _SupportPriceTextState();
}

class _SupportPriceTextState extends State<_SupportPriceText> {
  Color _textColor = Colors.white;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant _SupportPriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cur = widget.currentPrice;
    final prev = oldWidget.currentPrice;

    if (cur != null && prev != null && cur != prev) {
      _timer?.cancel();
      setState(() {
        _textColor = cur > prev ? AppColors.brandGreen : AppColors.brandRed;
      });
      _timer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _textColor = Colors.white;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cur = widget.currentPrice;
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _textColor,
        fontFamily: 'JetBrainsMono',
      ),
      child: Text(
        cur != null
            ? cur >= 1000
                ? '\$${cur.toStringAsFixed(0)}'
                : '\$${cur.toStringAsFixed(2)}'
            : '--',
      ),
    );
  }
}

class _Level extends StatelessWidget {
  final String label, price;
  final Color color;
  final double strength;
  const _Level(this.label, this.price, this.color, this.strength);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: AppColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation(color.withAlpha(100)),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(price,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'JetBrainsMono',
              )),
        ],
      ),
    );
  }
}

class _SentimentCard extends StatelessWidget {
  final SentimentBreakdown? sentiment;
  const _SentimentCard({this.sentiment});

  @override
  Widget build(BuildContext context) {
    final s = sentiment;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sentiment Breakdown',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 16),
          if (s != null) ...[
            _SentimentBar('Bullish', s.bullish, AppColors.brandGreen),
            _SentimentBar('Neutral', s.neutral, AppColors.brandAmber),
            _SentimentBar('Bearish', s.bearish, AppColors.brandRed),
          ] else ...[
            _SentimentBar('Bullish', 74, AppColors.brandGreen),
            _SentimentBar('Neutral', 18, AppColors.brandAmber),
            _SentimentBar('Bearish', 8, AppColors.brandRed),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          const Text('AI Verdict',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withAlpha(10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandGreen.withAlpha(25)),
            ),
            child: const Text(
              'Strong bullish consensus. Market structure supports continuation if \$95K holds.',
              style: TextStyle(
                  fontSize: 11, color: AppColors.brandGreen, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  const _SentimentBar(this.label, this.percent, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text('$percent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'JetBrainsMono',
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolatilityCard extends StatelessWidget {
  final String? volatilityAnalysis;
  const _VolatilityCard({this.volatilityAnalysis});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Volatility Analysis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                const SizedBox(height: 8),
                Text(
                  volatilityAnalysis ??
                      'Current volatility (ATR-14) is moderate at 3.2%. '
                          'Historical comparison: lower than the August 2024 high of 8.4%, '
                          'suggesting controlled price action. Good conditions for trend following.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              _VolMetric('ATR-14', '3.2%', AppColors.brandAmber),
              const SizedBox(height: 8),
              _VolMetric('IV Rank', '38%', AppColors.brandBlue),
              const SizedBox(height: 8),
              _VolMetric('BB Width', '4.1%', AppColors.brandPurple),
            ],
          ),
        ],
      ),
    );
  }
}

class _VolMetric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _VolMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'JetBrainsMono',
              )),
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _KeyLevelsCard extends StatelessWidget {
  final List<String>? insights;
  const _KeyLevelsCard({this.insights});

  @override
  Widget build(BuildContext context) {
    final items = insights ??
        [
          'Watch for break above \$98,400 — would signal continuation to \$100K',
          'Funding rates neutral — healthy conditions, not overleveraged',
          'ETF inflows positive for 3rd day — institutional accumulation',
          'Risk: rejection at \$98.4K could cause sharp drop to \$94K',
        ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Insights',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) {
            final colors = [
              AppColors.brandGreen,
              AppColors.brandBlue,
              AppColors.brandPurple,
              AppColors.brandAmber
            ];
            final icons = [
              Icons.trending_up_rounded,
              Icons.balance_rounded,
              Icons.account_balance_rounded,
              Icons.warning_amber_rounded
            ];
            final idx = e.key % colors.length;
            return _Insight(e.value, icons[idx], colors[idx]);
          }).toList(),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _Insight(this.text, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ))),
        ],
      ),
    );
  }
}

class _AiChatPanel extends StatelessWidget {
  final TextEditingController controller;
  const _AiChatPanel({required this.controller});

  static const _prompts = [
    'Why is BTC pumping today?',
    'What is the next resistance?',
    'Is this a good entry point?',
    'Explain the funding rate',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: const Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppColors.brandGreen),
              SizedBox(width: 8),
              Text('Ask AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SuggestedPrompts(prompts: _prompts),
              const SizedBox(height: 16),
              _ChatBubble(
                  text: 'What is the current BTC market structure?',
                  isUser: true),
              const SizedBox(height: 12),
              _ChatBubble(
                text:
                    'BTC is in a bullish market structure with higher highs and higher lows. '
                    'The price broke above the key \$94K resistance and is now testing \$97.4K. '
                    'The trend remains intact as long as we hold above \$93K.',
                isUser: false,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ask about the market...',
                    hintStyle:
                        TextStyle(color: AppColors.textDisabled, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded,
                    size: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestedPrompts extends StatelessWidget {
  final List<String> prompts;
  const _SuggestedPrompts({required this.prompts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggested',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: prompts
              .map((p) => GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(p,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          )),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.brandGreen.withAlpha(20) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUser
                ? AppColors.brandGreen.withAlpha(40)
                : AppColors.borderSubtle,
          ),
        ),
        child: Text(text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xCCFFFFFF),
              height: 1.5,
            )),
      ),
    );
  }
}
