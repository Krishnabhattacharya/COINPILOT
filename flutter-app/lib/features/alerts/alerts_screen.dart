import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/alerts_provider.dart';

// Outer build is static — _recentAlerts list never rebuilds
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Alert Center',
              subtitle: 'Configure your market intelligence alerts',
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent alerts are static mock data — never rebuild
                 Expanded(
                  flex: 2,
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Alerts', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                        )),
                        SizedBox(height: 12),
                        ..._recentAlerts.map((a) => _AlertItem(alert: a)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alert Settings', style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                            )),
                            const SizedBox(height: 12),
                            // Only switches column rebuilds on toggle
                            Consumer(
                              builder: (_, ref, __) {
                                final switches = ref.watch(
                                  alertsProvider.select((n) => n.switches),
                                );
                                return Column(
                                  children: switches.entries.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(e.key, style: const TextStyle(
                                          fontSize: 12, color: AppColors.textMuted,
                                        ))),
                                        Switch(
                                          value: e.value,
                                          onChanged: (v) =>
                                              ref.read(alertsProvider).toggle(e.key, v),
                                          activeColor: AppColors.brandGreen,
                                          inactiveTrackColor: AppColors.borderSubtle,
                                          trackOutlineColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Push Notifications', style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                            )),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.brandGreen.withAlpha(10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.brandGreen.withAlpha(25)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                    color: AppColors.brandGreen, size: 16),
                                  SizedBox(width: 8),
                                  Text('Notifications enabled', style: TextStyle(
                                    fontSize: 12, color: AppColors.brandGreen,
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _recentAlerts = [
    _Alert(Icons.warning_rounded, 'Funding Rate Spike',
      'ARB/USDT funding reached +0.085% — elevated squeeze risk',
      AppColors.brandRed, '2m ago'),
    _Alert(Icons.water_rounded, 'Whale Alert',
      '2,840 BTC transferred to Binance from unknown wallet',
      AppColors.brandPurple, '4m ago'),
    _Alert(Icons.new_releases_rounded, 'New Listing',
      'KEKIUS listed on Binance — AI score: 78/100',
      AppColors.brandGreen, '2h ago'),
    _Alert(Icons.sentiment_satisfied_rounded, 'Sentiment Shift',
      'BTC sentiment shifted from Neutral → Bullish (68% → 74%)',
      AppColors.brandBlue, '3h ago'),
    _Alert(Icons.bolt_rounded, 'Volatility Alert',
      'ETH 15m volatility spike detected — ATR x3 normal',
      AppColors.brandAmber, '5h ago'),
    _Alert(Icons.flag_rounded, 'Price Target',
      'BTC approaching R1 resistance at \$98,400',
      AppColors.brandCyan, '6h ago'),
  ];
}

class _Alert {
  final IconData icon;
  final String title, message;
  final Color color;
  final String time;
  const _Alert(this.icon, this.title, this.message, this.color, this.time);
}

class _AlertItem extends StatelessWidget {
  final _Alert alert;
  const _AlertItem({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: alert.color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(alert.icon, color: alert.color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
                )),
                const SizedBox(height: 2),
                Text(alert.message, style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted, height: 1.4,
                )),
              ],
            ),
          ),
          Text(alert.time, style: const TextStyle(
            fontSize: 10, color: AppColors.textDisabled,
          )),
        ],
      ),
    );
  }
}
