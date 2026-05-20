import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class FearGreedWidget extends StatelessWidget {
  const FearGreedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const value = 72;
    final color = value > 75
        ? AppColors.brandRed
        : value > 55
            ? AppColors.brandGreen
            : value > 45
                ? AppColors.brandAmber
                : AppColors.brandRed;
    const label = 'Greed';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Fear & Greed Index',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              NeonBadge(label: 'Live', color: AppColors.brandGreen),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: CircularPercentIndicator(
              radius: 52.0,
              lineWidth: 10.0,
              percent: value / 100,
              animation: true,
              animationDuration: 800,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: color,
              backgroundColor: AppColors.borderSubtle,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ScaleItem('Fear', AppColors.brandRed, 0),
              _ScaleItem('Neutral', AppColors.brandAmber, 50),
              _ScaleItem('Greed', AppColors.brandGreen, 100),
            ].map((w) => Expanded(child: w)).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          _HistoryRow(),
        ],
      ),
    );
  }
}


class _ScaleItem extends StatelessWidget {
  final String label;
  final Color color;
  final int value;
  _ScaleItem(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
        )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _history = const [
    ('Yesterday', 65, 'Greed'),
    ('Last Week', 48, 'Neutral'),
    ('Last Month', 31, 'Fear'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _history.map((item) {
        final color = item.$2 > 60
            ? AppColors.brandGreen
            : item.$2 > 45
                ? AppColors.brandAmber
                : AppColors.brandRed;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(item.$1, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text(item.$3, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('${item.$2}', style: TextStyle(
                fontSize: 11, color: color, fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w700,
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
