import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/ai_analysis_provider.dart';

const _coins = ['BTC', 'ETH', 'SOL', 'BNB'];

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
                        onCoinChanged: (c) =>
                            ref.read(aiAnalysisProvider).selectCoin(c),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Market summary rebuilds on coin change (shows coin name in text)
                  Consumer(
                    builder: (_, ref, __) {
                      final coin = ref.watch(
                        aiAnalysisProvider.select((n) => n.selectedCoin),
                      );
                      return _MarketSummaryCard(coin: coin);
                    },
                  ),
                  const SizedBox(height: 16),
                  // These cards are static (no dynamic coin references in mock data)
                  const Row(
                    children: [
                      Expanded(child: _SupportResistanceCard()),
                      SizedBox(width: 16),
                      Expanded(child: _SentimentCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _VolatilityCard(),
                  const SizedBox(height: 16),
                  const _KeyLevelsCard(),
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
            Text('AI Market Analysis', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            Text('Deep market intelligence · Powered by GPT-4', style: TextStyle(
              fontSize: 13, color: AppColors.textMuted,
            )),
          ],
        ),
        const Spacer(),
        ...coins.map((c) => GestureDetector(
          onTap: () => onCoinChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selectedCoin == c
                  ? AppColors.brandGreen.withAlpha(20)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedCoin == c
                    ? AppColors.brandGreen.withAlpha(60)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(c, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: selectedCoin == c ? AppColors.brandGreen : AppColors.textMuted,
            )),
          ),
        )),
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
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Market Summary', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                  )),
                  Text('$coin/USDT · Updated 30s ago', style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted,
                  )),
                ],
              ),
              const Spacer(),
              NeonBadge(label: 'Bullish', color: AppColors.brandGreen,
                icon: Icons.trending_up_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$coin is in a bullish trend structure. The price has been making higher highs '
            'and higher lows since the recent break above the \$94K resistance zone. RSI sits '
            'at 67 — strong but not yet overbought. The upcoming resistance zone at '
            '\$98.4K–\$100K will be key. A rejection here could lead to a healthy retracement '
            'to the \$94K–\$96K range before continuation higher. Funding rates remain neutral '
            '(0.023%), indicating organic buying rather than leveraged longs. Smart money is '
            'accumulating on dips.',
            style: const TextStyle(
              fontSize: 13, color: Color(0xCCFFFFFF), height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip('RSI', '67', AppColors.brandAmber),
              const SizedBox(width: 8),
              _StatChip('Funding', '+0.023%', AppColors.brandGreen),
              const SizedBox(width: 8),
              _StatChip('OI', '+12.4%', AppColors.brandGreen),
              const SizedBox(width: 8),
              _StatChip('Vol', '\$48.2B', AppColors.brandBlue),
            ],
          ),
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
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          Text(value, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: color, fontFamily: 'JetBrainsMono',
          )),
        ],
      ),
    );
  }
}

class _SupportResistanceCard extends StatelessWidget {
  const _SupportResistanceCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Support / Resistance', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 16),
          _Level('R3', '\$102,400', AppColors.brandRed, 0.9),
          _Level('R2', '\$100,000', AppColors.brandRed, 0.75),
          _Level('R1', '\$98,400', AppColors.brandRed, 0.6),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandAmber.withAlpha(40)),
            ),
            child: const Row(
              children: [
                Text('CURRENT', style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: AppColors.brandAmber, letterSpacing: 0.5,
                )),
                Spacer(),
                Text('\$97,420', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'JetBrainsMono',
                )),
              ],
            ),
          ),
          _Level('S1', '\$95,800', AppColors.brandGreen, 0.55),
          _Level('S2', '\$93,200', AppColors.brandGreen, 0.35),
          _Level('S3', '\$89,400', AppColors.brandGreen, 0.2),
        ],
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
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha(20), borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(label, style: TextStyle(
              fontSize: 8, fontWeight: FontWeight.w700, color: color,
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
          Text(price, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: color, fontFamily: 'JetBrainsMono',
          )),
        ],
      ),
    );
  }
}

class _SentimentCard extends StatelessWidget {
  const _SentimentCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sentiment Breakdown', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 16),
          _SentimentBar('Bullish', 74, AppColors.brandGreen),
          _SentimentBar('Neutral', 18, AppColors.brandAmber),
          _SentimentBar('Bearish', 8, AppColors.brandRed),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          const Text('AI Verdict', style: TextStyle(
            fontSize: 11, color: AppColors.textMuted,
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
              style: TextStyle(fontSize: 11, color: AppColors.brandGreen, height: 1.5),
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
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text('$percent%', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color,
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
  const _VolatilityCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Volatility Analysis', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                )),
                SizedBox(height: 8),
                Text(
                  'Current volatility (ATR-14) is moderate at 3.2%. '
                  'Historical comparison: lower than the August 2024 high of 8.4%, '
                  'suggesting controlled price action. Good conditions for trend following.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.6),
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
          Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: color,
            fontFamily: 'JetBrainsMono',
          )),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _KeyLevelsCard extends StatelessWidget {
  const _KeyLevelsCard();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Insights', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          SizedBox(height: 12),
          _Insight('Watch for break above \$98,400 — would signal continuation to \$100K',
            Icons.trending_up_rounded, AppColors.brandGreen),
          _Insight('Funding rates neutral — healthy conditions, not overleveraged',
            Icons.balance_rounded, AppColors.brandBlue),
          _Insight('ETF inflows positive for 3rd day — institutional accumulation',
            Icons.account_balance_rounded, AppColors.brandPurple),
          _Insight('Risk: rejection at \$98.4K could cause sharp drop to \$94K',
            Icons.warning_amber_rounded, AppColors.brandAmber),
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
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(20), borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(
            fontSize: 12, color: AppColors.textMuted, height: 1.5,
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
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.brandGreen),
              SizedBox(width: 8),
              Text('Ask AI', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
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
              _ChatBubble(text: 'What is the current BTC market structure?', isUser: true),
              const SizedBox(height: 12),
              _ChatBubble(
                text: 'BTC is in a bullish market structure with higher highs and higher lows. '
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
                    hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, size: 16, color: Colors.black),
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
        const Text('Suggested', style: TextStyle(
          fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5,
        )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: prompts.map((p) => GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(p, style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted,
              )),
            ),
          )).toList(),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
        child: Text(text, style: const TextStyle(
          fontSize: 12, color: Color(0xCCFFFFFF), height: 1.5,
        )),
      ),
    );
  }
}
