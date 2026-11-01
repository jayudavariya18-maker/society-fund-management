# 🏢 Bajrang Society Fund Management System
### A Complete Multilingual Society Finance & Festival Management Application

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%7C%20Auth-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Localization](https://img.shields.io/badge/Languages-EN%20%7C%20GU%20%7C%20HI-FF6B6B)](#multilingual-support)
[![Architecture](https://img.shields.io/badge/Access%20Model-NO%20ROLES%20(Equal%20Rights)-16324F)](#user-access-philosophy--no-roles)

---

## 📖 Executive Summary
The **Bajrang Society Fund Management System** is a production-quality, multi-platform (**Android** and **Responsive Web**) financial transparency and festival administration system designed specifically for a single residential co-operative housing society.

Unlike generic multi-tenant SaaS or student demonstration apps, this application implements an **auditable, double-entry-inspired ledger** where every rupee has a traceable origin, every expenditure has an identified member actor, and all active residents possess equal governance access.

---

## 🌟 Key Architectural Highlights

### 1. User Access Philosophy — NO ROLES
- **Elimination of Administrative Hierarchy**: Conventional roles such as Admin, Chairman, Treasurer, or Secretary are omitted.
- **Equal Member Permissions**: Every verified resident can inspect all accounts, log contributions, record expenses, review audit logs, and approve new residents.
- **Traceable Ledger Identity**: Every transaction permanently records `created_by` (the active resident's `member_id`).
- **Self-Approval Prevention**: A person cannot approve their own registration; an existing neighbor must confirm their residency.

### 2. Double-Entry Inspired Immutable Accounting
- **Exact Decimal Arithmetic**: Uses PostgreSQL `NUMERIC(12,2)` and exact decimal math in Dart, avoiding IEEE 754 floating-point errors.
- **Strict Fund Isolation**:
  - **General Society Maintenance Fund**: Operational capital for building electricity, security, lifts, and repairs.
  - **Dedicated Festival Funds**: Independent accounts for celebrations (Navratri, Diwali, Ganesh Chaturthi). Funds never co-mingle.
- **Zero Silent Deletion**: Posted transactions are immutable. Corrections are executed through traceable reversal and adjustment entries.

### 3. Trilingual Multilingual Support
Built with Flutter's official localization system (`app_en.arb`, `app_gu.arb`, `app_hi.arb`) and 131 matching translation keys:
1. **English (Default)**
2. **Gujarati (ગુજરાતી)**
3. **Hindi (हिन्दी)**
- Indian Rupee (`₹`) formatting, Indian numbering system (Lakhs & Crores), and persistent language preferences.

### 4. Database-Enforced Row Level Security (RLS)
- 11 normalized PostgreSQL tables protected with strict RLS policies.
- Pending or unauthenticated users are blocked from all financial ledgers.
- Database triggers automate audit trails (`public.audit_logs`) and registration activations.

---

## 🛠️ Technology Stack
- **Frontend Framework**: Flutter & Dart (Targeting Android and Responsive Web)
- **State Management**: `flutter_riverpod: ^2.5.1`
- **Routing & Navigation**: `go_router: ^14.2.0`
- **Backend & Database**: Supabase (PostgreSQL 15+, Auth, Storage, RLS, Triggers)
- **Document & Receipt Generation**: `pdf: ^3.10.8`, `printing: ^5.13.0`
- **Charts & Data Visualization**: `fl_chart: ^0.68.0`
- **Preferences & Persistence**: `shared_preferences: ^2.2.3`

---

## 📁 Project Directory Structure
```
bajrang/
├── lib/
│   ├── main.dart                               # App entry point & Supabase init
│   ├── app/
│   │   ├── app.dart                            # MaterialApp.router configuration
│   │   ├── router.dart                         # GoRouter route definitions & guards
│   │   ├── localization/                       # Typed localization & Riverpod provider
│   │   └── theme/                              # Material 3 Navy Blue & Teal palette
│   ├── core/
│   │   ├── services/                           # PDF, CSV, Receipt, Supabase services
│   │   ├── utils/                              # Currency (INR), Date, Phone validators
│   │   └── widgets/                            # ResponsiveScaffold, StatCard, TransactionTile
│   ├── features/
│   │   ├── authentication/                     # Phone OTP auth flow
│   │   ├── registration/                       # Resident registration & pending approval
│   │   ├── dashboard/                          # Metric overview, charts & quick actions
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
│   │   └── 20261101_000002_rls_and_audit.sql   # RLS policies & automatic audit triggers
│   └── seed.sql                                # Sample society, members, funds & festivals
├── test/
│   └── unit/                                   # Financial accounting & security unit tests
├── docs/                                       # DATABASE, SECURITY, SETUP, DEPLOYMENT guides
└── .env.example                                # Environment variable template
```

---

## 🚀 Quick Start Guide

### 1. Setup Environment
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Configure your Supabase credentials, or launch immediately in **Development Mock Mode** using pre-configured test profiles:
- **Active Resident**: Phone `+919825000001`, OTP `123456`
- **Pending Resident**: Phone `+919825000004`, OTP `123456`

### 2. Apply Database Migrations
Execute the migrations in the Supabase SQL editor:
1. `supabase/migrations/20261101_000001_initial_schema.sql`
2. `supabase/migrations/20261101_000002_rls_and_audit.sql`
3. `supabase/seed.sql`

### 3. Run the Application
```bash
# Fetch dependencies
flutter pub get

# Run on Responsive Web
flutter run -d chrome

# Run on Android Device / Emulator
flutter run -d android
```

---

## 🧪 Automated Test Suite & Scenarios
Run automated tests:
```bash
flutter test
```
The automated test runner validates all 7 core financial and security requirements:
- **Scenario 1**: General Fund Opening (₹10,000) + Contribution (₹5,000) - Expense (₹2,000) = ₹13,000.00 exact calculation.
- **Scenario 2**: Festival Fund Strict Isolation: Navratri collections (₹20,000) - expenses (₹8,000) = ₹12,000.00 without impacting Diwali Fund.
- **Scenario 3**: Pending members strictly denied financial ledger read/write access.
- **Scenario 4**: Self-approval prevention (`auth_uid == reviewer_auth_uid`) rejected.
- **Scenario 5**: Duplicate payment idempotency check blocks identical submissions.
- **Scenario 6**: Auditable expense correction preserving immutable transaction history.
- **Scenario 7**: Trilingual switching between English, Gujarati, and Hindi with 100% financial integrity.

---

## 📄 Documentation Links
- [Database Schema & Architecture](file:///docs/DATABASE.md)
- [Security & Row Level Security Policies](file:///docs/SECURITY.md)
- [Environment & Developer Setup](file:///docs/SETUP.md)
- [Production Deployment Guide](file:///docs/DEPLOYMENT.md)
- [Resident Operations Handbook](file:///docs/USER_GUIDE.md)

---

## ⚖️ License & Society Governance
Configured for **Bajrang Heights Co-Operative Housing Society**. Distributed under the equal-member society charter.
