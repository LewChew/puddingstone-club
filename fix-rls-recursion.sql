-- Fix infinite recursion in user_profiles RLS policies
-- Run this in your Supabase SQL Editor

-- Drop all existing policies on user_profiles
DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON user_profiles;

-- Create a security definer function to check if a user is an admin
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = user_id AND is_admin = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Disable RLS temporarily to avoid recursion when the function runs
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create new non-recursive policies

-- Allow everyone to view profiles
CREATE POLICY "Anyone can view profiles"
    ON user_profiles FOR SELECT
    TO anon, authenticated
    USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

-- Allow users to insert their own profile (for signup)
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Note: Admin operations will be handled by service role, not through RLS
