# Developer & Environment Setup Guide
## Bajrang Residential Society Fund Management System

### 1. Prerequisites
Ensure the following tools are installed on your workstation:
1. **Flutter SDK**: Version 3.19.0 or later (Dart 3.3.0+)
   ```bash
   flutter doctor
   ```
2. **Git**: Version 2.40+
3. **Supabase CLI** (optional for local database testing) or a free Supabase cloud project account:
   ```bash
   npx supabase --version
   ```
4. **Android Studio** (for Android APK / Bundle builds) or Chrome (for Flutter Web development).

---

### 2. Environment Variables Configuration
1. Copy the `.env.example` template to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Fill in your project settings:
   ```ini
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key-here
   SOCIETY_ID=00000000-0000-0000-0000-000000000001
   APP_ENV=development
   ```

> [!NOTE]
> In `development` mode with placeholder credentials, the application automatically launches in **Development Mock Mode** with pre-seeded test data, allowing immediate testing of phone OTP (`123456`), financial flows, and multilingual interfaces without waiting for network or SMS services.

---

### 3. Database Migration & Schema Setup

#### Option A: Supabase Cloud Dashboard
1. Open your project on [database.new](https://database.new) or [supabase.com](https://supabase.com).
2. Go to the **SQL Editor** tab.
3. Open and run `supabase/migrations/20261101_000001_initial_schema.sql` (Creates 11 tables, constraints, triggers, and views).
4. Run `supabase/migrations/20261101_000002_rls_and_audit.sql` (Enables Row Level Security and automatic audit triggers).
5. Run `supabase/seed.sql` to populate sample society details, active members, initial funds, and upcoming festivals.

#### Option B: Supabase CLI (Local Development)
```bash
# Initialize local Supabase instance
npx supabase start

# Apply migrations
npx supabase db reset
```

---

### 4. Supabase Auth Configuration (Phone OTP)
1. In the Supabase Dashboard, navigate to **Authentication** -> **Providers** -> **Phone**.
2. Enable the **Phone** provider.
3. Select an SMS Provider (e.g. Twilio, MessageBird, Textlocal, or Supabase default test numbers).
4. Under **Phone Auth**, configure testing phone numbers for immediate development:
   - Phone: `+919825000001`, OTP: `123456` (Active Member)
   - Phone: `+919825000004`, OTP: `123456` (Pending User)

---

### 5. Running the Application

#### 5.1 Fetch Dependencies
```bash
flutter pub get
```

#### 5.2 Run on Responsive Web
```bash
flutter run -d chrome --dart-define-from-file=.env
```

#### 5.3 Run on Android
```bash
flutter run -d android --dart-define-from-file=.env
```

---

### 6. Executing Automated Tests
To run the full suite of financial scenarios, localization checks, and security tests:
```bash
# Run Dart unit tests
flutter test

# Run cross-scenario verification runner
python scratch/run_all_tests.py
```
