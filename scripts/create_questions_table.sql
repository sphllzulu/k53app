-- Create the questions table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL CHECK (category IN ('rules_of_road', 'road_signs', 'vehicle_controls')),
    learner_code INTEGER NOT NULL CHECK (learner_code BETWEEN 1 AND 3),
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_index INTEGER NOT NULL CHECK (correct_index BETWEEN 0 AND 3),
    explanation TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    difficulty_level INTEGER NOT NULL CHECK (difficulty_level BETWEEN 1 AND 3),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Add indexes for better performance
    CONSTRAINT unique_question_text UNIQUE (question_text)
);

-- Create indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_questions_category ON public.questions(category);
CREATE INDEX IF NOT EXISTS idx_questions_learner_code ON public.questions(learner_code);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON public.questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_questions_active ON public.questions(is_active);

-- Add comment to table
COMMENT ON TABLE public.questions IS 'Stores K53 learner license exam questions';

-- Add comments to columns
COMMENT ON COLUMN public.questions.category IS 'Question category: rules_of_road, road_signs, or vehicle_controls';
COMMENT ON COLUMN public.questions.learner_code IS 'Learner code: 1 (Motorcycles), 2 (Light Vehicles), 3 (Heavy Vehicles)';
COMMENT ON COLUMN public.questions.options IS 'JSON array of answer options, e.g., [{"text": "Option 1"}, {"text": "Option 2"}]';
COMMENT ON COLUMN public.questions.correct_index IS 'Index of the correct answer (0-based)';
COMMENT ON COLUMN public.questions.difficulty_level IS 'Difficulty level: 1 (Easy), 2 (Medium), 3 (Hard)';

-- Enable Row Level Security (RLS) but create a policy that allows all operations for now
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows all operations (we can restrict this later)
CREATE POLICY "Allow all operations on questions" ON public.questions
FOR ALL USING (true);

-- Confirm table creation
SELECT 'Table public.questions created successfully' AS result;