# K53 App QA Flagging System Guide

## Overview

The QA Flagging System is a comprehensive quality assurance tool that allows users to report issues with questions and provides administrators with tools to manage and analyze content quality.

## Features

### User Features
- **Question Reporting**: Users can flag questions for various issues
- **Multiple Report Reasons**: 
  - Incorrect answer
  - Poor explanation
  - Typo/grammar error
  - Outdated information
  - Other issues
- **Severity Levels**: Critical, High, Medium, Low
- **Anonymous Reporting**: Users can report without creating an account

### Admin Features
- **Dashboard Overview**: Real-time metrics and analytics
- **Flag Management**: View and manage all flagged questions
- **Analytics**: Content quality metrics and performance tracking
- **Action Tracking**: Log administrative actions and resolutions

## Database Schema

### Core Tables

#### `question_flags`
```sql
CREATE TABLE question_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  severity TEXT CHECK (severity IN ('critical', 'high', 'medium', 'low')),
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_review', 'resolved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `question_reports`
```sql
CREATE TABLE question_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  flag_id UUID REFERENCES question_flags(id) ON DELETE CASCADE,
  reason TEXT CHECK (reason IN ('incorrect_answer', 'poor_explanation', 'typo', 'outdated', 'other')),
  description TEXT,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `qa_actions`
```sql
CREATE TABLE qa_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_id UUID REFERENCES question_flags(id) ON DELETE CASCADE,
  action_type TEXT CHECK (action_type IN ('review', 'edit', 'disable', 'delete', 'other')),
  description TEXT,
  admin_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `question_quality_metrics`
```sql
CREATE TABLE question_quality_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE UNIQUE,
  success_rate DECIMAL(5,2) DEFAULT 0,
  quality_score DECIMAL(5,2) DEFAULT 0,
  flag_count INTEGER DEFAULT 0,
  last_reviewed TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## API Endpoints

### User Endpoints

#### Report a Question
```dart
Future<bool> reportQuestion({
  required String questionId,
  required String reason,
  String? description,
  String severity = 'medium',
})
```

### Admin Endpoints

#### Get Flagged Questions
```dart
Future<List<Map<String, dynamic>>> getFlaggedQuestions({
  String? severity,
  String? status = 'open',
  int limit = 50,
})
```

#### Get QA Analytics
```dart
Future<Map<String, dynamic>> getQAAnalytics()
```

#### Update Flag Status
```dart
Future<bool> updateFlagStatus(String flagId, String status)
```

#### Create QA Action
```dart
Future<bool> createQAAction({
  required String flagId,
  required String actionType,
  required String description,
})
```

## Setup Instructions

### 1. Database Migration
Run the SQL migration script to create the necessary tables:
```bash
supabase migration up
```

### 2. RLS Policies
Ensure Row Level Security policies are properly configured for data protection.

### 3. Environment Configuration
Verify Supabase environment variables are set in `.env`:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Usage Examples

### User Reporting
```dart
// Report a question with incorrect answer
final success = await QAService.reportQuestion(
  questionId: 'question-123',
  reason: 'incorrect_answer',
  description: 'Option C is marked correct but should be Option B',
  severity: 'high',
);
```

### Admin Dashboard
```dart
// Get flagged questions
final flaggedQuestions = await AdminQAService.getFlaggedQuestions(
  severity: 'critical',
  status: 'open',
);

// Get analytics
final analytics = await AdminQAService.getQAAnalytics();
```

## Testing

### Integration Test
Run the integration test to verify system functionality:
```bash
dart test_qa_integration.dart
```

### Manual Testing
1. Login as admin user
2. Navigate to Admin Dashboard
3. Test each tab functionality:
   - QA Overview: Check metrics display
   - Flagged Questions: Verify question listing
   - Analytics: Review quality metrics

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify Supabase URL and API key
   - Check network connectivity

2. **Permission Denied Errors**
   - Verify RLS policies are correctly configured
   - Check user roles and permissions

3. **Empty Dashboard**
   - Ensure test data exists in the database
   - Verify question flags have been created

### Debug Mode
Enable debug logging in the AdminQAService for detailed error information.

## Performance Considerations

- Large datasets may require pagination for flagged questions
- Analytics queries should be optimized for performance
- Consider caching for frequently accessed data

## Security

- All user data is protected by RLS policies
- Admin endpoints require proper authentication
- Sensitive operations are logged for audit purposes

## Support

For issues with the QA Flagging System, contact the development team or check the application logs for detailed error information.