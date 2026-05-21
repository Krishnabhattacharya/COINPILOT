class AiAnalysis {
  final String type;
  final String model;
  final double? currentPriceUsd;
  final AnalysisData analysis;

  AiAnalysis({
    required this.type,
    required this.model,
    this.currentPriceUsd,
    required this.analysis,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      type: json['type']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      currentPriceUsd: (json['currentPriceUsd'] as num?)?.toDouble(),
      analysis: AnalysisData.fromJson(
          json['analysis'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AnalysisData {
  final String asset;
  final String trendDirection;
  final String summary;
  final double? currentPriceUsd;
  final KeyLevels keyLevels;
  final List<String> riskFactors;
  final int confidenceScore;
  final SentimentBreakdown sentimentBreakdown;
  final String volatilityAnalysis;
  final List<String> keyInsights;

  AnalysisData({
    required this.asset,
    required this.trendDirection,
    required this.summary,
    this.currentPriceUsd,
    required this.keyLevels,
    required this.riskFactors,
    required this.confidenceScore,
    required this.sentimentBreakdown,
    required this.volatilityAnalysis,
    required this.keyInsights,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      asset: json['asset']?.toString() ?? '',
      trendDirection: json['trendDirection']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      currentPriceUsd: (json['currentPriceUsd'] as num?)?.toDouble(),
      keyLevels:
          KeyLevels.fromJson(json['keyLevels'] as Map<String, dynamic>? ?? {}),
      riskFactors:
          (json['riskFactors'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 0,
      sentimentBreakdown: SentimentBreakdown.fromJson(
          json['sentimentBreakdown'] as Map<String, dynamic>? ?? {}),
      volatilityAnalysis: json['volatilityAnalysis']?.toString() ?? '',
      keyInsights:
          (json['keyInsights'] as List?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }
}

class KeyLevels {
  final List<Level> support;
  final List<Level> resistance;

  KeyLevels({required this.support, required this.resistance});

  factory KeyLevels.fromJson(Map<String, dynamic> json) {
    final sup = (json['support'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(Level.fromJson)
            .toList() ??
        [];
    final res = (json['resistance'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(Level.fromJson)
            .toList() ??
        [];
    return KeyLevels(support: sup, resistance: res);
  }
}

class Level {
  final String label;
  final double price;
  final String reason;

  Level({required this.label, required this.price, required this.reason});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      label: json['label']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class SentimentBreakdown {
  final int bullish;
  final int neutral;
  final int bearish;

  SentimentBreakdown(
      {required this.bullish, required this.neutral, required this.bearish});

  factory SentimentBreakdown.fromJson(Map<String, dynamic> json) {
    return SentimentBreakdown(
      bullish: (json['bullish'] as num?)?.toInt() ?? 0,
      neutral: (json['neutral'] as num?)?.toInt() ?? 0,
      bearish: (json['bearish'] as num?)?.toInt() ?? 0,
    );
  }
}
