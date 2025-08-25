# K53 Learner's License Simulation App

A production-ready Flutter application for K53 learner's license simulation and preparation.

## 🚀 Features

- **Authentication**: Secure Supabase authentication with email verification
- **Study Mode**: Interactive question learning with explanations
- **Mock Exams**: Timed exam simulations with scoring
- **Progress Tracking**: Analytics and performance monitoring
- **Gamification**: Badges, achievements, and progress rewards
- **WhatsApp Sharing**: Progress sharing with referral tracking
- **Accessibility**: Full TalkBack/screen reader support

## 🛠️ Tech Stack

- **Flutter**: Latest stable version with Android 10+ support
- **Riverpod**: State management with providers
- **Supabase**: Backend with PostgreSQL, Auth, and RLS
- **GoRouter**: Navigation and deep linking
- **flutter_dotenv**: Environment configuration

## 📋 Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extension
- Supabase account for backend services

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd k53app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create a `.env` file in the root directory with your Supabase credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_public_anon_key_here

# App Configuration
ENVIRONMENT=development
ENABLE_ANALYTICS=true
APP_NAME=K53 Learner's License
APP_VERSION=1.0.0

# Feature Flags
ENABLE_GAMIFICATION=true
ENABLE_SHARING=true
ENABLE_OFFLINE_MODE=true
```

### 4. Supabase Setup

1. Create a new project at [Supabase](https://supabase.com)
2. Get your project URL and anon key from Settings > API
3. Update the `.env` file with your credentials
4. Run the database schema migrations (see Database Setup below)

### 5. Database Deployment

Before running the application, you need to deploy the database schema:

1. **Create Supabase Project**: Go to [Supabase](https://supabase.com) and create a new project
2. **Update Environment**: Set your Supabase credentials in `.env` file
3. **Run Migration**: Execute the SQL migration from `supabase/migrations/001_initial_schema.sql` in the Supabase SQL Editor

Detailed deployment instructions: [supabase/README_DEPLOYMENT.md](supabase/README_DEPLOYMENT.md)

### 6. Run the Application

```bash
# For development
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## 🗄️ Database Setup

### Required Tables

Run these SQL commands in your Supabase SQL editor:

```sql
-- Core user data
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    handle TEXT UNIQUE,
    learner_code INTEGER CHECK (learner_code IN (1,2,3)),
    locale TEXT DEFAULT 'en',
    study_goal_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Question bank
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    learner_code INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_index INTEGER NOT NULL,
    explanation TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Study sessions
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    mode TEXT CHECK (mode IN ('study', 'mock_exam')),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    score INTEGER,
    total_questions INTEGER,
    time_spent_seconds INTEGER
);

-- Answer tracking
CREATE TABLE answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id),
    chosen_index INTEGER,
    is_correct BOOLEAN,
    elapsed_ms INTEGER,
    hints_used INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Gamification
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    badge_key TEXT NOT NULL,
    awarded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_key)
);

-- Referral tracking
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_user_id UUID REFERENCES profiles(id),
    medium TEXT,
    campaign TEXT,
    referral_code TEXT,
    clicked_at TIMESTAMPTZ,
    installed_at TIMESTAMPTZ
);
```

### Row-Level Security (RLS) Policies

Enable RLS on all tables and create appropriate policies:

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Questions policies (read-only for authenticated users)
CREATE POLICY "Authenticated users can read questions" ON questions
    FOR SELECT USING (auth.role() = 'authenticated');

-- Sessions policies
CREATE POLICY "Users can view own sessions" ON sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Similar policies for answers, badges, and referrals
```

## 🧪 Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

## 📦 Build Artifacts

The project generates:
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`

## 🔒 Security

- No client-side secrets (all sensitive data server-side)
- Row-Level Security (RLS) policies for data isolation
- Secure token handling with automatic refresh
- Input validation and sanitization

## 📊 Analytics & Monitoring

- Custom event tracking (no third-party SDKs)
- Session and answer telemetry
- Performance monitoring
- Error reporting

## 🤝 Contributing

1. Follow the existing code style and architecture
2. Write tests for new features
3. Update documentation accordingly
4. Ensure all tests pass before submitting

## 📄 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For technical issues or questions, please contact the development team.

---

**Delivery Date**: Thursday, August 28, 2025
