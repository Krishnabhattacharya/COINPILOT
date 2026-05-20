import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

class AiChatNotifier extends ChangeNotifier {
  final _messages = <ChatMessage>[
    const ChatMessage(
      text: 'Hello! I\'m your AI Trading Copilot. I have access to real-time market data, '
          'historical patterns, and current news. How can I help you trade smarter today?',
      isUser: false,
    ),
  ];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void send(String text) {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _isTyping = false;
      _messages.add(ChatMessage(text: _getResponse(text), isUser: false));
      notifyListeners();
    });
  }

  String _getResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('btc') || q.contains('bitcoin')) {
      return 'Based on current data: BTC is trading at \$97,420 (+2.4%). '
          'The RSI sits at 67 — bullish but not overbought. '
          'Key resistance at \$98,400–\$100,000. Support at \$95,800. '
          'Funding rates are neutral at +0.023%. '
          'My AI analysis suggests a 74% bullish sentiment across all sources. '
          'The market memory engine shows 87% similarity to October 2024 pre-ATH conditions.';
    }
    if (q.contains('funding')) {
      return 'Current funding rates: BTC +0.023%, ETH +0.018%, SOL -0.008%. '
          'BTC and ETH funding is mildly positive — longs are paying shorts. '
          'This is healthy and suggests organic buying, not overleveraged longs. '
          'SOL has slight negative funding, which could signal short-term bearish bias or upcoming short squeeze.';
    }
    return 'Great question! Based on current market conditions, I\'m analyzing the data. '
        'BTC is showing strong structure with neutral funding and positive ETF flows. '
        'The overall market sentiment is bullish at 72%. '
        'Would you like me to dive deeper into any specific aspect?';
  }
}

// Not autoDispose — chat history persists across navigation
final aiChatProvider = ChangeNotifierProvider(
  (ref) => AiChatNotifier(),
);
