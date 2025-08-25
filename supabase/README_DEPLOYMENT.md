# Database Schema Deployment Guide

## Prerequisites

1. **Supabase Account**: Create an account at [supabase.com](https://supabase.com)
2. **Supabase Project**: Create a new project in your Supabase dashboard
3. **Project Credentials**: Get your project URL and anon key from Settings > API

## Deployment Steps

### 1. Environment Setup

Update your `.env` file with your Supabase credentials:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key-here
```

### 2. Database Migration

#### Option A: Using Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the sidebar
3. Copy the entire content of `supabase/migrations/001_initial_schema.sql`
4. Paste into the SQL editor and click **Run**
5. Verify all tables were created successfully

#### Option B: Using Supabase CLI

1. Install the Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. Run the migration:
   ```bash
   supabase db push
   ```

### 3. Verify Deployment

After running the migration, verify the following:

1. **Tables Created**: Check that all tables appear in the **Table Editor**
   - profiles
   - questions
   - sessions
   - answers
   - badges
   - achievements
   - referrals
   - user_settings

2. **RLS Enabled**: Confirm Row-Level Security is enabled on all tables
   - Go to **Authentication** > **Policies**
   - Verify policies are in place for each table

3. **Triggers Created**: Check that triggers are working
   - `on_auth_user_created` trigger for automatic profile creation
   - `update_updated_at_column` triggers for timestamp updates

### 4. Initial Data Setup

#### Insert Sample Questions

Run the sample questions insert at the end of the migration file, or add more questions:

```sql
-- Add more sample questions as needed
INSERT INTO questions (category, learner_code, question_text, options, correct_index, explanation) VALUES
('rules_of_road', 1, 'What should you do when approaching a yellow traffic light?', 
 '[{"text": "Speed up to beat the light"}, {"text": "Stop if safe to do so"}, {"text": "Continue at same speed"}, {"text": "Sound your horn"}]', 
 1, 'A yellow light means prepare to stop. Stop if you can do so safely.'),
 
('road_signs', 1, 'What does a circular sign with a red border and white background indicate?', 
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Direction"}, {"text": "Information"}]', 
 1, 'Circular signs with red borders indicate prohibitions - things you must not do.');
```

### 5. Testing the Setup

#### Test Authentication
1. Run the app
2. Try to sign up with a new email
3. Verify that a user profile is automatically created
4. Check the `profiles` table for the new user

#### Test RLS Policies
1. Create two test users
2. Login with first user and create some data
3. Login with second user and verify they cannot access first user's data

#### Test Question Access
1. Login with any user
2. Verify questions can be read from the `questions` table
3. Verify only active questions are returned

### 6. Production Considerations

#### Environment Variables
Ensure your production environment has:
- Correct Supabase URL and anon key
- `ENVIRONMENT=production` setting
- Proper security configurations

#### Database Backups
- Set up automatic backups in Supabase dashboard
- Consider point-in-time recovery for production

#### Monitoring
- Set up logging and monitoring
- Use Supabase's built-in analytics
- Monitor RLS policy performance

### 7. Troubleshooting

#### Common Issues

1. **Permission Errors**: 
   - Verify RLS policies are correctly applied
   - Check that the `auth.users` table exists and has data

2. **Trigger Issues**:
   - Verify the `handle_new_user` function exists
   - Check trigger execution on user creation

3. **Connection Issues**:
   - Verify Supabase URL and anon key in `.env`
   - Check network connectivity

4. **Schema Errors**:
   - Run the migration in sequence
   - Drop tables and recreate if needed

### 8. Next Steps

After successful deployment:

1. **Add More Questions**: Populate the question bank with 400+ questions
2. **Test Features**: Verify all app features work with the live database
3. **Performance Testing**: Test with multiple concurrent users
4. **Security Audit**: Review RLS policies and access patterns

## Support

If you encounter issues during deployment:

1. Check the Supabase documentation
2. Review error messages in the SQL editor
3. Verify all environment variables are set correctly
4. Ensure your Supabase project is properly configured