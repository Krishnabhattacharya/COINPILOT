# CoinPilot — Software Specification Document

**Version:** 1.0.0
**Date:** 2026-05-19
**Product:** AI Trading Copilot (aitradingcopilot.com)
**Status:** Frontend 100% complete | Backend 0% complete

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [System Architecture](#2-system-architecture)
3. [Next.js Application — Marketing & Auth Layer](#3-nextjs-application--marketing--auth-layer)
4. [Flutter Web Application — Dashboard](#4-flutter-web-application--dashboard)
5. [Backend API Specification](#5-backend-api-specification)
6. [AI & RAG Infrastructure](#6-ai--rag-infrastructure)
7. [Database Design](#7-database-design)
8. [Real-Time Infrastructure](#8-real-time-infrastructure)
9. [Third-Party Integrations](#9-third-party-integrations)
10. [Authentication & Security](#10-authentication--security)
11. [Subscription & Billing](#11-subscription--billing)
12. [Background Jobs](#12-background-jobs)
13. [Deployment & DevOps](#13-deployment--devops)
14. [Design System](#14-design-system)
15. [Environment Variables](#15-environment-variables)
16. [Development Roadmap](#16-development-roadmap)
17. [Project Metrics](#17-project-metrics)

---

## 1. PROJECT OVERVIEW

### 1.1 Product Description

CoinPilot is an AI-powered crypto trading intelligence platform. It gives traders real-time market analysis, RAG-powered historical pattern matching (Market Memory), sentiment aggregation across social and on-chain sources, risk management tools, a psychology-aware trade journal, and a conversational AI assistant — all inside a unified dashboard.

### 1.2 Core Value Propositions

| Feature | Description |
|---------|-------------|
| **Market Memory Engine** | RAG pipeline that matches current market structure to historical patterns and shows what happened next |
| **AI Market Analysis** | Claude/GPT-4 powered per-coin analysis with trend, support/resistance, confidence scores |
| **Sentiment Intelligence** | Aggregated bullish/bearish score from News, Twitter, Reddit, and whale on-chain data |
| **New Listings Intel** | AI-scored new coin listings with momentum, potential, and risk scores |
| **Risk Management** | Interactive position sizing calculator with AI warnings |
| **Trade Journal** | Psychology-aware trade logging with AI pattern detection (FOMO, revenge trading) |
| **AI Chat Assistant** | Conversational interface with portfolio-aware context injection |
| **Smart Alerts** | Configurable alerts for price targets, whale moves, funding spikes, sentiment shifts |

### 1.3 Target Users

- **Retail Crypto Traders** — active traders who want data-driven edge
- **DeFi Participants** — users tracking new listings and on-chain activity
- **Institutional Desks** (Institutional tier) — teams needing API access + white-label

### 1.4 Subscription Tiers

| Tier | Price | Key Limits |
|------|-------|------------|
| **Starter** | Free | 3 AI summaries/day, 2 watchlist coins |
| **Pro** | $49/mo ($39/mo annual) | Unlimited analysis, full feature access |
| **Institutional** | $199/mo ($159/mo annual) | 5 seats, API access, white-label, SLA |

---

## 2. SYSTEM ARCHITECTURE

### 2.1 High-Level Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                           │
├──────────────────────────┬────────────────────────────────────┤
│   Next.js 14 (Port 3000) │   Flutter Web (Port 5001)          │
│   Landing + Blog + Auth  │   Authenticated Dashboard          │
└──────────────────────────┴────────────────────────────────────┘
                           │
                  Nginx / Dev Proxy
                           │
          ┌────────────────┴────────────────┐
          │                                 │
          ▼                                 ▼
   REST API Server                  WebSocket Server
   (Node.js / FastAPI)              (Socket.io / WS)
          │                                 │
          │                        Redis Pub/Sub
          │
   ┌──────┴──────────────────────────────────────────┐
   │                                                  │
   ▼                  ▼                  ▼            ▼
PostgreSQL          Redis           pgvector     TimescaleDB
(users, trades,   (sessions,       (RAG vector   (optional,
 alerts, journal)  cache, queues)   embeddings)   OHLCV store)
```

### 2.2 URL Routing Architecture

**Development:**
```
http://localhost:8080  (dev-proxy.js)
├── /dashboard, /analysis, /charts, /memory, /sentiment,
│   /listings, /risk, /journal, /chat, /alerts, /profile
│                          └──► Flutter :5001
└── /, /auth/*, /blog, /pricing
                           └──► Next.js :3000
```

**Production:**
```
https://aitradingcopilot.com  (Nginx reverse proxy)
├── /app/*, /dashboard/*, /analysis/*, /charts/*,
│   /chat/*, /memory/*, /sentiment/*, /listings/*,
│   /risk/*, /journal/*, /alerts/*, /profile/*
│                          └──► Flutter Web (Vercel)
└── /, /auth/*, /blog, /pricing, /sitemap.xml, /robots.txt
                           └──► Next.js (Vercel)

https://api.aitradingcopilot.com  (Backend API — to be built)
wss://api.aitradingcopilot.com    (WebSocket — to be built)
```

### 2.3 Technology Stack Summary

| Layer | Technology |
|-------|------------|
| Marketing / Auth Frontend | Next.js 14.2.5, React 18.3.1, TypeScript, Tailwind CSS |
| Dashboard Frontend | Flutter 3.3+, Dart, Riverpod, GoRouter |
| Backend API | Node.js + Fastify **or** Python + FastAPI (TBD) |
| Primary Database | PostgreSQL 16 + pgvector extension |
| Cache / Sessions | Redis 7 (Upstash managed recommended) |
| Vector Store | pgvector (co-located) **or** Pinecone (managed) |
| Background Jobs | BullMQ (Redis-backed) |
| LLM | Anthropic Claude Sonnet 4.6 (primary), GPT-4o (fallback) |
| Embeddings | OpenAI text-embedding-3-large |
| Hosting | Vercel (frontend), Railway / Render / Fly.io (backend) |
| CI/CD | GitHub Actions |
| Reverse Proxy | Nginx |

---

## 3. NEXT.JS APPLICATION — MARKETING & AUTH LAYER

### 3.1 Technology Stack

```
Next.js         14.2.5
React           18.3.1
TypeScript      5.5.3
Tailwind CSS    3.4.6
Framer Motion   11.3.8
Recharts        2.12.7
Radix UI        (Accordion, Dialog, Tabs, Tooltip)
Lucide React    0.400.0
Next Themes     0.3.0
React Type Animation  3.2.0
React CountUp   6.5.3
React Intersection Observer  9.13.0
Sharp           0.33.4  (image optimization)
```

### 3.2 Directory Structure

```
nextjs-app/
├── app/
│   ├── layout.tsx                  Root layout — fonts, metadata, providers
│   ├── page.tsx                    Landing page (assembles all landing components)
│   ├── not-found.tsx               Custom 404 page
│   ├── robots.ts                   SEO robots.txt generation
│   ├── sitemap.ts                  SEO sitemap generation
│   ├── blog/
│   │   └── page.tsx                Blog listing (6 articles, featured + grid)
│   └── auth/
│       ├── login/page.tsx          Email/password + Google OAuth login
│       ├── signup/page.tsx         Account creation with live password validation
│       ├── verify-otp/page.tsx     6-digit OTP verification screen
│       └── forgot-password/page.tsx  Email reset → confirmation state machine
├── components/
│   ├── auth/
│   │   ├── AuthLayout.tsx          Auth page wrapper (logo, branding, card)
│   │   ├── LoginForm.tsx           Login form component
│   │   ├── SignupForm.tsx          Signup form with validation indicators
│   │   └── ForgotPasswordForm.tsx  Forgot password with 3-state flow
│   └── landing/
│       ├── Navbar.tsx              Fixed header, mobile menu, CTAs
│       ├── Hero.tsx                Headline, ticker tape, AI analysis card
│       ├── Features.tsx            9 feature cards (3×3 grid)
│       ├── PatternEngine.tsx       Market Memory RAG demo section
│       ├── SentimentDemo.tsx       Sentiment meter + source breakdown
│       ├── RiskDemo.tsx            Interactive risk calculator demo
│       ├── Testimonials.tsx        6 user testimonials
│       ├── Pricing.tsx             3 pricing tiers with monthly/annual toggle
│       ├── FAQ.tsx                 Expandable accordion FAQ
│       ├── BlogPreview.tsx         Featured + grid blog post preview
│       ├── CTASection.tsx          Final conversion section
│       └── Footer.tsx              Links, legal, copyright
├── next.config.mjs
├── tailwind.config.ts
├── tsconfig.json
├── postcss.config.mjs
├── package.json
└── .env.example
```

### 3.3 Pages & Routes

| Route | Purpose | Auth Required | SEO Indexed |
|-------|---------|--------------|-------------|
| `/` | Full landing page | No | Yes |
| `/blog` | Blog listing (6 articles) | No | Yes |
| `/auth/login` | Login | No | No |
| `/auth/signup` | Registration | No | No |
| `/auth/verify-otp` | OTP verification | No | No |
| `/auth/forgot-password` | Password reset | No | No |
| `/404` | Custom error page | No | No |
| `/dashboard/*` | Rewritten → Flutter | Yes | No |
| `/app/*` | Rewritten → Flutter | Yes | No |
| `/analysis/*` | Rewritten → Flutter | Yes | No |
| `/charts/*` | Rewritten → Flutter | Yes | No |
| `/chat/*` | Rewritten → Flutter | Yes | No |

### 3.4 Next.js Configuration (next.config.mjs)

```
output:                "standalone"
optimizePackageImports: ["lucide-react", "framer-motion"]
remotePatterns:        assets.coingecko.com, cryptologos.cc, coin-images.coingecko.com
rewrites:              5 rules routing /dashboard, /app, /analysis, /charts, /chat → Flutter
headers:               X-Frame-Options: DENY
                       X-Content-Type-Options: nosniff
                       Referrer-Policy: strict-origin-when-cross-origin
```

### 3.5 Landing Page Components — Detail

#### Navbar
- Fixed/sticky header with scroll-based styling change
- Logo with gradient icon + "CoinPilot" text
- Desktop nav links: Features, Market Memory, Pricing, Blog
- Desktop CTAs: "Log in" (ghost), "Dashboard" (outline), "Start Free" (green filled)
- Mobile: hamburger → full-screen mobile menu
- Breakpoint: `md` (768px)

#### Hero
- Animated ticker tape: 8 crypto symbols scrolling horizontally (30s loop)
- Main headline with gradient text effect
- Subheading value proposition
- 3 CTAs: "Start Free Trial", "Open Dashboard", "Watch Demo"
- Live AI Market Summary card with typewriter animation
- Two-card grid:
  - Left (2/3 width): AI analysis card (sentiment score, confidence bar, trend direction)
  - Right (1/3 width): BTC price card + Fear & Greed gauge

#### Features (9 Cards)
| # | Feature | Color | Icon |
|---|---------|-------|------|
| 1 | AI Market Analysis | Green | Brain/chart |
| 2 | Market Memory Engine | Purple | Database |
| 3 | New Listings Intel | Cyan | Sparkles |
| 4 | Risk Management | Amber | Shield |
| 5 | Sentiment Intelligence | Blue | Activity |
| 6 | AI Trade Journal | Pink | BookOpen |
| 7 | Advanced Charts | Green | CandlestickChart |
| 8 | Smart Alert Center | Orange | Bell |
| 9 | AI Chat Assistant | Purple | MessageSquare |

#### PatternEngine (Market Memory Demo)
- Left column: headline, 4 benefit bullets, "Explore Patterns" CTA
- Right column:
  - Current market state card (live parameters)
  - 3 historical pattern match cards, each showing:
    - Date range of historical period
    - Similarity percentage + progress bar
    - Outcome (% move that followed)
    - Key contributing factors (badge chips)

#### SentimentDemo
- Overall bullish score gauge (0–100)
- Source breakdown table: Twitter %, Reddit %, Whale Activity %
- News feed: 4 items with Bullish / Bearish / Neutral badges

#### RiskDemo (Interactive)
- Sliders: Account Capital ($1K–$100K), Leverage (1x–20x), Risk Per Trade (0.5%–10%)
- Outputs update live: Position Size, Liquidation Distance %
- Leverage color coding: green ≤3x, amber 4–7x, red ≥8x
- AI warning box displayed when leverage ≥ 8x
- Risk label: Conservative / Moderate / High Risk

#### Pricing (3 Tiers)
- Monthly / Annual toggle (annual = ~20% discount)
- **Starter** (Free): 3 AI summaries/day, basic sentiment, F&G, 2 coins, Discord
- **Pro** ($49/$39): Everything unlimited, all features, real-time WS, priority support
- **Institutional** ($199/$159): Everything + 5 seats, API access, white-label, SLA

---

## 4. FLUTTER WEB APPLICATION — DASHBOARD

### 4.1 Technology Stack

```
Flutter SDK       >=3.3.0 <4.0.0
Dart              3.3+
go_router         ^14.2.0    Navigation
flutter_riverpod  ^2.5.1     State management
riverpod_annotation ^2.3.5   Code generation
google_fonts      ^6.2.1     Typography
flutter_animate   ^4.5.0     Animations
dio               ^5.4.3     HTTP client
retrofit          ^4.1.0     REST API generator
web_socket_channel ^3.0.1    WebSocket
hive_flutter      ^1.1.0     Local database
flutter_secure_storage ^9.2.2  JWT storage
shared_preferences ^2.3.0   Preferences
fl_chart          ^0.68.0    Charts
percent_indicator ^4.2.3     Gauges/progress
shimmer           ^3.0.0     Skeleton loaders
lottie            ^3.1.2     Lottie animations
cached_network_image ^3.3.1  Image caching
freezed_annotation ^2.4.4   Immutable models
json_annotation   ^4.9.0    JSON serialization
```

### 4.2 Directory Structure

```
flutter-app/
├── lib/
│   ├── main.dart                           App entry point
│   ├── app/
│   │   ├── app.dart                        Root MaterialApp + ThemeData
│   │   └── router.dart                     GoRouter — 11 routes in ShellRoute
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart             All color constants (AppColors class)
│   │   │   └── app_theme.dart              Full ThemeData, TextThemes, InputDecoration
│   │   └── widgets/
│   │       ├── app_shell.dart              Responsive layout (sidebar + topbar + content)
│   │       ├── sidebar.dart                Desktop navigation sidebar (220px)
│   │       ├── top_bar.dart                Top header (60px) with live indicator + ticker
│   │       └── glass_card.dart             Reusable glass-morphism card widget
│   └── features/
│       ├── dashboard/
│       │   ├── dashboard_screen.dart
│       │   └── widgets/
│       │       ├── market_overview_card.dart
│       │       ├── ai_summary_card.dart
│       │       ├── fear_greed_widget.dart
│       │       ├── funding_rate_panel.dart
│       │       ├── portfolio_overview.dart
│       │       ├── trending_coins.dart
│       │       └── whale_alerts.dart
│       ├── ai_analysis/
│       │   └── ai_analysis_screen.dart
│       ├── charts/
│       │   └── charts_screen.dart
│       ├── market_memory/
│       │   └── market_memory_screen.dart
│       ├── news_sentiment/
│       │   └── news_sentiment_screen.dart
│       ├── new_listings/
│       │   └── new_listings_screen.dart
│       ├── risk_management/
│       │   └── risk_management_screen.dart
│       ├── trade_journal/
│       │   └── trade_journal_screen.dart
│       ├── ai_chat/
│       │   └── ai_chat_screen.dart
│       ├── alerts/
│       │   └── alerts_screen.dart
│       └── profile/
│           └── profile_screen.dart
├── assets/
│   ├── fonts/       Inter + JetBrains Mono (8 weights total)
│   ├── images/
│   └── animations/  Lottie JSON files
├── pubspec.yaml
└── analysis_options.yaml
```

### 4.3 Navigation Architecture

**GoRouter — ShellRoute wraps all 11 routes:**

```dart
ShellRoute(
  builder: (ctx, state, child) => AppShell(child: child),
  routes: [
    /dashboard   → DashboardScreen
    /analysis    → AiAnalysisScreen
    /charts      → ChartsScreen
    /memory      → MarketMemoryScreen
    /sentiment   → NewsSentimentScreen
    /listings    → NewListingsScreen
    /risk        → RiskManagementScreen
    /journal     → TradeJournalScreen
    /chat        → AiChatScreen
    /alerts      → AlertsScreen
    /profile     → ProfileScreen
  ]
)
```

**AppShell Responsive Breakpoints:**

| Screen Width | Layout |
|-------------|--------|
| ≥ 1024px (Desktop) | Sidebar (220px) + TopBar (60px) + Scrollable Content |
| 768–1023px (Tablet) | TopBar + Content + BottomNavigationBar (5 tabs) |
| < 768px (Mobile) | TopBar + Content + BottomNavigationBar (5 tabs) |

### 4.4 Sidebar Navigation Groups

```
OVERVIEW
  └── Dashboard

AI INTELLIGENCE
  ├── AI Analysis
  ├── Market Memory
  └── AI Chat

MARKET
  ├── Charts
  ├── Sentiment
  └── New Listings  [badge: HOT]

TRADING
  ├── Risk Manager
  ├── Trade Journal
  └── Alerts        [badge: 3 (unread)]

ACCOUNT
  └── Profile
```

### 4.5 Screen-by-Screen Specification

---

#### Screen 1: Dashboard (`/dashboard`)

**Purpose:** Home screen — overview of market, portfolio, AI insights.

**Widgets:**
| Widget | Data Source | Update Frequency |
|--------|------------|-----------------|
| MarketOverviewCard (×4) | BTC, ETH, SOL, BNB prices + 24h change | WebSocket (real-time) |
| AiSummaryCard | LLM-generated insight | 15 min |
| FearGreedWidget | Alternative.me | 1 h |
| FundingRatePanel | Binance perpetuals | 30 s |
| PortfolioOverview | User's holdings + live prices | 60 s |
| TrendingCoins | CoinGecko trending endpoint | 5 min |
| WhaleAlerts | Whale Alert API | Real-time push |

---

#### Screen 2: AI Analysis (`/analysis`)

**Purpose:** Deep AI analysis for a selected coin.

**UI Sections:**
- Coin selector dropdown (default: BTC, options: ETH, SOL, BNB, custom input)
- MarketSummaryCard — LLM narrative: trend, momentum, key events, confidence %
- SupportResistanceCard — S1, S2, R1, R2, Pivot (calculated from OHLCV)
- SentimentCard — bullish % breakdown by source
- VolatilityCard — ATR (14), Bollinger Band width
- KeyLevelsCard — formatted table of price levels
- AiChatPanel — sidebar allowing follow-up questions in context of selected coin

**Caching:** 15 min per (coinId, analysis)

---

#### Screen 3: Charts (`/charts`)

**Purpose:** Advanced charting interface.

**Features:**
- Timeframe selector: `1m | 5m | 15m | 1H | 4H | 1D | 1W`
- Coin selector
- Indicator toggles: RSI, MACD, EMA (9, 21, 50), Volume, Bollinger Bands
- Drawing tools toolbar (placeholder for Phase 2)
- Candlestick chart rendered via `fl_chart` or custom Canvas painter
- Indicator panel below chart showing numeric values

**Data:** CoinGecko OHLCV endpoint, cached 5 min per (coin, interval)

---

#### Screen 4: Market Memory (`/memory`)

**Purpose:** RAG-powered historical pattern matching.

**UI:**
- **Current State Card:** Shows live market parameters
  - BTC price + structure
  - RSI (14d)
  - Funding rate (BTC perpetual)
  - Sentiment score
  - BTC dominance
- **Pattern Match Cards (×4):** Ordered by similarity score
  - Historical date range
  - Similarity % (progress bar + numeric)
  - Outcome: +X% or −X% over N days after
  - Key contributing factors (badge chips): RSI overbought, whale accumulation, etc.
  - Short narrative description

**Backend:** Vector similarity search via pgvector / Pinecone (cosine distance)

---

#### Screen 5: News & Sentiment (`/sentiment`)

**Purpose:** Aggregated sentiment from all sources.

**Tabs:**
1. **News** — Crypto news with AI sentiment badges (Bullish / Bearish / Neutral)
2. **Twitter** — Tweet volume + aggregate sentiment score per coin
3. **Reddit** — Subreddit analysis (r/bitcoin, r/ethereum, r/cryptocurrency)
4. **Whale Activity** — On-chain large transactions (>$5M)

**Top Section (all tabs):**
- Overall Sentiment Meter: 0–100 gauge
  - 0–20: Extreme Fear
  - 20–40: Fear
  - 40–60: Neutral
  - 60–80: Greed
  - 80–100: Extreme Greed
- Source contribution breakdown (Twitter %, Reddit %, News %, On-chain %)

---

#### Screen 6: New Listings (`/listings`)

**Purpose:** Early detection of new coin listings with AI scoring.

**Filter Tabs:** All | AI | Meme | DeFi | Gaming | RWA

**Per Listing Card:**
- Symbol + name + emoji icon
- Current price + 24h change (green/red)
- Exchange name + listing timestamp
- **Scores:**
  - Momentum (0–100) — price action velocity
  - Potential (0–100) — narrative + social strength
  - Risk (Low / Medium / High)
- Volume surge multiplier (e.g., "48x baseline")
- Tags: 🐳 Whale Accumulation, 🧠 Smart Money
- AI reason (1–2 sentence explanation)

---

#### Screen 7: Risk Management (`/risk`)

**Purpose:** Interactive position sizing and risk calculator.

**Inputs (Sliders + Fields):**
| Input | Range | Default |
|-------|-------|---------|
| Account Capital | $1,000 – $100,000 | $10,000 |
| Leverage | 1x – 20x | 1x |
| Risk Per Trade | 0.5% – 10% | 1% |
| Entry Price | Manual input | — |
| Stop-Loss Price | Manual input | — |

**Outputs (Computed Live):**
| Output | Formula |
|--------|---------|
| Position Size | (Capital × Risk%) / (Entry − StopLoss) |
| Liquidation Price | Entry × (1 − 1/Leverage) |
| Liquidation Distance | (Entry − Liq) / Entry × 100 |
| Max Loss in USD | Capital × Risk% |
| Risk Level | Conservative ≤2%, Moderate ≤5%, High >5% |

**AI Warnings:** Displayed when leverage ≥ 8x
**Leverage Color Coding:** ≤3x green, 4–7x amber, ≥8x red

---

#### Screen 8: Trade Journal (`/journal`)

**Purpose:** Log trades with psychology tagging and AI pattern detection.

**Tabs:**
1. **Trades** — Trade log list + FAB to add new trade
   - Fields: Pair, Direction (Long/Short), Entry Price, Exit Price, Size, Date, Notes
   - Tags: Psychology (FOMO / Patient / Revenge / Disciplined), Strategy, Outcome (Win/Loss/Breakeven)
   - Computed: P&L ($), P&L (%)

2. **Analytics** — Stats dashboard
   - Win Rate (%)
   - Profit Factor (gross profit / gross loss)
   - Average R:R ratio
   - Total P&L ($)
   - Trade count, streak

3. **Psychology** — AI-generated insights
   - Revenge trading pattern detection
   - FOMO frequency tracking
   - Emotional pattern over time (chart)
   - AI recommendations

---

#### Screen 9: AI Chat (`/chat`)

**Purpose:** Conversational AI assistant with trading context.

**Features:**
- Full-height chat interface
- User + AI message bubbles
- Typing indicator (animated dots)
- Streaming response via SSE or WebSocket
- 6 suggested quick-questions:
  - "What's the current BTC trend?"
  - "Should I hold my ETH position?"
  - "What are the top movers today?"
  - "Explain the current market structure"
  - "Any whale activity I should know?"
  - "What's your risk assessment for SOL?"
- Context injected into every message: current prices, Fear/Greed, user portfolio

**Persistence:** All messages stored in `chat_messages` DB table

---

#### Screen 10: Alerts (`/alerts`)

**Purpose:** Manage and view real-time trading alerts.

**Alert Types (Toggle on/off):**
| Alert Type | Trigger Condition |
|------------|------------------|
| Funding Rate Spikes | Funding rate > 0.05% |
| Whale Alerts | On-chain transaction > $5M |
| Volatility Burst | Price change > 50% within 1 hour |
| Sentiment Change | Sentiment score shifts > 10 points |
| New Listings | New coin listed within 4 hours |
| Price Targets | User-configured price threshold reached |

**Recent Alerts List:** Timestamp, coin, alert type, description, severity badge

---

#### Screen 11: Profile (`/profile`)

**Purpose:** User account and preferences management.

**Sections:**
- **ProfileCard:** Avatar (initials + color), name, email, subscription tier badge
- **SubscriptionCard:** Current plan + usage stats + upgrade CTA
- **Exchange Connections:** Linked Binance / Bybit API keys (display only, edit/delete)
- **Preferences:** Dark mode toggle, notification toggles (price alerts, whale, news)
- **Security:** 2FA toggle, active sessions, change password
- **AI Personality:** Selector — Direct | Friendly | Professional (affects LLM system prompt tone)

---

## 5. BACKEND API SPECIFICATION

> None of these endpoints exist yet. This section defines the full contract to be implemented.

**Base URL:** `https://api.aitradingcopilot.com`
**Authentication:** JWT Bearer token (header: `Authorization: Bearer <token>`)
**Format:** JSON request/response
**Rate Limiting:** Per-user + per-IP (see §10.3)

---

### 5.1 Auth Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/api/auth/register` | None | Register with email + password |
| POST | `/api/auth/login` | None | Login → returns `accessToken` + `refreshToken` (httpOnly cookie) |
| POST | `/api/auth/logout` | JWT | Invalidate refresh token |
| POST | `/api/auth/refresh` | Cookie | Exchange refresh token for new access token |
| POST | `/api/auth/forgot-password` | None | Send 6-digit OTP to email |
| POST | `/api/auth/verify-otp` | None | Verify OTP code (purpose: forgot_password or email_verify) |
| POST | `/api/auth/reset-password` | None | Set new password after OTP verified |
| GET  | `/api/auth/google` | None | Redirect to Google OAuth consent screen |
| GET  | `/api/auth/google/callback` | None | Handle Google OAuth callback |
| GET  | `/api/auth/me` | JWT | Return current user object |

**Request/Response examples:**

```
POST /api/auth/register
Body: { "name": "...", "email": "...", "password": "..." }
Response 201: { "user": {...}, "accessToken": "..." }

POST /api/auth/login
Body: { "email": "...", "password": "..." }
Response 200: { "user": {...}, "accessToken": "..." }
Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict
```

---

### 5.2 User & Profile Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET  | `/api/user/profile` | JWT | Full profile (avatar, name, plan, created_at) |
| PATCH | `/api/user/profile` | JWT | Update name, avatar_url, timezone, currency |
| GET  | `/api/user/preferences` | JWT | Notification + display preferences |
| PATCH | `/api/user/preferences` | JWT | Update preferences |
| DELETE | `/api/user/account` | JWT | GDPR-compliant account deletion |

---

### 5.3 Market Data Endpoints

> All data proxied from CoinGecko / Binance. Responses cached in Redis.

| Method | Route | Cache TTL | Description |
|--------|-------|-----------|-------------|
| GET | `/api/market/coins` | 60s | Paginated coin list (price, 24h %, mcap, volume). Query: `page`, `limit`, `order` |
| GET | `/api/market/coins/:coinId` | 30s | Single coin detail (all metadata + current price) |
| GET | `/api/market/coins/:coinId/ohlcv` | 5m | OHLCV candles. Query: `interval` (1m/5m/1h/1d), `from`, `to` |
| GET | `/api/market/coins/:coinId/orderbook` | 10s | Current orderbook depth |
| GET | `/api/market/fear-greed` | 1h | Fear & Greed Index (Alternative.me) |
| GET | `/api/market/global` | 60s | Global market cap, dominance, volume |
| GET | `/api/market/trending` | 5m | Trending coins (24h) |
| GET | `/api/market/funding-rates` | 30s | Perpetual funding rates (Binance) |
| GET | `/api/market/new-listings` | 15m | New coin listings with AI momentum scores |
| GET | `/api/market/whale-alerts` | Real-time | Recent large on-chain transactions |
| GET | `/api/dashboard/summary` | 60s | Combined: top prices + F&G + trending + whale alerts + AI summary |

---

### 5.4 Portfolio Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET | `/api/portfolio` | JWT | Portfolio summary: holdings, total value, P&L, allocation |
| POST | `/api/portfolio/holdings` | JWT | Add holding: `{ coinId, coinSymbol, amount, avgBuyPriceUsd }` |
| PATCH | `/api/portfolio/holdings/:id` | JWT | Update amount or avg buy price |
| DELETE | `/api/portfolio/holdings/:id` | JWT | Remove holding |
| GET | `/api/portfolio/performance` | JWT | Historical portfolio value over time (chart data) |

---

### 5.5 Trade Journal Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET | `/api/journal` | JWT | Paginated trade list. Query: `page`, `limit`, `outcome`, `dateFrom`, `dateTo` |
| POST | `/api/journal` | JWT | Log new trade (see schema below) |
| GET | `/api/journal/:id` | JWT | Single trade detail |
| PATCH | `/api/journal/:id` | JWT | Update trade entry |
| DELETE | `/api/journal/:id` | JWT | Delete trade entry |
| GET | `/api/journal/stats` | JWT | Aggregated stats: win rate, profit factor, avg R:R, psychology patterns |

**POST /api/journal body:**
```json
{
  "pair": "BTC/USDT",
  "direction": "long",
  "entryPrice": 95000,
  "exitPrice": 97500,
  "size": 0.1,
  "entryAt": "2026-05-01T10:00:00Z",
  "exitAt": "2026-05-03T14:30:00Z",
  "notes": "Clean breakout play",
  "psychology": "patient",
  "strategy": "breakout",
  "outcome": "win"
}
```

---

### 5.6 Risk Management Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/api/risk/position-size` | JWT | Calculate: `{ accountSize, riskPercent, entryPrice, stopLossPrice, leverage }` |
| POST | `/api/risk/rr-calculator` | JWT | Risk:Reward: `{ entryPrice, stopLoss, takeProfit }` |
| GET | `/api/risk/max-drawdown/:coinId` | JWT | Historical max drawdown for a coin |

---

### 5.7 Alerts Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET | `/api/alerts` | JWT | All user alerts (active + inactive) |
| POST | `/api/alerts` | JWT | Create alert: `{ coinId, condition, targetValue, alertType }` |
| PATCH | `/api/alerts/:id` | JWT | Update alert (toggle active, change target) |
| DELETE | `/api/alerts/:id` | JWT | Delete alert |
| GET | `/api/alerts/history` | JWT | Paginated history of fired alerts |

---

### 5.8 News & Sentiment Endpoints

| Method | Route | Cache TTL | Description |
|--------|-------|-----------|-------------|
| GET | `/api/sentiment/news` | 10m | Latest crypto news with AI sentiment score (bullish/bearish/neutral) |
| GET | `/api/sentiment/social` | 15m | Twitter + Reddit aggregate sentiment for top 10 coins |
| GET | `/api/sentiment/coins/:coinId` | 15m | All sentiment signals for a specific coin |
| GET | `/api/sentiment/on-chain` | 10m | On-chain indicators: NVT, SOPR, exchange netflow |

---

### 5.9 Subscription / Billing Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| GET | `/api/billing/plans` | None | List all plans and pricing |
| POST | `/api/billing/checkout` | JWT | Create Stripe Checkout session |
| POST | `/api/billing/portal` | JWT | Customer portal URL for managing subscription |
| POST | `/api/billing/webhook` | Stripe sig | Stripe webhook (subscription events) |
| GET | `/api/billing/subscription` | JWT | Current subscription status |

---

## 6. AI & RAG INFRASTRUCTURE

### 6.1 AI Chat — Streaming Completions

**Endpoint:** `POST /api/ai/chat`
**Protocol:** Server-Sent Events (SSE) for streaming

**System Prompt Template (injected per request):**
```
You are CoinPilot, an expert crypto trading AI assistant.

CURRENT MARKET DATA (updated 60s ago):
- BTC: ${{btcPrice}} ({{btcChange24h}}% 24h)
- ETH: ${{ethPrice}} ({{ethChange24h}}% 24h)
- Fear & Greed Index: {{fearGreed}}/100 ({{fearGreedLabel}})
- Overall Market Sentiment: {{sentimentScore}}/100

USER PORTFOLIO:
{{portfolioSummary}}

AI Personality: {{personality}}  // direct | friendly | professional
Respond concisely. Use markdown. Do not give financial advice.
```

**Models:**
- Primary: `claude-sonnet-4-6` (Anthropic)
- Fallback: `gpt-4o` (OpenAI)

**Storage:** Every turn stored in `chat_messages` (PostgreSQL)
**Rate Limit:** Free tier — 3/day, Pro — unlimited, Institutional — unlimited + priority

---

### 6.2 AI Market Analysis

**Endpoint:** `GET /api/ai/analysis/:coinId`
**Cache:** 15 min (Redis)

**Pipeline:**
```
1. Fetch coin OHLCV (30d), current price, volume, market cap (CoinGecko)
2. Compute: RSI(14), MACD, Bollinger Bands, EMA(9,21,50), support/resistance
3. Fetch sentiment score for coin (LunarCrush + CryptoPanic)
4. Build structured prompt with all data
5. Call Claude Sonnet → structured JSON response:
   {
     "summary": "...",
     "trendDirection": "bullish|bearish|neutral",
     "confidenceScore": 72,
     "supportLevels": [94200, 91500],
     "resistanceLevels": [98000, 102000],
     "keyRisks": ["..."],
     "outlook": "short|medium|long"
   }
6. Cache result in Redis for 15 min
7. Return to client
```

---

### 6.3 Market Memory Engine — Full RAG Pipeline

This is the platform's flagship differentiator.

#### Ingestion Phase (Nightly Background Job)

```
For each coin in top-100 list:
  For each window size in [30, 60, 90] days:
    For each historical window (sliding, 7-day step):
      1. Fetch OHLCV data for the window
      2. Compute feature vector:
         {
           price_change_pct: float,
           volume_change_pct: float,
           rsi_start: float,
           rsi_end: float,
           macd_signal: "bullish_cross"|"bearish_cross"|"neutral",
           bollinger_width_pct: float,
           funding_rate_avg: float,
           fear_greed_avg: float,
           btc_dominance_avg: float,
           sentiment_score_avg: float
         }
      3. Convert feature vector to natural language description string
      4. Call OpenAI text-embedding-3-large → 1536-dim vector
      5. Compute outcome_data:
         {
           price_30d_after: float,
           pct_change_30d: float,
           price_60d_after: float,
           pct_change_60d: float
         }
      6. Upsert into pgvector market_patterns table
```

#### Query Phase (On User Request)

```
1. Compute current market feature vector (same schema as ingestion)
2. Convert to natural language description
3. Embed via OpenAI text-embedding-3-large
4. Run pgvector cosine similarity search → top 5 matches
5. For each match, retrieve: date range, features, outcome_data
6. Build prompt with matches + outcomes → Claude generates narrative
7. Return: [ { date, similarity%, outcome, keyFactors, explanation } × 4 ]
```

**Vector Index:**
```sql
CREATE INDEX ON market_patterns
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

---

### 6.4 Sentiment AI Scoring

**Endpoint:** `POST /api/ai/sentiment/score` (internal, called by background job)

**Pipeline:**
```
For each news article / tweet batch:
  1. Call Claude Haiku (cheap) with:
     "Classify the sentiment of this crypto news as: bullish, bearish, or neutral.
      Confidence 0-100. Coin mentioned (if any). Return JSON."
  2. Store result in Redis (key: sentiment:{hash(text)}, TTL: 24h)
  3. Aggregate per coin: compute weighted average sentiment score
```

---

### 6.5 New Listings AI Scoring

**Endpoint:** `GET /api/ai/listings/score/:coinId`
**Trigger:** Nightly job + on-demand

**Input signals to LLM:**
- Social volume (LunarCrush)
- Whitepaper summary (scraped/fetched)
- Tokenomics (circulating supply, total supply, vesting)
- Whale accumulation (Whale Alert)
- Exchange tier (Tier 1: Binance/Coinbase vs. Tier 2/3)
- Narrative fit (AI/Meme/DeFi/Gaming/RWA)

**Output:**
```json
{
  "momentumScore": 78,
  "potentialScore": 65,
  "riskLevel": "Medium",
  "whaleAccumulation": true,
  "smartMoney": false,
  "volumeSurge": "48x",
  "aiReason": "Strong AI narrative, Tier 1 listing, whale accumulation detected..."
}
```

---

## 7. DATABASE DESIGN

### 7.1 PostgreSQL — Tables

#### users
```sql
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT UNIQUE NOT NULL,
  password_hash   TEXT,
  google_id       TEXT UNIQUE,
  name            TEXT,
  avatar_url      TEXT,
  plan            TEXT NOT NULL DEFAULT 'free',  -- free | pro | elite
  email_verified  BOOLEAN DEFAULT false,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);
```

#### refresh_tokens
```sql
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  TEXT UNIQUE NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON refresh_tokens (user_id);
```

#### otp_codes
```sql
CREATE TABLE otp_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code        TEXT NOT NULL,
  purpose     TEXT NOT NULL,   -- forgot_password | email_verify
  expires_at  TIMESTAMPTZ NOT NULL,
  used        BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);
```

#### portfolio_holdings
```sql
CREATE TABLE portfolio_holdings (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  coin_id             TEXT NOT NULL,
  coin_symbol         TEXT NOT NULL,
  amount              NUMERIC(20, 8) NOT NULL,
  avg_buy_price_usd   NUMERIC(20, 8),
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON portfolio_holdings (user_id);
```

#### trade_journal
```sql
CREATE TABLE trade_journal (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pair          TEXT NOT NULL,
  direction     TEXT NOT NULL CHECK (direction IN ('long', 'short')),
  entry_price   NUMERIC(20, 8),
  exit_price    NUMERIC(20, 8),
  size          NUMERIC(20, 8),
  pnl_usd       NUMERIC(20, 8),
  pnl_percent   NUMERIC(10, 4),
  entry_at      TIMESTAMPTZ,
  exit_at       TIMESTAMPTZ,
  notes         TEXT,
  psychology    TEXT CHECK (psychology IN ('fomo', 'patient', 'revenge', 'disciplined')),
  strategy      TEXT,
  outcome       TEXT CHECK (outcome IN ('win', 'loss', 'breakeven')),
  created_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON trade_journal (user_id, entry_at DESC);
```

#### alerts
```sql
CREATE TABLE alerts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  coin_id       TEXT NOT NULL,
  coin_symbol   TEXT NOT NULL,
  alert_type    TEXT NOT NULL,  -- price_target | funding_spike | whale | volatility | sentiment | new_listing
  condition     TEXT,           -- above | below | percent_change
  target_value  NUMERIC(20, 8),
  is_active     BOOLEAN DEFAULT true,
  fired_at      TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON alerts (user_id);
CREATE INDEX ON alerts (is_active, coin_id);
```

#### chat_messages
```sql
CREATE TABLE chat_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role        TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content     TEXT NOT NULL,
  model       TEXT,
  tokens_used INTEGER,
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON chat_messages (user_id, created_at DESC);
```

#### user_preferences
```sql
CREATE TABLE user_preferences (
  user_id        UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  currency       TEXT DEFAULT 'USD',
  timezone       TEXT DEFAULT 'UTC',
  theme          TEXT DEFAULT 'dark',
  email_alerts   BOOLEAN DEFAULT true,
  push_alerts    BOOLEAN DEFAULT true,
  default_coins  TEXT[] DEFAULT ARRAY['bitcoin', 'ethereum'],
  ai_personality TEXT DEFAULT 'friendly',  -- direct | friendly | professional
  updated_at     TIMESTAMPTZ DEFAULT now()
);
```

#### subscriptions
```sql
CREATE TABLE subscriptions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  stripe_customer_id      TEXT UNIQUE,
  stripe_subscription_id  TEXT UNIQUE,
  plan                    TEXT NOT NULL CHECK (plan IN ('pro', 'elite')),
  status                  TEXT NOT NULL,  -- active | canceled | past_due | trialing
  current_period_end      TIMESTAMPTZ,
  created_at              TIMESTAMPTZ DEFAULT now(),
  updated_at              TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX ON subscriptions (user_id);
```

---

### 7.2 pgvector — Vector Store

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE market_patterns (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coin_id         TEXT NOT NULL,
  window_start    DATE NOT NULL,
  window_end      DATE NOT NULL,
  interval_days   INTEGER NOT NULL,  -- 30 | 60 | 90
  embedding       vector(1536) NOT NULL,
  features        JSONB NOT NULL,
  outcome_data    JSONB,
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX ON market_patterns
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

CREATE INDEX ON market_patterns (coin_id, window_start);
```

**features JSONB schema:**
```json
{
  "price_change_pct": 34.5,
  "volume_change_pct": 120.3,
  "rsi_start": 45.2,
  "rsi_end": 67.8,
  "macd_signal": "bullish_cross",
  "bollinger_width_pct": 8.2,
  "funding_rate_avg": 0.023,
  "fear_greed_avg": 72.0,
  "btc_dominance_avg": 48.5,
  "sentiment_score_avg": 68.0
}
```

**outcome_data JSONB schema:**
```json
{
  "price_30d_after": 101420.0,
  "pct_change_30d": 4.1,
  "price_60d_after": 104900.0,
  "pct_change_60d": 7.8,
  "price_90d_after": 98200.0,
  "pct_change_90d": -1.2
}
```

---

### 7.3 Redis — Key Namespaces

| Key Pattern | TTL | Purpose |
|-------------|-----|---------|
| `session:{userId}` | 7d | Session data |
| `market:coins:list:{page}` | 60s | Paginated coin list |
| `market:coin:{coinId}` | 30s | Single coin data |
| `market:ohlcv:{coinId}:{interval}` | 5m | OHLCV candles |
| `market:feargreed` | 1h | Fear & Greed index |
| `market:global` | 60s | Global market stats |
| `market:trending` | 5m | Trending coins |
| `market:funding` | 30s | Funding rates |
| `ai:analysis:{coinId}` | 15m | LLM analysis per coin |
| `ai:listing:score:{coinId}` | 4h | AI listing score |
| `sentiment:news` | 10m | News with scores |
| `sentiment:social:{coinId}` | 15m | Social sentiment per coin |
| `sentiment:{hash(text)}` | 24h | Individual article/tweet score |
| `rl:{userId}:{endpoint}` | sliding | Per-user rate limit counter |
| `rl:ip:{ip}` | sliding | Per-IP rate limit counter |

**Pub/Sub Channels:**
```
prices:{coinId}          Real-time price tick broadcast
alert:fired:{userId}     Trigger notification delivery
whale:alert              New whale transaction (broadcast all)
sentiment:update         Sentiment score changed for a coin
```

---

## 8. REAL-TIME INFRASTRUCTURE

### 8.1 WebSocket Server

**Library:** Socket.io (Node.js) with `@socket.io/redis-adapter` for horizontal scaling

**Connection:** `wss://api.aitradingcopilot.com`
**Auth:** JWT passed as query param `?token=<accessToken>` on connect

### 8.2 Event Contract

| Event | Direction | Payload |
|-------|-----------|---------|
| `subscribe:prices` | Client → Server | `{ coinIds: ["bitcoin", "ethereum"] }` |
| `unsubscribe:prices` | Client → Server | `{ coinIds: [...] }` |
| `price:tick` | Server → Client | `{ coinId, price, change24h, timestamp }` |
| `subscribe:alerts` | Client → Server | `{}` (auto on auth) |
| `alert:fired` | Server → Client | `{ alertId, coinId, type, message, firedAt }` |
| `whale:alert` | Server → Client | `{ from, to, amount, coin, valueUsd, txHash }` |
| `sentiment:update` | Server → Client | `{ coinId, score, change, source }` |
| `ai:chat:token` | Server → Client | `{ token, done: bool }` (streaming) |

### 8.3 Price Feed Architecture

```
Binance WebSocket Streams (server-side)
        │
        ▼
  Backend subscribes to Binance WS streams
  for top 50 coins (aggTrade + kline streams)
        │
        ▼
   Parse + normalize price data
        │
        ▼
  Publish to Redis: PUBLISH prices:{coinId} {...}
        │
        ▼
  Socket.io Redis adapter broadcasts to
  all subscribed client WebSocket connections
```

---

## 9. THIRD-PARTY INTEGRATIONS

### 9.1 Market Data

| Provider | Endpoint Used | Rate Limit | Env Var |
|----------|--------------|------------|---------|
| **CoinGecko Pro** | `/coins/markets`, `/coins/{id}`, `/coins/{id}/ohlc`, `/search/trending` | 500 req/min | `COINGECKO_API_KEY` |
| **Binance** | `/api/v3/ticker/24hr`, `/fapi/v1/fundingRate`, WS streams | 1200 req/min | `BINANCE_API_KEY` + `BINANCE_SECRET` |
| **Alternative.me** | `https://api.alternative.me/fng/` | Free, cache 1h | None |
| **Whale Alert** | `/v1/transactions` | 10 req/min | `WHALE_ALERT_API_KEY` |
| **Glassnode** | `/v1/metrics/*` (NVT, SOPR, exchange flows) | 3K req/month | `GLASSNODE_API_KEY` |
| **CoinMarketCal** | `/events` (new listings calendar) | 50 req/min | `COINMARKETCAL_API_KEY` |

### 9.2 Sentiment & Social

| Provider | Data | Env Var |
|----------|------|---------|
| **LunarCrush** | Social volume, engagement, sentiment score per coin | `LUNARCRUSH_API_KEY` |
| **CryptoPanic** | Curated crypto news with community votes | `CRYPTOPANIC_API_KEY` |
| **Twitter/X API v2** | Tweet search + volume by coin hashtag | `TWITTER_BEARER_TOKEN` |
| **Reddit API** | Subreddit post/comment sentiment | `REDDIT_CLIENT_ID` + `REDDIT_SECRET` |

### 9.3 AI & LLM

| Service | Model | Use Case | Env Var |
|---------|-------|---------|---------|
| **Anthropic** | `claude-sonnet-4-6` | Market analysis, chat (primary) | `ANTHROPIC_API_KEY` |
| **Anthropic** | `claude-haiku-4-5-20251001` | Sentiment scoring (cheap, high-volume) | `ANTHROPIC_API_KEY` |
| **OpenAI** | `gpt-4o` | Chat fallback | `OPENAI_API_KEY` |
| **OpenAI** | `text-embedding-3-large` | RAG embeddings | `OPENAI_API_KEY` |

### 9.4 Auth, Email, Payments

| Service | Purpose | Env Var |
|---------|---------|---------|
| **Google OAuth 2.0** | Social login | `GOOGLE_CLIENT_ID` + `GOOGLE_CLIENT_SECRET` |
| **Resend** | Transactional email (OTP, welcome, alert notifications) | `RESEND_API_KEY` |
| **Stripe** | Subscription billing (Pro + Institutional) | `STRIPE_SECRET_KEY` + `STRIPE_WEBHOOK_SECRET` |
| **Firebase Cloud Messaging** | Browser push notifications for alerts | `FCM_SERVER_KEY` |

---

## 10. AUTHENTICATION & SECURITY

### 10.1 Auth Flow

```
Email/Password:
  Register → hash password (bcrypt, cost 12)
           → send verification OTP
           → verify OTP → mark email_verified = true
           → login → issue JWT (15m) + refresh token (7d, httpOnly cookie)

Google OAuth:
  Click "Continue with Google"
  → redirect to /api/auth/google
  → Google consent screen
  → callback /api/auth/google/callback
  → upsert user (google_id)
  → issue JWT + refresh token

Token Refresh:
  Access token expires (15m)
  → client sends refresh token (cookie)
  → server validates, issues new access token
  → old refresh token invalidated (rotation)
```

### 10.2 Password Policy

- Minimum 8 characters (enforced in SignupForm + API)
- Must contain: uppercase letter, number
- bcrypt hash with cost factor 12

### 10.3 Rate Limiting

| Endpoint | Limit | Window |
|----------|-------|--------|
| `POST /api/auth/login` | 5 attempts | 15 min per IP |
| `POST /api/auth/register` | 3 accounts | 1 hour per IP |
| `POST /api/auth/forgot-password` | 3 OTP sends | 15 min per email |
| `POST /api/ai/chat` | Free: 3/day, Pro+: unlimited | 24 hours per user |
| All other endpoints | 100 req/min | Per user (JWT) |
| Unauthenticated | 20 req/min | Per IP |

### 10.4 Security Headers (Next.js + Nginx)

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: (to be configured per domain)
```

### 10.5 Data Security

- JWT stored in memory (Flutter) + `flutter_secure_storage`
- Refresh token in httpOnly cookie (Next.js), secure storage (Flutter)
- User API keys (exchange connections) encrypted at rest (AES-256)
- Row-level security: all DB queries scoped to `user_id`
- GDPR: `DELETE /api/user/account` removes all user data

---

## 11. SUBSCRIPTION & BILLING

### 11.1 Stripe Integration

**Events handled by `/api/billing/webhook`:**
- `checkout.session.completed` → create subscription row
- `customer.subscription.updated` → update plan/status
- `customer.subscription.deleted` → downgrade to free
- `invoice.payment_failed` → mark status `past_due`, send email

### 11.2 Feature Gating

| Feature | Free | Pro | Institutional |
|---------|------|-----|--------------|
| AI Market Summaries | 3/day | Unlimited | Unlimited |
| Market Memory Engine | No | Yes | Yes |
| Advanced Sentiment | Basic only | Yes | Yes |
| New Listings Intel | No | Yes | Yes |
| Risk Calculator | No | Yes | Yes |
| Trade Journal + Psychology | No | Yes | Yes |
| Whale Alerts | No | Yes | Yes |
| Advanced Charts + AI Overlay | No | Yes | Yes |
| AI Chat | No | Yes (GPT-4) | Yes (Priority) |
| Real-time WebSocket | No | Yes | Yes |
| API Access | No | No | Yes |
| Team Seats | 1 | 1 | 5 |
| White-label | No | No | Yes |
| SLA | No | No | Yes |

---

## 12. BACKGROUND JOBS

**Queue System:** BullMQ with Redis broker

| Job | Schedule | Description |
|-----|----------|-------------|
| `ingest-market-history` | Daily 00:00 UTC | Fetch OHLCV for top 100 coins, compute feature vectors, embed, upsert to pgvector |
| `score-new-listings` | Every 4h | CoinMarketCal + CoinGecko new listings → run AI scoring → cache results |
| `aggregate-sentiment` | Every 15m | LunarCrush + CryptoPanic + Twitter → score with Claude Haiku → cache in Redis |
| `check-price-alerts` | Every 30s | Fetch current prices → compare to active alerts → fire WebSocket events + email |
| `send-alert-emails` | On trigger | Resend email when alert fires (if user has email_alerts = true) |
| `update-fear-greed` | Every 1h | Alternative.me API → cache in Redis |
| `update-whale-alerts` | Every 2m | Whale Alert API → publish to Redis pub/sub → WebSocket broadcast |
| `clean-expired-tokens` | Daily 03:00 UTC | Delete expired OTPs and refresh tokens from DB |
| `update-funding-rates` | Every 30s | Binance fundingRate endpoint → cache + WebSocket broadcast |

---

## 13. DEPLOYMENT & DEVOPS

### 13.1 Local Development

```bash
# Root directory
npm run dev
# Runs concurrently:
#   - Next.js on :3000  (cd nextjs-app && npm run dev)
#   - Flutter Web on :5001  (cd flutter-app && flutter run -d web-server --web-port 5001)
#   - dev-proxy.js on :8080

# Or individually:
cd nextjs-app && npm run dev
cd flutter-app && flutter run -d web-server --web-port 5001 --web-hostname localhost
node dev-proxy.js
```

### 13.2 Environment Setup

```
nextjs-app/.env.local          (local dev — never commit)
nextjs-app/.env.example        (template — committed)
```

### 13.3 Production Deployment

**Next.js → Vercel:**
- Connect GitHub repo → Vercel auto-detects Next.js
- Root directory: `nextjs-app`
- Build command: `npm run build`
- Output: `.next` (standalone)
- Set all `NEXT_PUBLIC_*` and server-side env vars in Vercel dashboard

**Flutter Web → Vercel (via GitHub Actions):**
```yaml
# .github/workflows/deploy.yml
on: push (main branch)
steps:
  1. Setup Flutter
  2. flutter pub get
  3. flutter build web --release --web-renderer canvaskit
  4. Deploy build/web to Vercel
Secrets needed: VERCEL_FLUTTER_TOKEN, VERCEL_ORG_ID, VERCEL_FLUTTER_PROJECT_ID
```

**Backend API → Railway / Render / Fly.io:**
- Dockerfile-based deployment
- PostgreSQL: managed instance (Railway Postgres, Supabase, or Neon)
- Redis: Upstash (serverless Redis, free tier available)

**Docker Compose (optional self-hosted):**
```yaml
services:
  nextjs:   port 3000
  flutter:  port 5000
  nginx:    ports 80, 443 (reverse proxy)
```

### 13.4 Nginx Production Config

```
Domain:        aitradingcopilot.com
SSL:           /etc/nginx/ssl/cert.pem + key.pem
HTTP → HTTPS:  301 redirect
Gzip:          enabled (text/html, text/css, application/javascript, application/json)
WebSocket:     Upgrade + Connection headers for /socket.io/

Routing:
  /app/* /dashboard/* /analysis/* /charts/* /chat/*
  /memory/* /sentiment/* /listings/* /risk/* /journal/*
  /alerts/* /profile/*
                → proxy_pass Flutter Web (Vercel URL)

  /* (everything else)
                → proxy_pass Next.js (Vercel URL)
```

### 13.5 Post-Deployment Checklist

- [ ] Next.js Vercel project created and deployed
- [ ] Flutter Web Vercel project created
- [ ] GitHub Actions secrets configured (Vercel tokens)
- [ ] Backend API deployed (Railway / Render)
- [ ] PostgreSQL instance created + migrations run
- [ ] pgvector extension enabled
- [ ] Redis instance created (Upstash)
- [ ] All environment variables set in each service
- [ ] SSL certificate installed (Let's Encrypt or Vercel auto-SSL)
- [ ] DNS A/CNAME records updated
- [ ] Stripe webhook endpoint registered
- [ ] Google OAuth redirect URIs updated to production domain
- [ ] CORS configured: `api.aitradingcopilot.com` → allow `aitradingcopilot.com`
- [ ] Rate limiting enabled
- [ ] Sentry error tracking set up
- [ ] Background job workers running

---

## 14. DESIGN SYSTEM

### 14.1 Color Palette

**Background (shared across Next.js + Flutter):**
| Token | Hex | Use |
|-------|-----|-----|
| `bg-primary` | `#0A0B0F` | Main page background |
| `bg-secondary` | `#0F1117` | Section backgrounds |
| `bg-tertiary` | `#13151D` | Nested backgrounds |
| `bg-card` | `#141720` | Card backgrounds |
| `bg-card-hover` | `#1A1D28` | Card hover state |

**Brand Colors:**
| Token | Hex | Use |
|-------|-----|-----|
| `brand-green` | `#00FF88` | Primary accent, positive, CTAs |
| `brand-green-dim` | `#00CC6A` | Secondary green, hover states |
| `brand-red` | `#FF3366` | Negative, danger, loss |
| `brand-blue` | `#3B82F6` | Info, links, secondary actions |
| `brand-purple` | `#8B5CF6` | AI features, premium |
| `brand-cyan` | `#06B6D4` | Market data, listings |
| `brand-amber` | `#F59E0B` | Warnings, risk indicators |
| `brand-pink` | `#EC4899` | Trade journal, psychology |
| `brand-orange` | `#F97316` | Alerts |

**Text:**
| Token | Opacity | Use |
|-------|---------|-----|
| `text-primary` | 100% | Headings, primary content |
| `text-secondary` | 60% | Body text, descriptions |
| `text-muted` | 30% | Placeholders, disabled |
| `text-disabled` | 15% | Truly disabled |

**Borders:**
| Token | Opacity | Use |
|-------|---------|-----|
| `border-subtle` | 6% white | Default card borders |
| `border-default` | 10% white | Active/visible borders |
| `border-bright` | 25% white | Highlighted borders |
| `border-green` | 24% green | Focus/selected state |

### 14.2 Typography

**Fonts:** Inter (primary), JetBrains Mono (code/numbers)
**Loaded via:** Google Fonts (Next.js layout.tsx + Flutter pubspec.yaml)

| Style | Size | Weight | Use |
|-------|------|--------|-----|
| Display Large | 48px | 900 | Hero headlines |
| Display Medium | 36px | 800 | Section headlines |
| Headline Large | 24px | 700 | Card titles |
| Headline Medium | 20px | 600 | Sub-section titles |
| Title Large | 16px | 600 | Navigation items, labels |
| Body Large | 16px | 400 | Paragraph text |
| Body Medium | 14px | 400 | Secondary body |
| Body Small | 12px | 400 | Captions, metadata |
| Mono | 13px | 500 | Prices, numbers, code |

### 14.3 Animations

| Animation | Duration | Use |
|-----------|----------|-----|
| `float` | 6s loop | Cards, icons floating |
| `glow-pulse` | 2s loop | Live indicator, green glows |
| `slide-up` | 0.5s | Page/section entry |
| `fade-in` | 0.8s | Element reveal |
| `ticker` | 30s loop | Price ticker tape |
| `pulse-slow` | 4s loop | Status indicators |

### 14.4 Responsive Breakpoints

| Name | Width | Layout |
|------|-------|--------|
| Mobile | < 768px | Single column, bottom nav |
| Tablet | 768–1023px | Two column or stacked, bottom nav |
| Desktop | ≥ 1024px | Sidebar + content layout |

---

## 15. ENVIRONMENT VARIABLES

### 15.1 Next.js (.env.local)

```env
# App URLs
NEXT_PUBLIC_APP_URL=https://aitradingcopilot.com
NEXT_PUBLIC_FLUTTER_DASHBOARD_URL=https://coinpilot-flutter.vercel.app
FLUTTER_APP_URL=http://localhost:5001
NEXT_PUBLIC_API_URL=https://api.aitradingcopilot.com
NEXT_PUBLIC_WS_URL=wss://api.aitradingcopilot.com
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX

# Auth (server-side only)
NEXTAUTH_SECRET=
NEXTAUTH_URL=https://aitradingcopilot.com
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# Market Data APIs (server-side only)
COINGECKO_API_KEY=
BINANCE_API_KEY=
BINANCE_SECRET=

# AI (server-side only)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
```

### 15.2 Backend API (.env)

```env
# Server
NODE_ENV=production
PORT=4000
API_URL=https://api.aitradingcopilot.com
FRONTEND_URL=https://aitradingcopilot.com

# Database
DATABASE_URL=postgresql://user:pass@host:5432/coinpilot
REDIS_URL=redis://default:pass@host:6379

# Auth
JWT_SECRET=
JWT_EXPIRY=15m
REFRESH_TOKEN_SECRET=
REFRESH_TOKEN_EXPIRY=7d
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_CALLBACK_URL=https://api.aitradingcopilot.com/api/auth/google/callback

# Email
RESEND_API_KEY=
FROM_EMAIL=noreply@aitradingcopilot.com

# Market Data
COINGECKO_API_KEY=
BINANCE_API_KEY=
BINANCE_SECRET=
WHALE_ALERT_API_KEY=
GLASSNODE_API_KEY=
COINMARKETCAL_API_KEY=

# Sentiment
LUNARCRUSH_API_KEY=
CRYPTOPANIC_API_KEY=
TWITTER_BEARER_TOKEN=
REDDIT_CLIENT_ID=
REDDIT_SECRET=

# AI / LLM
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
DEFAULT_AI_MODEL=claude-sonnet-4-6

# Vector DB (pgvector uses DATABASE_URL above — or Pinecone below)
PINECONE_API_KEY=
PINECONE_INDEX=coinpilot-market-memory
PINECONE_ENVIRONMENT=us-east-1-aws

# Payments
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRO_PRICE_ID=
STRIPE_ELITE_PRICE_ID=

# Push Notifications
FCM_SERVER_KEY=
```

---

## 16. DEVELOPMENT ROADMAP

### Phase 1 — Frontend (COMPLETE)
- [x] Next.js landing page — all components
- [x] Next.js auth pages — login, signup, OTP, forgot password
- [x] Next.js blog page
- [x] Flutter app shell — sidebar, topbar, responsive layout
- [x] All 11 Flutter dashboard screens (UI-only, mock data)
- [x] Design system — colors, typography, animations
- [x] Routing architecture (GoRouter + Next.js rewrites)
- [x] Docker Compose + Nginx config
- [x] GitHub Actions CI/CD workflow
- [x] Vercel deployment documentation

### Phase 2 — Backend Foundation (NOT STARTED)
- [ ] Choose backend framework (Node.js + Fastify recommended)
- [ ] Set up PostgreSQL + run migrations for all 9 tables
- [ ] Enable pgvector extension
- [ ] Set up Redis (Upstash)
- [ ] Implement auth endpoints (register, login, OTP, Google OAuth, refresh)
- [ ] Implement user profile endpoints
- [ ] Set up Resend for transactional email

### Phase 3 — Market Data Layer (NOT STARTED)
- [ ] Build CoinGecko proxy with Redis caching
- [ ] Build Binance proxy (REST + WebSocket)
- [ ] Implement WebSocket server (Socket.io + Redis adapter)
- [ ] Set up price feed pipeline (Binance WS → Redis pub/sub → Socket.io)
- [ ] Implement all `/api/market/*` endpoints
- [ ] `/api/dashboard/summary` aggregation endpoint

### Phase 4 — AI & RAG (NOT STARTED)
- [ ] Integrate Anthropic SDK (Claude Sonnet 4.6)
- [ ] Build AI analysis endpoint with prompt engineering
- [ ] Build AI chat endpoint with SSE streaming
- [ ] Build Market Memory ingestion pipeline (nightly job)
- [ ] Build Market Memory query endpoint (pgvector cosine search)
- [ ] Build sentiment scoring pipeline (Claude Haiku batch)
- [ ] Build new listings AI scoring

### Phase 5 — Feature Completion (NOT STARTED)
- [ ] Connect all Flutter screens to live API endpoints
- [ ] Replace all mock data with real API calls
- [ ] Implement trade journal CRUD + analytics
- [ ] Implement portfolio CRUD
- [ ] Implement alerts system (creation + background checker + WebSocket fire)
- [ ] Integrate Stripe billing (checkout, portal, webhook)
- [ ] Build all background BullMQ jobs

### Phase 6 — Polish & Launch (NOT STARTED)
- [ ] Rate limiting middleware
- [ ] Error monitoring (Sentry)
- [ ] Performance audit (Lighthouse, API response times)
- [ ] Security audit
- [ ] Load testing
- [ ] Beta user onboarding
- [ ] Production launch on aitradingcopilot.com

---

## 17. PROJECT METRICS

| Metric | Count |
|--------|-------|
| **Next.js Pages** | 8 |
| **Next.js Landing Components** | 12 |
| **Next.js Auth Components** | 4 |
| **Flutter Screens** | 11 |
| **Flutter Dashboard Widgets** | 7 |
| **Flutter Core Widgets** | 4 |
| **Planned API Endpoints** | 46 |
| **AI Endpoints** | 7 |
| **Third-Party Service Integrations** | 14 |
| **PostgreSQL Tables** | 9 |
| **Vector Table** | 1 (market_patterns) |
| **Redis Key Namespaces** | 14 |
| **WebSocket Event Types** | 8 |
| **Background Jobs** | 9 |
| **Auth Methods** | 2 (email/password + Google OAuth) |
| **Subscription Tiers** | 3 (Free, Pro, Institutional) |
| **Pricing Plans** | 6 (3 tiers × monthly/annual) |
| **Chart Timeframes** | 7 |
| **Technical Indicators** | 5 |
| **Sentiment Sources** | 4 |
| **Alert Types** | 6 |
| **Responsive Breakpoints** | 3 |
| **Brand Colors** | 9 |
| **Custom Animations** | 6 |
| **Total Files (Frontend)** | 70+ |

---

*Document prepared by comprehensive codebase analysis — CoinPilot v1.0.0 — 2026-05-19*
