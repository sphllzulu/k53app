-- SQL script to create admin user and set proper role
-- Run this in your Supabase SQL editor after creating the user through authentication

-- First, create the user through Supabase authentication UI with:
-- Email: admin@example.com
-- Password: admin123

-- Then run this SQL to update their role:

-- Update the user's role to admin
UPDATE profiles 
SET role = 'admin'
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@example.com'
);

-- Verify the update worked
SELECT id, email, role 
FROM profiles 
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@example.com'
);

-- Alternative: If you need to create the user programmatically:
-- Note: This requires enabling the auth admin API or using the Supabase dashboard

-- Method 1: Use Supabase dashboard to create user, then update role with above SQL

-- Method 2: Use the auth.admin API (requires service role key)
/*
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

// Create user
const { data: user, error } = await supabase.auth.admin.createUser({
  email: 'admin@example.com',
  password: 'admin123',
  email_confirm: true,
})

// Update profile role
if (user) {
  await supabase
    .from('profiles')
    .update({ role: 'admin' })
    .eq('id', user.id)
}
*/

-- For immediate testing, you can also manually set any existing user as admin:
-- UPDATE profiles SET role = 'admin' WHERE id = 'your-user-id-here';