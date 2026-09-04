# 🎓 Tuitio — Tuition & Class Tracker

**Tuitio** is a sleek, modern, offline-first cross-platform application designed for private tutors, home educators, and freelance instructors to effortlessly manage students, log class sessions, track flexible class-based payment cycles, and monitor monthly income.

---

## 🚀 Key Features

- **📱 Class-Based Payment Cycles**: Unlike rigid calendar months, Tuitio models tuition around customizable class-count cycles (e.g., 12 classes per cycle). Cycles automatically track session counts and transition seamlessly upon payment.
- **📊 Interactive Dashboard**: Instant access to active student cards, progress indicators (e.g., 8/12 classes completed), and quick-action class log modal with date/time pickers and session notes.
- **👤 Student Management**: Full CRUD capabilities for student profiles, contact info, customizable target class counts, and fee structures.
- **📜 Class Logs & Timeline**: Detailed history per student showing individual session durations, start/end timestamps, and topic notes.
- **💰 Salary & Earnings Analytics**: Real-time financial summary showing total collected revenue vs. pending/unpaid tuition balances, with quick one-tap paid/unpaid status toggles.
- **⚡ Reactive Offline Data**: Powered by SQLite & Drift DB for ultra-fast local storage, data privacy, and instant multi-screen state synchronization via Riverpod streams.
- **🎨 Modern UI/UX**: Built with `shadcn_ui` for clean typography, micro-animations, fluid state changes, and dark/light responsive layouts.

---

## 🛠️ Technology Stack

| Layer                      | Technology                                                                          |
| :------------------------- | :---------------------------------------------------------------------------------- |
| **Framework**              | [Flutter](https://flutter.dev) (Dart 3.x)                                           |
| **State Management**       | [Flutter Riverpod](https://riverpod.dev) (v3)                                       |
| **Database / Persistence** | [Drift](https://drift.simonbinder.eu/) (SQLite native engine)                       |
| **UI Components**          | [shadcn_ui](https://pub.dev/packages/shadcn_ui) + Custom Cupertino/Material Widgets |
| **Routing**                | [go_router](https://pub.dev/packages/go_router) with Stateful Shells                |
| **Platforms Supported**    | Android, iOS, Windows, macOS, Linux, Web                                            |

---

## 📁 Project Structure

```
lib/
├── app/                  # Application initialization & Routing
│   ├── app.dart          # Main MaterialApp entry widget
│   └── router.dart       # GoRouter configuration & shell navigation
├── core/                 # Shared utilities, constants, database & base UI
│   ├── constants/        # Global constants
│   ├── database/         # Drift SQLite setup, tables, DAOs & providers
│   │   ├── daos/         # Data Access Objects (Students, Classes, PaymentCycles)
│   │   └── tables/       # Table schema definitions
│   ├── extensions/       # Dart extension methods
│   ├── utils/            # Helper utilities (date formatting, currency)
│   └── widgets/          # Reusable shared UI widgets (AppShell, Cards, Modals)
└── features/             # Feature-oriented architecture
    ├── classes/          # Class session logic & UI components
    ├── dashboard/        # Active student list, quick log & status overview
    ├── salary/           # Revenue breakdown, payment cycle trackers & stats
    └── students/         # Student directory, detailed history & forms
```

---

## ⚡ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.2` or later)
- [Dart SDK](https://dart.dev/get-started)
- Optional: [Just](https://github.com/casey/just) command runner for code generation

### Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/mmycin/Tuitio-App.git
    cd Tuitio-App
    ```

2. **Install dependencies:**

    ```bash
    flutter pub get
    ```

3. **Generate database models and DAO code:**

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    # Or using Just:
    just buildGen
    ```

4. **Run the app:**
    ```bash
    flutter run
    ```

---

## 🗄️ Database Architecture

The local database uses **Drift (SQLite)** and is built around 3 primary entities:

1. **`Students`**: Stores student metadata (name, phone, monthly fee, target classes per month).
2. **`PaymentCycles`**: Manages flexible tuition billing blocks (`studentId`, `totalClasses`, `isPaid`, `startedAt`, `paidAt`).
3. **`Classes`**: Logged sessions tied to a student and their current active cycle (`studentId`, `cycleId`, `startedAt`, `endedAt`, `notes`).

---

## 📝 License

This project is private and proprietary software.
