# Production Deployment & Build Guide
## Bajrang Residential Society Fund Management System

### 1. Android Release Build

#### 1.1 Keystore Setup
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

#### 1.2 Build Release APK
```bash
flutter build apk --release --dart-define=SUPABASE_URL=https://your-production.supabase.co --dart-define=SUPABASE_ANON_KEY=your_production_anon_key
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### 1.3 Build Android App Bundle (AAB for Google Play / Internal Distribution)
```bash
flutter build appbundle --release --dart-define=SUPABASE_URL=https://your-production.supabase.co --dart-define=SUPABASE_ANON_KEY=your_production_anon_key
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

### 2. Responsive Web Production Build

#### 2.1 Compile Web Artifacts
```bash
flutter build web --release --web-renderer canvaskit --dart-define=SUPABASE_URL=https://your-production.supabase.co --dart-define=SUPABASE_ANON_KEY=your_production_anon_key
```
Output: `build/web/`

#### 2.2 Deploying to Hosting Providers

##### Option A: Deploy to Supabase Storage / Netlify
```bash
# Using Netlify CLI
npx netlify-cli deploy --prod --dir=build/web
```

##### Option B: Deploy to Vercel
Create `vercel.json` in the project root:
```json
{
  "outputDirectory": "build/web",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```
Run:
```bash
npx vercel --prod
```

##### Option C: Deploy to GitHub Pages or Custom Web Server (Nginx / Apache)
Ensure your web server redirects all sub-routes to `index.html` to support GoRouter client-side routing.
Nginx configuration:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

### 3. Production Readiness Checklist
- [x] All 11 PostgreSQL tables created with constraints and foreign keys.
- [x] Row Level Security (RLS) active on all 11 tables.
- [x] Service-role key removed from all client code.
- [x] Database views `vw_fund_balances` and `vw_society_financial_summary` verified.
- [x] Storage buckets created with authenticated member upload policies.
- [x] SMS Provider configured for live OTP delivery.
- [x] Multi-lingual ARB files tested for English, Gujarati, and Hindi.
- [x] Automated test scenarios 1-7 passed.
