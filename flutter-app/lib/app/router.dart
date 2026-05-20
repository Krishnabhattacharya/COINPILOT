import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/ai_analysis/ai_analysis_screen.dart';
import '../features/charts/charts_screen.dart';
import '../features/market_memory/market_memory_screen.dart';
import '../features/news_sentiment/news_sentiment_screen.dart';
import '../features/new_listings/new_listings_screen.dart';
import '../features/risk_management/risk_management_screen.dart';
import '../features/trade_journal/trade_journal_screen.dart';
import '../features/ai_chat/ai_chat_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/trade_now/trade_now_screen.dart';
import '../features/token_unlocks/token_unlocks_screen.dart';
import '../features/onchain/onchain_screen.dart';
import '../features/orderbook/orderbook_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import '../core/widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/trade-now', builder: (c, s) => const TradeNowScreen()),
        GoRoute(path: '/analysis', builder: (c, s) => const AiAnalysisScreen()),
        GoRoute(path: '/charts', builder: (c, s) => const ChartsScreen()),
        GoRoute(path: '/memory', builder: (c, s) => const MarketMemoryScreen()),
        GoRoute(path: '/sentiment', builder: (c, s) => const NewsSentimentScreen()),
        GoRoute(path: '/listings', builder: (c, s) => const NewListingsScreen()),
        GoRoute(path: '/orderbook', builder: (c, s) => const OrderbookScreen()),
        GoRoute(path: '/onchain', builder: (c, s) => const OnchainScreen()),
        GoRoute(path: '/token-unlocks', builder: (c, s) => const TokenUnlocksScreen()),
        GoRoute(path: '/portfolio', builder: (c, s) => const PortfolioScreen()),
        GoRoute(path: '/risk', builder: (c, s) => const RiskManagementScreen()),
        GoRoute(path: '/journal', builder: (c, s) => const TradeJournalScreen()),
        GoRoute(path: '/chat', builder: (c, s) => const AiChatScreen()),
        GoRoute(path: '/alerts', builder: (c, s) => const AlertsScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0A0B0F),
    body: Center(
      child: Text(
        'Page not found',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),
);