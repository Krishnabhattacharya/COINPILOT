import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/risk_provider.dart';

// Outer build is static — SectionHeader and _RiskTips never rebuild
class RiskManagementScreen extends ConsumerWidget {
  const RiskManagementScreen({super.key});

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
              title: 'Risk Management',
              subtitle: 'AI-powered position sizing and risk assessment',
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Calculator + results rebuild together on any slider change
                      Consumer(
                        builder: (_, ref, __) {
                          final n = ref.watch(riskProvider);
                          return _CalculatorCard(
                            capital: n.capital,
                            leverage: n.leverage,
                            riskPercent: n.riskPercent,
                            entryPrice: n.entryPrice,
                            stopLoss: n.stopLoss,
                            onCapitalChanged: (v) =>
                                ref.read(riskProvider).setCapital(v),
                            onLeverageChanged: (v) =>
                                ref.read(riskProvider).setLeverage(v),
                            onRiskChanged: (v) =>
                                ref.read(riskProvider).setRiskPercent(v),
                            onEntryChanged: (v) =>
                                ref.read(riskProvider).setEntryPrice(v),
                            onStopChanged: (v) =>
                                ref.read(riskProvider).setStopLoss(v),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (_, ref, __) {
                          final n = ref.watch(riskProvider);
                          return _ResultsCard(
                            positionSize: n.positionSize,
                            liquidationPrice: n.liquidationPrice,
                            liquidationDistance: n.liquidationDistance,
                            riskInDollars: n.riskInDollars,
                            riskLevel: n.riskLevel,
                            riskColor: n.riskColor,
                            leverage: n.leverage,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      // Warning + meter rebuild on leverage/risk changes
                      Consumer(
                        builder: (_, ref, __) {
                          final n = ref.watch(riskProvider);
                          return Column(
                            children: [
                              _AiRiskWarning(
                                leverage: n.leverage,
                                riskPercent: n.riskPercent,
                                riskColor: n.riskColor,
                                liquidationDistance: n.liquidationDistance,
                              ),
                              const SizedBox(height: 16),
                              _LeverageMeter(
                                leverage: n.leverage,
                                color: n.riskColor,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Tips are static — never need to rebuild
                      const _RiskTips(),
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
}

class _CalculatorCard extends StatelessWidget {
  final double capital, leverage, riskPercent, entryPrice, stopLoss;
  final ValueChanged<double> onCapitalChanged, onLeverageChanged, onRiskChanged,
      onEntryChanged, onStopChanged;

  const _CalculatorCard({
    required this.capital, required this.leverage, required this.riskPercent,
    required this.entryPrice, required this.stopLoss,
    required this.onCapitalChanged, required this.onLeverageChanged,
    required this.onRiskChanged, required this.onEntryChanged,
    required this.onStopChanged,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = leverage <= 3
        ? AppColors.brandGreen
        : leverage <= 7
            ? AppColors.brandAmber
            : AppColors.brandRed;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Position Calculator'),
          const SizedBox(height: 20),
          _SliderRow(
            'Account Capital',
            '\$${capital.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},',
            )}',
            capital, 1000, 100000, 1000, AppColors.brandGreen, onCapitalChanged,
          ),
          const SizedBox(height: 16),
          _SliderRow('Leverage', '${leverage.toInt()}x', leverage, 1, 20, 1,
            riskColor, onLeverageChanged),
          const SizedBox(height: 8),
          Row(
            children: [
              _LevTag('1x Safe', AppColors.brandGreen),
              const Spacer(),
              _LevTag('10x Risky', AppColors.brandAmber),
              const Spacer(),
              _LevTag('20x Danger', AppColors.brandRed),
            ],
          ),
          const SizedBox(height: 16),
          _SliderRow('Risk Per Trade', '${riskPercent.toStringAsFixed(1)}%',
            riskPercent, 0.5, 10, 0.5, AppColors.brandGreen, onRiskChanged),
        ],
      ),
    );
  }
}

class _LevTag extends StatelessWidget {
  final String label;
  final Color color;
  const _LevTag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 9, color: color.withAlpha(120)));
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final double current, min, max, divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderRow(this.label, this.value, this.current, this.min, this.max,
      this.divisions, this.color, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: color,
            fontFamily: 'JetBrainsMono',
          )),
        ]),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: color,
            inactiveTrackColor: AppColors.borderSubtle,
            thumbColor: color,
            overlayColor: color.withAlpha(20),
          ),
          child: Slider(
            value: current, min: min, max: max,
            divisions: ((max - min) / divisions).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final double positionSize, liquidationPrice, liquidationDistance, riskInDollars, leverage;
  final String riskLevel;
  final Color riskColor;

  const _ResultsCard({
    required this.positionSize, required this.liquidationPrice,
    required this.liquidationDistance, required this.riskInDollars,
    required this.riskLevel, required this.riskColor, required this.leverage,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              _Metric('Position Size', '\$${positionSize.toStringAsFixed(0)}',
                AppColors.brandGreen),
              _Metric('Liq. Price', '\$${liquidationPrice.toStringAsFixed(0)}',
                riskColor),
              _Metric('Max Loss', '\$${riskInDollars.toStringAsFixed(0)}',
                AppColors.brandRed),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: riskColor.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: riskColor.withAlpha(30)),
            ),
            child: Row(
              children: [
                const Text('Risk Level', style: TextStyle(
                  fontSize: 12, color: AppColors.textMuted,
                )),
                const Spacer(),
                Text(riskLevel, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: riskColor,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Metric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: color,
            fontFamily: 'JetBrainsMono',
          )),
        ],
      ),
    );
  }
}

