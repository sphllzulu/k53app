-- Migration to allow question seeding while maintaining RLS
-- This adds a policy that allows inserting questions for seeding purposes

-- Create a policy that allows inserting questions (for seeding)
CREATE POLICY "Allow question seeding" ON questions
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Note: This policy allows any authenticated user to insert questions
-- For production, you might want to restrict this to specific roles or users
-- For example, you could check if the user has a specific role:
-- WITH CHECK (
--     EXISTS (
--         SELECT 1 FROM profiles 
--         WHERE id = auth.uid() 
--         AND role IN ('admin', 'content_manager')
--     )
-- );