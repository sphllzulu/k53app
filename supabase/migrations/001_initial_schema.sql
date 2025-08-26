-- K53 App Initial Database Schema
-- Created: 2025-08-25
-- Description: Initial schema setup with tables and RLS policies

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Core user profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    handle TEXT UNIQUE,
    learner_code INTEGER CHECK (learner_code IN (1, 2, 3)),
    locale TEXT DEFAULT 'en',
    study_goal_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Question bank table
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    learner_code INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_index INTEGER NOT NULL,
    explanation TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Study sessions table
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    mode TEXT NOT NULL CHECK (mode IN ('study', 'mock_exam')),
    category TEXT,
    total_questions INTEGER,
    score INTEGER,
    time_spent_seconds INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Answer tracking table
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

-- Gamification badges table
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    badge_key TEXT NOT NULL,
    badge_name TEXT NOT NULL,
    badge_description TEXT,
    awarded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_key)
);

-- User achievements table
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_key TEXT NOT NULL,
    achievement_name TEXT NOT NULL,
    achievement_description TEXT,
    progress INTEGER DEFAULT 0,
    target INTEGER DEFAULT 100,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_key)
);

-- Referral tracking table
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_user_id UUID REFERENCES profiles(id),
    referred_email TEXT,
    medium TEXT,
    campaign TEXT,
    referral_code TEXT,
    clicked_at TIMESTAMPTZ,
    installed_at TIMESTAMPTZ,
    signed_up_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User settings/preferences table
CREATE TABLE user_settings (
    id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    sound_effects BOOLEAN DEFAULT TRUE,
    vibration_feedback BOOLEAN DEFAULT TRUE,
    daily_reminder_enabled BOOLEAN DEFAULT FALSE,
    daily_reminder_time TIME DEFAULT '20:00:00',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Question reports from users
CREATE TABLE question_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    reporter_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL CHECK (reason IN (
        'incorrect_answer',
        'confusing_question',
        'multiple_correct',
        'outdated_info',
        'other'
    )),
    comment TEXT,
    session_id UUID REFERENCES sessions(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prevent duplicate reports
CREATE UNIQUE INDEX unique_user_question_report
ON question_reports(reporter_user_id, question_id);

-- Automated and manual flags for admin QA
CREATE TABLE question_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    flag_type TEXT NOT NULL CHECK (flag_type IN (
        'low_success_rate',
        'high_report_rate',
        'statistical_anomaly',
        'manual_review',
        'content_audit'
    )),
    severity TEXT DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    details JSONB,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_review', 'resolved', 'dismissed')),
    auto_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES profiles(id)
);

-- QA actions and audit trail
CREATE TABLE qa_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    flag_id UUID REFERENCES question_flags(id) ON DELETE CASCADE,
    reviewer_user_id UUID REFERENCES profiles(id),
    action_type TEXT NOT NULL CHECK (action_type IN (
        'flag_created',
        'under_review',
        'question_edited',
        'question_removed',
        'flag_resolved',
        'flag_dismissed',
        'escalated'
    )),
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content quality metrics
CREATE TABLE question_quality_metrics (
    question_id UUID PRIMARY KEY REFERENCES questions(id) ON DELETE CASCADE,
    total_attempts INTEGER DEFAULT 0,
    correct_attempts INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2),
    report_count INTEGER DEFAULT 0,
    avg_time_to_answer INTEGER,
    quality_score DECIMAL(3,2),
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_learner_code ON questions(learner_code);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_mode ON sessions(mode);
CREATE INDEX idx_answers_session_id ON answers(session_id);
CREATE INDEX idx_answers_question_id ON answers(question_id);
CREATE INDEX idx_badges_user_id ON badges(user_id);
CREATE INDEX idx_achievements_user_id ON achievements(user_id);
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_user_id);
CREATE INDEX idx_question_reports_question_id ON question_reports(question_id);
CREATE INDEX idx_question_reports_user_id ON question_reports(reporter_user_id);
CREATE INDEX idx_question_reports_created_at ON question_reports(created_at);
CREATE INDEX idx_question_flags_question_id ON question_flags(question_id);
CREATE INDEX idx_question_flags_status ON question_flags(status);
CREATE INDEX idx_question_flags_severity ON question_flags(severity);
CREATE INDEX idx_qa_actions_question_id ON qa_actions(question_id);
CREATE INDEX idx_qa_actions_reviewer_id ON qa_actions(reviewer_user_id);
CREATE INDEX idx_quality_metrics_question_id ON question_quality_metrics(question_id);

