import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class _Unlock {
  final String symbol, name, emoji;
  final String date, daysLeft;
  final String amount, usdValue;
  final double supplyPct;
  final String riskLevel;
  final String priceImpact;
  final String category;
  final String notes;

  const _Unlock({
    required this.symbol, required this.name, required this.emoji,
    required this.date, required this.daysLeft,
    required this.amount, required this.usdValue,
    required this.supplyPct, required this.riskLevel,
    required this.priceImpact, required this.category, required this.notes,
  });
}

const _unlocks = [
  _Unlock(
    symbol: 'APT', name: 'Aptos', emoji: '⚡',
    date: 'May 22, 2026', daysLeft: '2 days',
    amount: '11.3M APT', usdValue: '\$89.7M',
    supplyPct: 4.2,
    riskLevel: 'HIGH',
    priceImpact: '-8% to -15%',
    category: 'Team & Investors',
    notes: 'Large team unlock from initial vesting cliff. Insiders historically sell within 2 weeks.',
  ),
  _Unlock(
    symbol: 'ARB', name: 'Arbitrum', emoji: '🔷',
    date: 'May 28, 2026', daysLeft: '8 days',
    amount: '92.7M ARB', usdValue: '\$121.5M',
    supplyPct: 2.8,
    riskLevel: 'HIGH',
    priceImpact: '-5% to -12%',
    category: 'Investors',
    notes: 'Quarterly investor unlock per vesting schedule. Similar unlock in Feb caused -9% in 3 days.',
  ),
  _Unlock(
    symbol: 'WLD', name: 'Worldcoin', emoji: '🌐',
    date: 'Jun 3, 2026', daysLeft: '14 days',
    amount: '18.5M WLD', usdValue: '\$48.1M',
    supplyPct: 3.1,
    riskLevel: 'MEDIUM',
    priceImpact: '-3% to -8%',
    category: 'Team',
    notes: 'Monthly linear unlock for team members. Price has stabilized around unlock dates recently.',
  ),
  _Unlock(
    symbol: 'SUI', name: 'Sui', emoji: '💧',
    date: 'Jun 10, 2026', daysLeft: '21 days',
    amount: '64.2M SUI', usdValue: '\$76.3M',
    supplyPct: 1.9,
    riskLevel: 'MEDIUM',
    priceImpact: '-2% to -6%',
    category: 'Early Contributors',
    notes: 'Smaller relative unlock. Ecosystem fund keeps buying pressure to offset sell pressure.',
  ),
  _Unlock(
    symbol: 'STRK', name: 'Starknet', emoji: '⭐',
    date: 'Jun 15, 2026', daysLeft: '26 days',
    amount: '128M STRK', usdValue: '\$92.2M',
    supplyPct: 8.5,
    riskLevel: 'EXTREME',
    priceImpact: '-15% to -30%',
    category: 'Foundation & Investors',
    notes: 'Massive 8.5% supply unlock. Investors have been selling every unlock since TGE. Avoid long exposure.',
  ),
  _Unlock(
    symbol: 'IMX', name: 'Immutable', emoji: '🎮',
    date: 'Jul 1, 2026', daysLeft: '42 days',
    amount: '22.8M IMX', usdValue: '\$41.2M',
    supplyPct: 1.5,
    riskLevel: 'LOW',
    priceImpact: '-1% to -3%',
    category: 'Ecosystem Fund',
    notes: 'Ecosystem allocation used for grants and development. Typically not sold on market.',
  ),
];

class TokenUnlocksScreen extends StatefulWidget {
  const TokenUnlocksScreen({super.key});

  @override
  State<TokenUnlocksScreen> createState() => _TokenUnlocksScreenState();
}

class _TokenUnlocksScreenState extends State<TokenUnlocksScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Unlock> get _filtered {
    if (_query.isEmpty) return _unlocks;
    final q = _query.toLowerCase();
    return _unlocks.where((u) =>
      u.symbol.toLowerCase().contains(q) ||
      u.name.toLowerCase().contains(q) ||
      u.category.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final highRisk = _unlocks.where((u) => u.riskLevel == 'HIGH' || u.riskLevel == 'EXTREME').length;

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
                  _buildHeader('\$469.0M', highRisk),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  if (_query.isEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSummaryRow(),
                    const SizedBox(height: 20),
                    _buildTimeline(),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    _query.isEmpty
                      ? 'Upcoming Unlocks'
                      : '${filtered.length} result${filtered.length == 1 ? '' : 's'} for "$_query"',
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No unlocks found for "$_query"',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UnlockCard(unlock: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
          ),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search by coin, name or category...',
                hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String totalValue, int highRisk) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Token Unlocks', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5,
              )),
              Text('Vesting schedule · Price impact · Risk assessment',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        NeonBadge(label: '6 upcoming', color: AppColors.brandAmber),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _SummaryTile('\$469M', 'Total Unlock Value', '42 days', AppColors.brandAmber)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryTile('3', 'High Risk Events', 'Monitor closely', AppColors.brandRed)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryTile('STRK', 'Biggest Risk', '8.5% supply', AppColors.brandRed)),
      ],
    );
  }

  Widget _buildTimeline() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unlock Timeline (Next 42 Days)', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 16),
          ..._unlocks.map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(u.daysLeft, style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted,
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${u.emoji} ${u.symbol}', style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                          )),
                          const Spacer(),
                          Text(u.usdValue, style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: _riskColor(u.riskLevel),
                            fontFamily: 'JetBrainsMono',
                          )),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: u.supplyPct / 10,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation(_riskColor(u.riskLevel)),
                          minHeight: 3,
                        ),
                      ),
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

Color _riskColor(String risk) {
  switch (risk) {
    case 'EXTREME': return AppColors.brandRed;
    case 'HIGH': return AppColors.brandAmber;
    case 'MEDIUM': return AppColors.brandBlue;
    default: return AppColors.brandGreen;
  }
}

class _SummaryTile extends StatelessWidget {
  final String value, label, sub;
  final Color color;
  const _SummaryTile(this.value, this.label, this.sub, this.color);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w900,
            color: color, fontFamily: 'JetBrainsMono',
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _UnlockCard extends StatelessWidget {
  final _Unlock unlock;
  const _UnlockCard({super.key, required this.unlock});

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(unlock.riskLevel);

    return GlassCard(
      borderColor: color.withAlpha(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Center(child: Text(unlock.emoji,
                  style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(unlock.symbol, style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(unlock.riskLevel, style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700, color: color,
                          )),
                        ),
                      ],
                    ),
                    Text('${unlock.name} · ${unlock.category}', style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted,
                    )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(unlock.usdValue, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'JetBrainsMono',
                  )),
                  Text(unlock.date, style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted,
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _UnlockStat('Amount', unlock.amount, AppColors.textMuted),
              const SizedBox(width: 8),
              _UnlockStat('% Supply', '${unlock.supplyPct}%', color),
              const SizedBox(width: 8),
              _UnlockStat('In', unlock.daysLeft, AppColors.brandBlue),
              const SizedBox(width: 8),
              _UnlockStat('Est. Impact', unlock.priceImpact, color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 13, color: AppColors.brandAmber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(unlock.notes, style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted, height: 1.5,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnlockStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _UnlockStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textDisabled)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color,
            )),
          ],
        ),
      ),
    );
  }
}