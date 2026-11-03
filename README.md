# 🪔 RamSeva — Ramdevra Society Fund Management System
### A Multilingual Residential Society Finance, Ledger & Festival Management Application

> **"Ram Na Aashirwad, Hanumanji Ni Shakti, Ramdevra Ni Pragati."**  
> *"રામના આશીર્વાદ, હનુમાનજીની શક્તિ, રામદેવરાની પ્રગતિ."*  
> *"राम के आशीर्वाद, हनुमानजी की शक्ति, रामदेवरा की प्रगति।"*

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-APK%20Release-3DDC84?logo=android&logoColor=white)](#-download-android-app)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%7C%20Realtime%20%7C%20Auth-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Localization](https://img.shields.io/badge/Languages-English%20%7C%20%E0%AA%97%E0%AA%81%E0%AA%9C%E0%AA%B0%E0%AA%BE%E0%AA%A4%E0%AB%80%20%7C%20%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-FF6B6B)](#-trilingual-localization-support)
[![Open Source License](https://img.shields.io/badge/License-Cooperative%20Society%20Charter-FF9800)](#-license--society-governance)

---

## 📱 DOWNLOAD ANDROID APP

Society residents can download and install the official Android release directly onto their smartphones for free:

### 📥 Direct Release APK Download:
👉 **[Download RamSeva Release APK (v1.0.0)](https://github.com/jayudavariya18-maker/society-fund-management/releases/download/v1.0.0/app-release.apk)**  
*(Alternatively, browse all releases at [GitHub Releases Page](https://github.com/jayudavariya18-maker/society-fund-management/releases))*

- **Direct Download Link**: [https://github.com/jayudavariya18-maker/society-fund-management/releases/download/v1.0.0/app-release.apk](https://github.com/jayudavariya18-maker/society-fund-management/releases/download/v1.0.0/app-release.apk)
- **Application Name**: `RamSeva`
- **Society Name**: `Ramdevra Society`
- **Package ID**: `com.society.bajrang` *(Preserved for installation consistency)*
- **Version**: `1.0.0` (Build `1`)
- **Compatibility**: Android 5.0 (API 21) up to Android 15+ (API 36)
- **Supported Architectures**: Universal APK (`arm64-v8a`, `armeabi-v7a`, `x86_64`)
- **Primary Visual Theme**: Sacred Gold (`#D4AF37`), Vibrant Saffron (`#FF6D00`), Deep Navy (`#0F1E36`)

### 📲 Step-by-Step Android Installation Guide:
1. Tap the **[Download APK](https://github.com/jayudavariya18-maker/society-fund-management/releases/download/v1.0.0/app-release.apk)** link above using Chrome or any mobile browser.
2. Once the download completes, tap **Open** or locate `app-release.apk` in your phone's **Downloads** folder.
3. If Android displays a prompt stating *"For your security, your phone is not allowed to install unknown apps from this source"*:
   - Tap **Settings**.
   - Toggle **Allow from this source** to ON.
   - Tap the back button and tap **Install**.
4. Tap **Open** to launch **RamSeva**.
5. Select your preferred language (**English**, **ગુજરાતી**, or **हिन्दी**) on the top-right and sign in with your 10-digit mobile number.

---

## 📖 Executive Summary
**RamSeva** is a production-grade, multi-platform (**Android** and **Responsive Web**) residential society financial management and festival administration application engineered specifically for **Ramdevra Society**.

Unlike conventional opaque apps or top-down accounting software, RamSeva implements an **auditable, double-entry-inspired ledger** where:
- Every rupee has a verifiable source and purpose.
- Every expenditure and contribution has an identified member actor.
- All active residents hold equal democratic governance privileges (no permanent admin hierarchies).
- Financial data synchronizes instantaneously across all member devices via Supabase Realtime.

---

## 🌟 Key Architectural Highlights

### 1. Centralized Realtime Multi-Device Synchronization
- **Supabase Realtime PostgreSQL CDC (Change Data Capture)**: Listens for mutations on `contributions`, `expenses`, `funds`, `members`, `festivals`, and `registration_requests`.
- **Immediate Cross-Device Propagation**: When Resident A records a contribution or expense, Resident B's dashboard and balance sheets immediately refresh without manual restarts.
- **Riverpod Cache Invalidation**: Coordinated invalidation ensures UI state is always a direct reflection of central Supabase PostgreSQL records.
- **App Lifecycle & Connectivity Resilience**: Auto-fetches latest backend data upon app resume, screen navigation, and network reconnection.

### 2. Clean Initial State & First-Member Bootstrap
- **Zero Demonstration Clutter**: The database and application start with ₹0.00 balances, zero demo members, and zero fake transactions.
- **First-Member Bootstrap Gate**: When RamSeva is first deployed to a fresh society (`active_members_count == 0`), the first registered resident is automatically verified and activated as the founding member.
- **Automatic Gate Lockout**: The instant 1 active member exists, the bootstrap mechanism permanently closes. All subsequent applicants require explicit verification by an existing active neighbor.
- **Self-Approval Prevention**: An applicant can never approve their own registration; mutual trust across neighbors is enforced at both Flutter and PostgreSQL database trigger levels.

### 3. Native Mobile OTP Authentication
- Clean +91 Indian mobile number authentication powered by Supabase Auth (`signInWithOtp`, `verifyOTP`).
- Automatic session caching and persistence across app restarts.
- Resident approval pipeline: `Unregistered -> Mobile OTP -> Registration Form -> Pending Approval -> Active Resident`.
- Actionable SMS provider diagnostics when custom gateways (Twilio, MessageBird, Textlocal) need to be provisioned in the Supabase console.

### 4. Double-Entry Inspired Immutable Accounting
- **Exact Decimal Arithmetic**: Uses PostgreSQL `NUMERIC(12,2)` and precision-safe Dart decimal math, eliminating IEEE 754 floating-point drift.
- **Strict Fund Isolation**:
  - **General Society Fund**: General maintenance (electricity, security, lifts, repairs, cleaning).
  - **Dedicated Festival Funds**: Isolated accounts for celebrations (Navratri, Diwali, Ganesh Chaturthi, Janmashtami). Festival finances never co-mingle with general funds.
- **Zero Silent Deletion**: Posted records are immutable. Corrections are executed through traceable reversal and adjustment entries.

### 5. Trilingual Multilingual Support
Built with Flutter's official localization system (`app_en.arb`, `app_gu.arb`, `app_hi.arb`):
1. **English (Default)**
2. **Gujarati (ગુજરાતી)**
3. **Hindi (हिन्दी)**
- Indian Rupee (`₹`) formatting, Indian numbering system (Lakhs & Crores), and persistent language preferences.

---

## 🛠️ Technology Stack
- **Frontend Framework**: Flutter & Dart (Android and Responsive Web)
- **State Management**: `flutter_riverpod: ^2.5.1`
- **Routing & Navigation**: `go_router: ^14.2.0`
- **Backend & Database**: Supabase (PostgreSQL 15+, Auth, Realtime, Storage, RLS, Triggers)
- **Document & Receipt Generation**: `pdf: ^3.10.8`, `printing: ^5.13.0`
- **Charts & Data Visualization**: `fl_chart: ^0.68.0`
- **Preferences & Persistence**: `shared_preferences: ^2.2.3`

---

## 📁 Project Directory Structure
```
bajrang/
├── assets/
│   └── images/
│       ├── logo.png                            # Official sacred ceremonial object logo
│       └── logo.jpeg                           # High-resolution original master
├── lib/
│   ├── main.dart                               # App entry point & dynamic config loader
│   ├── app/
│   │   ├── app.dart                            # RamSevaApp & lifecycle synchronization
│   │   ├── router.dart                         # GoRouter route definitions & guards
│   │   ├── localization/                       # Typed localization & Riverpod provider
│   │   └── theme/                              # Royal Gold, Saffron & Navy Blue palette
│   ├── core/
│   │   ├── config/                             # Supabase URL & Key dynamic loader
│   │   ├── services/                           # Supabase Realtime, PDF, CSV, Receipts
│   │   ├── utils/                              # Currency (INR), Date, Phone validators
│   │   └── widgets/                            # ResponsiveScaffold, StatCard, TransactionTile
│   ├── features/
│   │   ├── authentication/                     # Phone OTP auth flow & session persistence
│   │   ├── registration/                       # Resident registration & bootstrap gate
│   │   ├── dashboard/                          # Tagline banner, metric overview & actions
│   │   ├── funds/                              # General vs Festival fund ledgers
│   │   ├── contributions/                      # Deposits, payments & receipt generation
│   │   ├── expenses/                           # Outgoing payments & auditable corrections
│   │   ├── festivals/                          # Festival & sub-event management
│   │   ├── members/                            # Member directory & registration approvals
│   │   ├── reports/                            # Financial statement, PDF & CSV export
│   │   ├── announcements/                      # Community notice board
│   │   ├── audit_logs/                         # Append-only chronological activity log
│   │   └── profile/                            # Resident profile & language switcher
│   ├── l10n/                                   # ARB files (app_en.arb, app_gu.arb, app_hi.arb)
│   └── shared/models/                          # Typed immutable domain models
├── supabase/
│   ├── migrations/
│   │   ├── 20261101_000001_initial_schema.sql  # 11 tables, constraints, views & triggers
│   │   ├── 20261101_000002_rls_and_audit.sql   # RLS policies & automatic audit triggers
│   │   └── 20261102_000003_ramseva_init_and_bootstrap.sql # Realtime & bootstrap procedure
│   └── seed.sql                                # Clean initial state: Ramdevra Society (₹0)
├── test/
│   ├── unit/                                   # 15 Financial, security & localization tests
│   └── widget_test.dart                        # RamSevaApp smoke test
└── docs/                                       # Architecture & deployment specifications
```

---

## 🚀 Quick Start & Database Setup

### 1. Configure Supabase Credentials
You can provide your Supabase credentials through any of three convenient methods:

#### Option A: Compile-Time / Run-Time Defines
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### Option B: Assets Configuration File
Create `assets/config.json`:
```json
{
  "supabaseUrl": "https://your-project.supabase.co",
  "supabaseAnonKey": "your-anon-key"
}
```

#### Option C: In-App Diagnostics Screen
Launch the application and navigate to Settings to save your backend credentials directly into local device storage.

### 2. Apply Database Migrations in Supabase
Run the SQL scripts in your Supabase SQL Editor in sequence:
1. `supabase/migrations/20261101_000001_initial_schema.sql`
2. `supabase/migrations/20261101_000002_rls_and_audit.sql`
3. `supabase/migrations/20261102_000003_ramseva_init_and_bootstrap.sql`
4. `supabase/seed.sql`

This creates the tables, enables **Supabase Realtime** on financial ledgers, configures RLS, and sets the clean opening balance to ₹0.00 for **Ramdevra Society**.

### 3. Build & Run
```bash
# Run Unit & Widget Tests
flutter test

# Build Android Release APK
flutter build apk --release

# Run Web Application
flutter run -d chrome
```

---

## 🧪 Automated Test Suite
RamSeva includes comprehensive unit and widget tests covering all financial scenarios:
- **Scenario 1**: Exact decimal arithmetic without IEEE 754 precision drift.
- **Scenario 2**: Complete isolation between General Fund and Festival Funds.
- **Scenario 3**: Unapproved members strictly denied financial ledger read/write access.
- **Scenario 4**: Self-approval prevention (`applicant != reviewer`).
- **Scenario 5**: Duplicate payment idempotency protection.
- **Scenario 6**: Auditable expense corrections with immutable audit references.
- **Scenario 7**: Trilingual switching (EN/GU/HI) with persistent financial integrity.
- **Scenario 8**: First-member bootstrap gate that activates the founding resident and locks permanently.

Run the test suite with:
```bash
flutter test
```

---

## ⚖️ License & Society Governance
Configured for **Ramdevra Society**. Distributed under the equal-resident democratic society charter.
