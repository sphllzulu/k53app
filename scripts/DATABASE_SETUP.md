# K53 App Database Setup Guide

## Overview

This guide covers the database setup and seeding process for the K53 Learner's License App. We've streamlined the process to use Dart-based seeding instead of multiple SQL scripts.

## Database Structure

The database uses Supabase with the following main tables:

- **questions** - Stores all K53 exam questions
- **profiles** - User profiles and progress
- **sessions** - Study and exam sessions
- **answers** - User answer tracking
- **achievements** - Gamification achievements

## Setup Process

### 1. Database Migrations

Apply the database schema migrations:

```bash
# Apply initial schema
supabase db reset

# Or apply migrations manually through Supabase SQL editor
```

Migrations are located in `supabase/migrations/`:
- `001_initial_schema.sql` - Main database schema
- `002_remove_level_fields.sql` - Removed level-based progression
- `003_allow_question_seeding.sql` - Allows question insertion while maintaining RLS

### 2. Environment Configuration

Create/update your `.env` file with Supabase credentials:

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### 3. Seeding Questions

We provide two seeding options:

#### Option A: Basic Seeder (9 questions)
```bash
dart run scripts/seed_k53_questions.dart
```

#### Option B: Comprehensive Seeder (152+ questions)
```bash
dart run scripts/seed_comprehensive_k53.dart
```

### 4. Verify Setup

Check that questions were inserted correctly:

```sql
SELECT COUNT(*) as total_questions FROM questions;
SELECT category, COUNT(*) FROM questions GROUP BY category;
```

## Seeding Scripts

### scripts/seed_k53_questions.dart
- Basic seeder with 9 sample questions
- Good for testing and development
- Covers all 3 categories and learner codes

### scripts/seed_comprehensive_k53.dart
- Comprehensive seeder with official Evolve Driving Academy questions
- Includes Rules of the Road, Road Signs, and Vehicle Controls
- Full coverage for production use

### Additional SQL Seeders

#### scripts/seed_evolve_questions_simple.sql
- Official Evolve Driving Academy questions (27 essential questions)
- Ready-to-run SQL script for Supabase SQL Editor
- Includes both Rules of the Road and Vehicle Controls

#### scripts/seed_evolve_questions.sql
- Complete Evolve Driving Academy question set (72+ questions)
- Comprehensive coverage of all question categories

## Cleanup

Remove redundant scripts after setup:

```bash
dart run scripts/cleanup_redundant_scripts.dart
```

This removes:
- Multiple SQL seed files with overlapping content
- JavaScript-based seeding scripts
- Legacy migration files

## Troubleshooting

### Common Issues

1. **RLS (Row Level Security) Errors**
   - Ensure RLS is disabled for the questions table during seeding
   - Or use service role key instead of anon key

2. **Connection Issues**
   - Verify Supabase URL and keys in `.env` file
   - Check internet connection

3. **Duplicate Questions**
   - The scripts include duplicate prevention logic
   - Questions are only inserted if they don't already exist

### Reset Database

To start fresh:

```bash
# Reset entire database
supabase db reset

# Or truncate questions table
TRUNCATE TABLE questions CASCADE;
```

## Maintenance

### Adding New Questions

1. Add questions to the appropriate function in `seed_comprehensive_k53.dart`
2. Follow the existing question format
3. Include proper explanations and difficulty levels

### Updating Questions

1. Questions are versioned with a `version` field
2. To update a question, increment the version number
3. The seeding script will insert new versions while keeping old ones

## Best Practices

1. **Backup First** - Always backup your database before major changes
2. **Test Locally** - Test seeding on a local/development database first
3. **Monitor Performance** - Large inserts may take time, monitor Supabase metrics
4. **Version Control** - Keep migrations and seed scripts in version control

## Support

For database-related issues, check:
- Supabase dashboard for query performance
- Application logs for seeding errors
- Database connection settings in `.env`