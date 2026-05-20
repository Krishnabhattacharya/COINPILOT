import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class NewsSentimentScreen extends StatefulWidget {
  const NewsSentimentScreen({super.key});

  @override
  State<NewsSentimentScreen> createState() => _NewsSentimentScreenState();
}

class _NewsSentimentScreenState extends State<NewsSentimentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _Header(tabController: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _NewsTab(),
                _TwitterTab(),
                _RedditTab(),
                _WhaleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TabController tabController;
  const _Header({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('News & Sentiment', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                  Text('Real-time market sentiment aggregation', style: TextStyle(
                    fontSize: 12, color: AppColors.textMuted,
                  )),
                ],
              ),
              const Spacer(),
              _SentimentMeter(value: 72),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.brandGreen,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            indicatorColor: AppColors.brandGreen,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'News'),
              Tab(text: 'Twitter/X'),
              Tab(text: 'Reddit'),
              Tab(text: 'Whale Activity'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentimentMeter extends StatelessWidget {
  final int value;
  const _SentimentMeter({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value > 60 ? AppColors.brandGreen : value > 45 ? AppColors.brandAmber : AppColors.brandRed;
    final label = value > 60 ? 'Bullish' : value > 45 ? 'Neutral' : 'Bearish';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Text('$value', style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w900, color: color, fontFamily: 'JetBrainsMono',
          )),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color,
              )),
              const Text('Sentiment', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsTab extends StatelessWidget {
  final _news = const [
    _NewsItem('BlackRock Bitcoin ETF records 3rd largest inflow day ever at \$842M', 'bullish', '2h ago', 'Bloomberg'),
    _NewsItem('Federal Reserve signals rate pause in upcoming Q2 meeting', 'bullish', '4h ago', 'Reuters'),
    _NewsItem('Binance lists new DeFi token with \$400M FDV, first day volume surges', 'neutral', '5h ago', 'CoinDesk'),
    _NewsItem('BTC miner capitulation index at 5-year low, suggesting bottom is in', 'bullish', '7h ago', 'CryptoQuant'),
    _NewsItem('SEC approves Bitcoin ETF options trading on Nasdaq', 'bullish', '9h ago', 'WSJ'),
    _NewsItem('Crypto exchange hack: \$45M stolen from DeFi protocol', 'bearish', '11h ago', 'The Block'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _news.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _NewsCard(item: _news[i]),
    );
  }
}

class _NewsItem {
  final String title;
  final String sentiment;
  final String time;
  final String source;
  const _NewsItem(this.title, this.sentiment, this.time, this.source);
}

class _NewsCard extends StatelessWidget {
  final _NewsItem item;
  const _NewsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.sentiment == 'bullish'
        ? AppColors.brandGreen
        : item.sentiment == 'bearish'
            ? AppColors.brandRed
            : AppColors.brandAmber;

    return GlassCard(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: Colors.white, height: 1.4,
                )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.sentiment.toUpperCase(), style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5,
                      )),
                    ),
                    const SizedBox(width: 8),
                    Text(item.source, style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted,
                    )),
                    const Spacer(),
                    Text(item.time, style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TwitterTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Twitter/X Sentiment', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  _TwitterMetric('68%', 'Bullish Tweets', AppColors.brandGreen),
                  const SizedBox(width: 12),
                  _TwitterMetric('124K', 'BTC Posts', AppColors.brandBlue),
                  const SizedBox(width: 12),
                  _TwitterMetric('+42%', 'Vol Change', AppColors.brandAmber),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.bgTertiary,
                      child: Text('@${['trader', 'whale', 'analyst', 'degen', 'bull'][i][0].toUpperCase()}',
                        style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Text('@${['cryptotrader', 'whalealert', 'btcanalyst', 'defi_degen', 'bullmarket'][i]}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    const Spacer(),
                    Text('${[2, 5, 12, 18, 34][i]}m ago', style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ['BTC looking extremely strong here. Higher lows on every timeframe. \$100K incoming 🚀',
                    '2,840 BTC just moved from unknown wallet to Binance. Potential sell incoming?',
                    'RSI at 67 on the daily. Still room to run before overbought territory hits.',
                    'LFG! ETF flows absolutely insane today. Institutions are not selling.',
                    'Bull market confirmed. Every dip is being bought aggressively.'][i],
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _TwitterMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _TwitterMetric(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color,
              fontFamily: 'JetBrainsMono',
            )),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _RedditPost {
  final String subreddit, title, body, sentiment, time;
  final int upvotes, comments;
  const _RedditPost(this.subreddit, this.title, this.body, this.sentiment, this.time, this.upvotes, this.comments);
}

class _RedditTab extends StatelessWidget {
  static const _stats = [
    _TwitterMetric('74%', 'Bullish Posts', AppColors.brandGreen),
    _TwitterMetric('48.2K', 'r/Bitcoin Mentions', AppColors.brandBlue),
    _TwitterMetric('+31%', 'Volume vs 7d Avg', AppColors.brandAmber),
  ];

  static const _posts = [
    _RedditPost('r/Bitcoin', 'BTC broke the descending trendline on daily — this is it',
      'Just broke through the trendline that\'s been holding us down for 3 weeks. Volume confirming. We could see \$102K before any significant pullback. Accumulating here.',
      'bullish', '1h ago', 4820, 312),
    _RedditPost('r/CryptoCurrency', 'ETF inflows hit \$842M today — institutions are not done',
      'BlackRock alone added over 8,700 BTC today. Fidelity added another 4,200. This is relentless demand. Supply on exchanges keeps dropping. This math is simple.',
      'bullish', '3h ago', 3140, 218),
    _RedditPost('r/ethfinance', 'ETH still lagging BTC — ETH/BTC ratio looks ready to break out',
      'The ETH/BTC ratio has been compressing for months. Historically this level precedes an ETH outperformance period. Watching the 0.040 level closely.',
      'neutral', '5h ago', 1890, 167),
    _RedditPost('r/SatoshiStreetBets', 'SOL short squeeze incoming — funding negative, shorts piling in',
      'Funding rate went negative this morning. Shorts are crowded at this level. Every time we\'ve seen this setup on SOL it squeezed hard within 48 hours.',
      'bullish', '7h ago', 2640, 189),
    _RedditPost('r/Bitcoin', 'Careful — we\'re at historical overbought levels, don\'t FOMO',
      'Not saying we crash, but RSI on the weekly is at 78. The last two times we were here we corrected 15-20% before continuing higher. Don\'t put in money you need.',
      'bearish', '10h ago', 5280, 441),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reddit Sentiment', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
              )),
              const SizedBox(height: 16),
              Row(
                children: _stats.asMap().entries.map((e) {
                  final s = e.value;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: e.key < _stats.length - 1 ? 12 : 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: s.color.withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: s.color.withAlpha(25)),
                      ),
                      child: Column(
                        children: [
                          Text(s.value, style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800, color: s.color,
                            fontFamily: 'JetBrainsMono',
                          )),
                          Text(s.label, style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._posts.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RedditCard(post: p),
        )),
      ],
    );
  }
}