-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_quality_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Questions policies (read-only for authenticated users)
CREATE POLICY "Authenticated users can read questions" ON questions
    FOR SELECT USING (auth.role() = 'authenticated' AND is_active = true);

-- Sessions policies
CREATE POLICY "Users can view own sessions" ON sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON sessions
    FOR UPDATE USING (auth.uid() = user_id);

-- Answers policies
CREATE POLICY "Users can view own answers" ON answers
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM sessions WHERE sessions.id = answers.session_id
        )
    );

CREATE POLICY "Users can insert own answers" ON answers
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM sessions WHERE sessions.id = answers.session_id
        )
    );

-- Badges policies
CREATE POLICY "Users can view own badges" ON badges
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own badges" ON badges
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Achievements policies
CREATE POLICY "Users can view own achievements" ON achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements" ON achievements
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" ON achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Referrals policies
CREATE POLICY "Users can view own referrals" ON referrals
    FOR SELECT USING (auth.uid() = referrer_user_id);

CREATE POLICY "Users can insert own referrals" ON referrals
    FOR INSERT WITH CHECK (auth.uid() = referrer_user_id);

-- User settings policies
CREATE POLICY "Users can view own settings" ON user_settings
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own settings" ON user_settings
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own settings" ON user_settings
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Question reports policies
CREATE POLICY "Users can create own reports" ON question_reports
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = reporter_user_id);

CREATE POLICY "Users can view own reports" ON question_reports
    FOR SELECT TO authenticated
    USING (auth.uid() = reporter_user_id);

-- Add role column to profiles table for admin access
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'qa_reviewer'));

