-- Add approval status to photos table
-- Run this in your Supabase SQL Editor

-- Add status column to photos table
ALTER TABLE photos
ADD COLUMN status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'));

-- Create index for better performance
CREATE INDEX idx_photos_status ON photos(status);

-- Update RLS policies for photos to only show approved photos to non-admins
DROP POLICY IF EXISTS "Authenticated users can view photos" ON photos;

-- Allow everyone to view approved photos
CREATE POLICY "Anyone can view approved photos"
    ON photos FOR SELECT
    TO anon, authenticated
    USING (status = 'approved');

-- Allow admins to view all photos
CREATE POLICY "Admins can view all photos"
    ON photos FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );
