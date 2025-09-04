-- Migration to remove level-related fields from profiles table
-- This migration removes the level-based progression system

-- Remove level-related columns from profiles table
ALTER TABLE profiles 
DROP COLUMN IF EXISTS mock_exam_level,
DROP COLUMN IF EXISTS has_completed_level1;

-- Update the handle_new_user function to remove level references
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

-- Note: This migration should be run after ensuring the application code
-- has been updated to remove all level-based functionality