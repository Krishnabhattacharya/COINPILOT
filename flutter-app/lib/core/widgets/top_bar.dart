import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Live indicator
          _LiveIndicator(),
          const SizedBox(width: 16),

          // Market ticker (desktop)
          if (MediaQuery.of(context).size.width >= 1024) ...[
            _MarketTicker(),
            const Spacer(),
          ] else
            const Spacer(),

          // Search
          _SearchButton(),
          const SizedBox(width: 8),

          // Notifications
          _NotificationButton(),
          const SizedBox(width: 8),

          // Theme toggle
          _ThemeButton(),
        ],
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandGreen.withOpacity(0.4 + 0.6 * _controller.value),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen.withOpacity(0.3 * _controller.value),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'LIVE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.brandGreen,
            letterSpacing: 1.2,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      ],
    );
  }
}

class _MarketTicker extends StatelessWidget {
  final _items = const [
    _TickerItem('BTC', '\$97,420', true),
    _TickerItem('ETH', '\$3,842', true),
    _TickerItem('SOL', '\$184', false),
    _TickerItem('BNB', '\$612', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.symbol,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontFamily: 'JetBrainsMono',
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.price,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _TickerItem {
  final String symbol;
  final String price;
  final bool positive;
  const _TickerItem(this.symbol, this.price, this.positive);
}

class _SearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _TopBarButton(
      icon: Icons.search_rounded,
      onTap: () => _showSearchOverlay(context),
    );
  }

  void _showSearchOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'search',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => const _SearchDialog(),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _controller = TextEditingController();
  String _query = '';

  static const _coins = [
    _SearchItem('BTC', 'Bitcoin · \$97,420', '/analysis', Icons.currency_bitcoin_rounded, Color(0xFFF7931A)),
    _SearchItem('ETH', 'Ethereum · \$3,842', '/analysis', Icons.water_drop_rounded, Color(0xFF627EEA)),
    _SearchItem('SOL', 'Solana · \$184', '/analysis', Icons.flash_on_rounded, Color(0xFF9945FF)),
    _SearchItem('BNB', 'BNB · \$612', '/analysis', Icons.circle_rounded, Color(0xFFF3BA2F)),
    _SearchItem('XRP', 'Ripple · \$2.14', '/analysis', Icons.waves_rounded, Color(0xFF0085C3)),
    _SearchItem('DOGE', 'Dogecoin · \$0.182', '/analysis', Icons.pets_rounded, Color(0xFFC2A633)),
  ];

  static const _screens = [
    _SearchItem('Dashboard', 'Market overview & live data', '/dashboard', Icons.dashboard_rounded, AppColors.brandGreen),
    _SearchItem('Trade Now?', 'AI trading signal aggregator', '/trade-now', Icons.bolt_rounded, AppColors.brandGreen),
    _SearchItem('AI Analysis', 'Deep AI coin analysis', '/analysis', Icons.psychology_rounded, AppColors.brandPurple),
    _SearchItem('Charts', 'Candlestick & technical analysis', '/charts', Icons.candlestick_chart_rounded, AppColors.brandBlue),
    _SearchItem('Sentiment', 'News & social sentiment', '/sentiment', Icons.sentiment_satisfied_rounded, AppColors.brandAmber),
    _SearchItem('New Listings', 'New coin listings & AI scoring', '/listings', Icons.new_releases_rounded, AppColors.brandGreen),
    _SearchItem('Order Book', 'Bid/ask walls & depth', '/orderbook', Icons.menu_rounded, AppColors.brandBlue),
    _SearchItem('Exchange Flows', 'On-chain inflows & outflows', '/onchain', Icons.account_tree_rounded, AppColors.brandCyan),
    _SearchItem('Token Unlocks', 'Vesting schedule & risk', '/token-unlocks', Icons.lock_open_rounded, AppColors.brandAmber),
    _SearchItem('Portfolio', 'Holdings & P&L tracker', '/portfolio', Icons.pie_chart_rounded, AppColors.brandPurple),
    _SearchItem('Risk Manager', 'Position sizing & risk tools', '/risk', Icons.shield_rounded, AppColors.brandRed),
    _SearchItem('Trade Journal', 'Log & review your trades', '/journal', Icons.book_rounded, AppColors.brandBlue),
    _SearchItem('Alerts', 'Price & signal alerts', '/alerts', Icons.notifications_rounded, AppColors.brandAmber),
    _SearchItem('AI Chat', 'Chat with AI copilot', '/chat', Icons.chat_bubble_outline_rounded, AppColors.brandGreen),
    _SearchItem('Profile', 'Settings & account', '/profile', Icons.person_rounded, AppColors.textMuted),
  ];

  List<_SearchItem> get _filtered {
    if (_query.isEmpty) return [..._coins.take(4), ..._screens.take(4)];
    final q = _query.toLowerCase();
    final coins = _coins.where((i) =>
      i.title.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
    final screens = _screens.where((i) =>
      i.title.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
    return [...coins, ...screens];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.08,
          left: 20, right: 20,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                          onChanged: (v) => setState(() => _query = v),
                          decoration: const InputDecoration(
                            hintText: 'Search coins or navigate screens...',
                            hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ESC', style: TextStyle(
                            fontSize: 10, color: AppColors.textMuted, fontFamily: 'JetBrainsMono',
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.borderSubtle, height: 1),
                if (_query.isEmpty) ...[
                  _SectionHeader('Coins'),
                ],
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final isFirstScreen = _query.isEmpty && i == 4;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFirstScreen) _SectionHeader('Screens'),
                          _SearchResultRow(
                            item: item,
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go(item.route);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No results found', style: TextStyle(
                      fontSize: 14, color: AppColors.textMuted,
                    )),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(label, style: const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: AppColors.textDisabled, letterSpacing: 1.0,
      )),
    );
  }
}

class _SearchItem {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  const _SearchItem(this.title, this.subtitle, this.route, this.icon, this.color);
}

class _SearchResultRow extends StatelessWidget {
  final _SearchItem item;
  final VoidCallback onTap;
  const _SearchResultRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 16, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                  )),
                  Text(item.subtitle, style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted,
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TopBarButton(
          icon: Icons.notifications_outlined,
          onTap: () => context.go('/alerts'),
        ),
        Positioned(
          top: 2, right: 2,
          child: Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
              color: AppColors.brandRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _TopBarButton(
      icon: Icons.wb_sunny_outlined,
      onTap: () {},
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 17, color: AppColors.textMuted),
      ),
    );
  }
}