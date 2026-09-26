# DreamFund 🚀

> **Family Financial Goal & Savings Application**

DreamFund is a cross-platform (Web, Android, iOS) financial goal-planning and savings application built with Flutter & Dart. It helps users define target purchase goals (e.g. Gaming PC, Europe Vacation, Emergency Reserves), calculate exact required monthly/weekly contributions, analyze budget affordability, and collaborate within a shared family vault.

---

## 🌟 Key Features

* 🎯 **Smart Goal Calculation Engine**: Automatically calculates required monthly and weekly savings (`(Target Price - Current Saved) / Months Remaining`), estimated completion dates, and affordability scenarios.
* 💡 **Financial Recommendation System**: Real-time advice and 3 actionable options when savings fall short (extend target date, increase weekly contributions, or adjust target budget).
* 📊 **Dashboard & Metrics**: Visual breakdown of total savings vault, combined goal progress bars, monthly goal plans, and unallocated cash surplus.
* 👨‍👩‍👧‍👦 **Shared Family Vault**: Collaborative savings group with invite code generation (`DREAM-7890`) and family member contribution tracking.
* 💳 **Monthly Budget & Cashflow Tracker**: Category budgets with expenditure progress indicators and transaction logs (Income vs Expense).
* ⚡ **Gamification & Achievements**: Level progression, XP rewards (+50 XP for goals, +25 XP for deposits), streak counters, and milestone badges.
* 📱 **Responsive Cross-Platform UI**: Adapts automatically with a Side Navigation Rail on Web/Desktop and Bottom Navigation Bar on Mobile.

---

## 🏗️ Technology Stack

* **Frontend**: Flutter & Dart (Material 3 Design)
* **State Management**: Riverpod (`flutter_riverpod`)
* **Routing**: GoRouter (`go_router`)
* **Typography & UI**: Google Fonts (`google_fonts`), `fl_chart`, `percent_indicator`
* **Backend Ready**: Decoupled repository architecture ready for Firebase Cloud Firestore & Cloud Functions integration.

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.47.0 or higher)
* [Dart SDK](https://dart.dev/)
* Chrome / Edge (for Web execution)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Chintan-dev/DreamFund.git
   cd DreamFund
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Web**:
   ```bash
   flutter run -d chrome
   ```

4. **Build Web Release**:
   ```bash
   flutter build web
   ```

---

## 📁 Architecture Overview

```
lib/
├── core/
│   ├── theme/          // Material 3 Dark/Light themes & Brand Palette
│   └── utils/          // Currency formatters & Savings Calculation Engine
├── features/
│   ├── auth/           // Authentication & User profile models
│   ├── dashboard/      // Financial overview & active goals carousel
│   ├── goals/          // Goal creation, detail view & deposit modals
│   ├── budget/         // Cashflow summary, category budgets & transactions
│   ├── family/         // Shared vault & family member contributions
│   └── gamification/   // XP level system, streaks & milestone badges
└── main.dart           // ProviderScope & GoRouter configuration
```

---

## 📜 License

Designed and developed for personal and family wealth goal planning.