-- Admin QA policies
CREATE POLICY "qa_flags_admin_access" ON question_flags
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "qa_actions_admin_access" ON qa_actions
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "quality_metrics_admin_access" ON question_quality_metrics
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Create function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, handle, learner_code, locale)
    VALUES (
        NEW.id,
        'user_' || substr(NEW.id::text, 1, 8),
        1,
        'en'
    )
    ON CONFLICT (id) DO NOTHING;
    
    INSERT INTO public.user_settings (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at
    BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_achievements_updated_at
    BEFORE UPDATE ON achievements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample questions (10 for each category)
INSERT INTO questions (category, learner_code, question_text, options, correct_index, explanation) VALUES
-- Rules of the Road (10 questions)
('rules_of_road', 1, 'What does a solid white line across the road indicate?',
 '[{"text": "Stop here for traffic lights"}, {"text": "Stop here for stop sign"}, {"text": "Yield to oncoming traffic"}, {"text": "No stopping allowed"}]',
 1, 'A solid white line across the road indicates where you must stop for a stop sign or traffic light.'),

('rules_of_road', 1, 'When approaching a yield sign, what should you do?',
 '[{"text": "Come to a complete stop"}, {"text": "Slow down and be prepared to stop"}, {"text": "Speed up to merge quickly"}, {"text": "Ignore if no traffic is visible"}]',
 1, 'A yield sign requires you to slow down and be prepared to stop if necessary to let other traffic proceed.'),

('rules_of_road', 1, 'What is the minimum following distance you should maintain behind another vehicle?',
 '[{"text": "1 second"}, {"text": "2 seconds"}, {"text": "3 seconds"}, {"text": "5 seconds"}]',
 2, 'Maintain at least a 3-second following distance to allow adequate reaction time in case of sudden stops.'),

('rules_of_road', 1, 'When may you overtake another vehicle on the left?',
 '[{"text": "Never"}, {"text": "When the vehicle is turning right"}, {"text": "When the vehicle is slowing down"}, {"text": "Only on highways"}]',
 1, 'You may overtake on the left when the vehicle in front is turning right or when lanes are marked for passing.'),

('rules_of_road', 1, 'What does a flashing yellow traffic light mean?',
 '[{"text": "Stop immediately"}, {"text": "Proceed with caution"}, {"text": "Speed up to clear intersection"}, {"text": "Prepare to stop"}]',
 1, 'A flashing yellow light means proceed with caution - be prepared to stop if necessary.'),

('rules_of_road', 1, 'When must you use your headlights?',
 '[{"text": "Only at night"}, {"text": "When visibility is less than 150m"}, {"text": "Only in rain"}, {"text": "Only on highways"}]',
 1, 'You must use headlights when visibility is less than 150 meters, at night, or in adverse weather conditions.'),

('rules_of_road', 1, 'What is the speed limit in urban areas unless otherwise indicated?',
 '[{"text": "40 km/h"}, {"text": "60 km/h"}, {"text": "80 km/h"}, {"text": "100 km/h"}]',
 1, 'The default speed limit in urban areas is 60 km/h unless otherwise posted.'),

('rules_of_road', 1, 'When approaching a pedestrian crossing, what should you do?',
 '[{"text": "Speed up to cross quickly"}, {"text": "Slow down and be prepared to stop"}, {"text": "Sound your horn"}, {"text": "Ignore if no pedestrians"}]',
 1, 'Always slow down and be prepared to stop for pedestrians at crossings.'),

('rules_of_road', 1, 'What does a circular red traffic light mean?',
 '[{"text": "Proceed with caution"}, {"text": "Stop and wait for green"}, {"text": "Turn right only"}, {"text": "Slow down"}]',
 1, 'A circular red light means you must come to a complete stop and wait for it to turn green.'),

('rules_of_road', 1, 'When may you drive in the right-hand lane of a freeway?',
 '[{"text": "Never"}, {"text": "Only when overtaking"}, {"text": "At any time"}, {"text": "Only during daylight"}]',
 1, 'On freeways, the right-hand lane is generally for overtaking only unless otherwise indicated.'),

-- Road Signs (10 questions)
('road_signs', 1, 'What does a triangular sign with a red border indicate?',
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Information"}, {"text": "Direction"}]',
 0, 'Triangular signs with red borders are warning signs that alert drivers to potential hazards ahead.'),

('road_signs', 1, 'What does a circular sign with a red border indicate?',
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Information"}, {"text": "Direction"}]',
 1, 'Circular signs with red borders indicate prohibitions - things you must not do.'),

('road_signs', 1, 'What does a blue circular sign indicate?',
 '[{"text": "Warning"}, {"text": "Mandatory instruction"}, {"text": "Information"}, {"text": "Prohibition"}]',
 1, 'Blue circular signs indicate mandatory instructions - things you must do.'),

('road_signs', 1, 'What does a rectangular blue sign indicate?',
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Information"}, {"text": "Mandatory"}]',
 2, 'Rectangular blue signs provide information to drivers.'),

('road_signs', 1, 'What does a yellow diamond-shaped sign indicate?',
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Information"}, {"text": "Direction"}]',
 0, 'Yellow diamond-shaped signs are warning signs that alert to potential hazards.'),

('road_signs', 1, 'What does a sign with a red circle and diagonal bar indicate?',
 '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Information"}, {"text": "Mandatory"}]',
 1, 'A red circle with a diagonal bar indicates that something is prohibited.'),

('road_signs', 1, 'What does a sign with a white "P" on blue background indicate?',
 '[{"text": "No parking"}, {"text": "Parking area"}, {"text": "Pedestrian crossing"}, {"text": "Police station"}]',
 1, 'A white "P" on blue background indicates a parking area.'),

('road_signs', 1, 'What does a sign with a pedestrian symbol indicate?',
 '[{"text": "No pedestrians"}, {"text": "Pedestrian crossing"}, {"text": "School zone"}, {"text": "Walking path"}]',
 1, 'A pedestrian symbol indicates a pedestrian crossing ahead.'),

('road_signs', 1, 'What does a sign with a bicycle symbol indicate?',
 '[{"text": "No bicycles"}, {"text": "Bicycle path"}, {"text": "Bicycle crossing"}, {"text": "Bicycle shop"}]',
 1, 'A bicycle symbol indicates a bicycle path or crossing.'),

('road_signs', 1, 'What does a sign with a red triangle and exclamation mark indicate?',
 '[{"text": "Danger ahead"}, {"text": "No entry"}, {"text": "Hospital"}, {"text": "Construction"}]',
 0, 'A red triangle with exclamation mark is a general warning sign for danger ahead.'),

-- Vehicle Controls (10 questions)
('vehicle_controls', 1, 'When should you use your hazard lights?',
 '[{"text": "When driving in heavy rain"}, {"text": "When your vehicle has broken down"}, {"text": "When overtaking"}, {"text": "When parking illegally"}]',
 1, 'Hazard lights should be used when your vehicle has broken down or is obstructing traffic to warn other road users.'),

('vehicle_controls', 1, 'What does the anti-lock braking system (ABS) help prevent?',
 '[{"text": "Engine overheating"}, {"text": "Wheel lock-up during braking"}, {"text": "Tire wear"}, {"text": "Fuel consumption"}]',
 1, 'ABS prevents wheel lock-up during hard braking, helping maintain steering control.'),

('vehicle_controls', 1, 'When should you use your high beam headlights?',
 '[{"text": "In urban areas"}, {"text": "On well-lit roads"}, {"text": "On dark rural roads"}, {"text": "In fog"}]',
 2, 'Use high beams on dark rural roads where there is no oncoming traffic.'),

('vehicle_controls', 1, 'What is the purpose of the handbrake?',
 '[{"text": "For emergency stops"}, {"text": "To park the vehicle securely"}, {"text": "To help with hill starts"}, {"text": "To improve fuel economy"}]',
 1, 'The handbrake is primarily used to secure the vehicle when parked, especially on slopes.'),

('vehicle_controls', 1, 'When should you check your tire pressure?',
 '[{"text": "Only when tires look flat"}, {"text": "When tires are cold"}, {"text": "After long drives"}, {"text": "Only at service stations"}]',
 1, 'Check tire pressure when tires are cold for accurate readings, as heat from driving increases pressure.'),

('vehicle_controls', 1, 'What does the temperature gauge indicate?',
 '[{"text": "Outside air temperature"}, {"text": "Engine coolant temperature"}, {"text": "Oil temperature"}, {"text": "Cabin temperature"}]',
 1, 'The temperature gauge shows the engine coolant temperature to help prevent overheating.'),

('vehicle_controls', 1, 'When should you use your indicators?',
 '[{"text": "Only when turning"}, {"text": "When changing lanes or turning"}, {"text": "Only in heavy traffic"}, {"text": "When overtaking"}]',
 1, 'Use indicators when changing direction, changing lanes, or turning to signal your intentions to other road users.'),

('vehicle_controls', 1, 'What is the purpose of the rearview mirror?',
 '[{"text": "To check your appearance"}, {"text": "To monitor traffic behind you"}, {"text": "To see blind spots"}, {"text": "For parking only"}]',
 1, 'The rearview mirror helps you monitor traffic conditions behind your vehicle.'),

('vehicle_controls', 1, 'When should you use your windscreen wipers?',
 '[{"text": "Only in heavy rain"}, {"text": "When visibility is impaired by rain, snow, or spray"}, {"text": "To clean the windscreen"}, {"text": "Only during daytime"}]',
 1, 'Use windscreen wipers whenever visibility is impaired by rain, snow, or spray from other vehicles.'),

('vehicle_controls', 1, 'What does the fuel gauge indicate?',
 '[{"text": "Fuel consumption rate"}, {"text": "Remaining fuel in tank"}, {"text": "Fuel quality"}, {"text": "Distance to empty"}]',
 1, 'The fuel gauge shows the amount of fuel remaining in the vehicle''s tank.');

-- Create admin role for content management (optional)
-- Note: This would be set up in the Supabase dashboard with appropriate permissions