class _AiRiskWarning extends StatelessWidget {
  final double leverage, riskPercent, liquidationDistance;
  final Color riskColor;

  const _AiRiskWarning({
    required this.leverage, required this.riskPercent,
    required this.riskColor, required this.liquidationDistance,
  });

  @override
  Widget build(BuildContext context) {
    final isHigh = leverage > 7;
    final color = isHigh ? AppColors.brandRed : AppColors.brandAmber;

    return GlassCard(
      borderColor: color.withAlpha(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isHigh ? Icons.warning_rounded : Icons.info_rounded,
              color: color, size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHigh ? 'AI Risk Warning' : 'AI Tip',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  isHigh
                      ? '${leverage.toInt()}x leverage is very high during current '
                        'volatility. A ${liquidationDistance.toStringAsFixed(1)}% adverse '
                        'move liquidates your position. Consider reducing to 3–5x.'
                      : 'Current leverage of ${leverage.toInt()}x is moderate. '
                        'Ensure your stop loss is set below key support at \$95,800.',
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeverageMeter extends StatelessWidget {
  final double leverage;
  final Color color;
  const _LeverageMeter({required this.leverage, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leverage Risk Meter', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.brandGreen, AppColors.brandAmber, AppColors.brandRed],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: (leverage / 20) * (MediaQuery.of(context).size.width * 0.3) - 4,
                child: Container(
                  width: 8, height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1x Safe', style: TextStyle(fontSize: 9, color: AppColors.brandGreen)),
              const Spacer(),
              Text('${leverage.toInt()}x', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color,
                fontFamily: 'JetBrainsMono',
              )),
              const Spacer(),
              const Text('20x Danger', style: TextStyle(fontSize: 9, color: AppColors.brandRed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskTips extends StatelessWidget {
  const _RiskTips();

  static const _tips = [
    'Never risk more than 1–2% of capital per trade',
    'Always set stop loss before entering a position',
    'Reduce leverage during high volatility periods',
    'Use position size calculator for every trade',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk Management Rules', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          const SizedBox(height: 12),
          ..._tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen, shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: Text(t, style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted, height: 1.4,
                ))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
