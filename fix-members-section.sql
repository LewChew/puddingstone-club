-- Fix Members Section - Allow anonymous users to view member profiles
-- Run this in your Supabase SQL Editor

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON user_profiles;

-- Create new policy that allows everyone (including anonymous users) to view profiles
CREATE POLICY "Public profiles are viewable by everyone"
    ON user_profiles FOR SELECT
    TO anon, authenticated
    USING (true);