class _RedditCard extends StatelessWidget {
  final _RedditPost post;
  const _RedditCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final color = post.sentiment == 'bullish'
        ? AppColors.brandGreen
        : post.sentiment == 'bearish' ? AppColors.brandRed : AppColors.brandAmber;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandRed.withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(post.subreddit, style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.brandRed,
                )),
              ),
              const Spacer(),
              Text(post.time, style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.title, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3,
          )),
          const SizedBox(height: 6),
          Text(post.body, style: const TextStyle(
            fontSize: 11, color: AppColors.textMuted, height: 1.5,
          ), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.arrow_upward_rounded, size: 13, color: AppColors.brandAmber),
              const SizedBox(width: 4),
              Text('${post.upvotes}', style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted,
              )),
              const SizedBox(width: 12),
              Icon(Icons.chat_bubble_outline_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${post.comments}', style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(post.sentiment.toUpperCase(), style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhaleAlert {
  final String symbol, amount, usdValue, from, to, time, type;
  final bool isBearish;
  const _WhaleAlert(this.symbol, this.amount, this.usdValue, this.from, this.to, this.time, this.type, this.isBearish);
}

class _WhaleTab extends StatelessWidget {
  static const _alerts = [
    _WhaleAlert('BTC', '2,840', '\$276.8M', 'Unknown Wallet', 'Binance', '4m', 'Exchange Deposit', true),
    _WhaleAlert('ETH', '18,420', '\$70.8M', 'Coinbase Custody', 'Unknown', '12m', 'Exchange Withdrawal', false),
    _WhaleAlert('USDT', '85,000,000', '\$85.0M', 'Tether Treasury', 'Unknown', '28m', 'Mint', false),
    _WhaleAlert('BTC', '1,200', '\$117.0M', 'Kraken', 'Unknown', '45m', 'Exchange Withdrawal', false),
    _WhaleAlert('ETH', '9,800', '\$37.7M', 'Unknown', 'Coinbase', '1h', 'Exchange Deposit', true),
    _WhaleAlert('SOL', '220,000', '\$40.5M', 'Unknown', 'OKX', '1.5h', 'Exchange Deposit', true),
    _WhaleAlert('BTC', '680', '\$66.2M', 'Unknown', 'Bybit', '2h', 'Exchange Deposit', true),
    _WhaleAlert('USDT', '50,000,000', '\$50.0M', 'Unknown', 'Binance', '3h', 'Stablecoin Transfer', false),
  ];

  @override
  Widget build(BuildContext context) {
    final deposits = _alerts.where((a) => a.type == 'Exchange Deposit').length;
    final withdrawals = _alerts.where((a) => a.type == 'Exchange Withdrawal').length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Whale Activity Summary', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                  )),
                  const Spacer(),
                  NeonBadge(label: 'LIVE', color: AppColors.brandGreen, icon: Icons.circle),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _WhaleStat('$deposits', 'Exchange Deposits', AppColors.brandRed),
                  const SizedBox(width: 12),
                  _WhaleStat('$withdrawals', 'Withdrawals', AppColors.brandGreen),
                  const SizedBox(width: 12),
                  _WhaleStat('\$744M', 'Total Moved (3h)', AppColors.brandAmber),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brandAmber.withAlpha(25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.psychology_rounded, size: 14, color: AppColors.brandAmber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI: Net exchange deposits outpacing withdrawals. Monitor for potential sell pressure. Watch BTC at \$94,200 support.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._alerts.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _WhaleAlertCard(alert: a),
        )),
      ],
    );
  }
}

class _WhaleStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _WhaleStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: color,
              fontFamily: 'JetBrainsMono',
            )),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _WhaleAlertCard extends StatelessWidget {
  final _WhaleAlert alert;
  const _WhaleAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = alert.isBearish ? AppColors.brandRed
        : alert.type == 'Mint' ? AppColors.brandPurple
        : AppColors.brandGreen;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(alert.isBearish ? '🐋' : alert.type == 'Mint' ? '🏦' : '🐳',
                style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${alert.amount} ${alert.symbol}', style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(alert.type, style: TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w700, color: color,
                      )),
                    ),
                  ],
                ),
                Text('${alert.from} → ${alert.to}', style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(alert.usdValue, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: color, fontFamily: 'JetBrainsMono',
              )),
              Text(alert.time + ' ago', style: const TextStyle(
                fontSize: 10, color: AppColors.textDisabled,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
