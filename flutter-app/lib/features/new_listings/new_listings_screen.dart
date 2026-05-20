import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/new_listings_provider.dart';

const _filters = ['All', 'AI', 'Meme', 'DeFi', 'Gaming', 'RWA'];

// Screen is stateless — ChangeNotifierProvider.autoDispose handles lifecycle
class NewListingsScreen extends ConsumerWidget {
  const NewListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Outer build is static — no ref.watch here, only Consumer inside
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
                  const _Header(),
                  const SizedBox(height: 16),
                  // Only filter row rebuilds when filter changes
                  Consumer(
                    builder: (_, ref, __) {
                      final filter = ref.watch(
                        newListingsProvider.select((n) => n.filter),
                      );
                      return _FilterRow(
                        filters: _filters,
                        selected: filter,
                        onChanged: (f) =>
                            ref.read(newListingsProvider).setFilter(f),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Only sliver list rebuilds when filter changes
          Consumer(
            builder: (_, ref, __) {
              final filter = ref.watch(
                newListingsProvider.select((n) => n.filter),
              );
              final filtered = filter == 'All'
                  ? _listings
                  : _listings.where((l) => l.narrative == filter).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ListingCard(listing: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

const _listings = [
  _Listing(
    symbol: 'KEKIUS', name: 'Kekius Maximus', emoji: '🐸',
    exchange: 'Binance', listingDate: '2h ago',
    price: '\$0.0842', change: '+284%',
    volumeSurge: '48x',
    socialSentiment: 92, momentumScore: 88, potentialScore: 78,
    riskLevel: 'High', narrative: 'Meme',
    aiReason: 'Elon-adjacent meme narrative with viral social spread. '
        'Early exchange listing with institutional market makers. '
        'Similar launch pattern to DOGE 2021 and PEPE 2023.',
    whaleActivity: true, smartMoney: true,
  ),
  _Listing(
    symbol: 'AIXT', name: 'AI Execution Token', emoji: '🤖',
    exchange: 'Bybit', listingDate: '5h ago',
    price: '\$2.14', change: '+64%',
    volumeSurge: '12x',
    socialSentiment: 78, momentumScore: 72, potentialScore: 71,
    riskLevel: 'Medium', narrative: 'AI',
    aiReason: 'AI agent infrastructure play. Strong team with prior exits. '
        'Trading volume suggests institutional interest in first 4 hours.',
    whaleActivity: true, smartMoney: false,
  ),
  _Listing(
    symbol: 'RWAX', name: 'RWA Exchange', emoji: '🏦',
    exchange: 'Binance', listingDate: '12h ago',
    price: '\$0.42', change: '+38%',
    volumeSurge: '8x',
    socialSentiment: 65, momentumScore: 60, potentialScore: 68,
    riskLevel: 'Medium', narrative: 'RWA',
    aiReason: 'Real-world asset tokenization narrative with major bank partnerships. '
        'Fundamentally strong with real revenue. Lower risk vs meme plays.',
    whaleActivity: false, smartMoney: true,
  ),
  _Listing(
    symbol: 'GMFI', name: 'GameFi Protocol', emoji: '🎮',
    exchange: 'Bybit', listingDate: '1d ago',
    price: '\$0.18', change: '+12%',
    volumeSurge: '3x',
    socialSentiment: 48, momentumScore: 42, potentialScore: 45,
    riskLevel: 'Low', narrative: 'Gaming',
    aiReason: 'Solid gaming infrastructure with 200K beta users. '
        'Early momentum has slowed. Good for accumulation if narrative revives.',
    whaleActivity: false, smartMoney: false,
  ),
];

class _Listing {
  final String symbol, name, emoji, exchange, listingDate;
  final String price, change, volumeSurge;
  final int socialSentiment, momentumScore, potentialScore;
  final String riskLevel, narrative, aiReason;
  final bool whaleActivity, smartMoney;

  const _Listing({
    required this.symbol, required this.name, required this.emoji,
    required this.exchange, required this.listingDate,
    required this.price, required this.change, required this.volumeSurge,
    required this.socialSentiment, required this.momentumScore,
    required this.potentialScore, required this.riskLevel,
    required this.narrative, required this.aiReason,
    required this.whaleActivity, required this.smartMoney,
  });
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Listings', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            Text('Binance & Bybit · AI early momentum detection', style: TextStyle(
              fontSize: 12, color: AppColors.textMuted,
            )),
          ],
        ),
        const Spacer(),
        NeonBadge(label: 'LIVE', color: AppColors.brandGreen, icon: Icons.circle),
        const SizedBox(width: 8),
        NeonBadge(label: '4 new today', color: AppColors.brandAmber),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) => GestureDetector(
          onTap: () => onChanged(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected == f ? AppColors.brandGreen.withAlpha(20) : AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected == f
                    ? AppColors.brandGreen.withAlpha(60)
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(f, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: selected == f ? AppColors.brandGreen : AppColors.textMuted,
            )),
          ),
        )).toList(),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final _Listing listing;
  const _ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final riskColor = listing.riskLevel == 'High'
        ? AppColors.brandRed
        : listing.riskLevel == 'Medium'
            ? AppColors.brandAmber
            : AppColors.brandGreen;

    const narrativeColor = {
      'Meme': AppColors.brandGreen,
      'AI': AppColors.brandPurple,
      'DeFi': AppColors.brandBlue,
      'Gaming': AppColors.brandCyan,
      'RWA': AppColors.brandAmber,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Center(child: Text(listing.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(listing.symbol, style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (narrativeColor[listing.narrative] ?? AppColors.brandGreen)
                                .withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(listing.narrative, style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: narrativeColor[listing.narrative] ?? AppColors.brandGreen,
                          )),
                        ),
                      ],
                    ),
                    Text('${listing.name} · ${listing.exchange}', style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted,
                    )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(listing.price, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'JetBrainsMono',
                  )),
                  Text(listing.change, style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.brandGreen, fontFamily: 'JetBrainsMono',
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Score('Social', listing.socialSentiment, AppColors.brandBlue),
              const SizedBox(width: 8),
              _Score('Momentum', listing.momentumScore, AppColors.brandAmber),
              const SizedBox(width: 8),
              _Score('AI Score', listing.potentialScore, AppColors.brandGreen),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill('Vol Surge', listing.volumeSurge, AppColors.brandCyan),
              const SizedBox(width: 8),
              _StatPill('Listed', listing.listingDate, AppColors.textMuted),
              const SizedBox(width: 8),
              _StatPill('Risk', listing.riskLevel, riskColor),
              if (listing.whaleActivity) ...[
                const SizedBox(width: 8),
                _StatPill('🐋 Whale', 'Active', AppColors.brandPurple),
              ],
              if (listing.smartMoney) ...[
                const SizedBox(width: 8),
                _StatPill('🏦 Smart', 'Money', AppColors.brandGreen),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Why this coin may have potential:', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brandGreen,
                    )),
                    const SizedBox(height: 4),
                    Text(listing.aiReason, style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted, height: 1.5,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Score(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              Text('$value', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: color,
                fontFamily: 'JetBrainsMono',
              )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
          Text(value, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color,
          )),
        ],
      ),
    );
  }
}