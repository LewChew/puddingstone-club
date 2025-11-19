-- Puddingstone Club Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User Profiles Table (extends auth.users with app-specific data)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Membership Requests Table
CREATE TABLE membership_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    message TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Member Availability Table
CREATE TABLE availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    member_name TEXT NOT NULL,
    available_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, available_date)
);

-- Photos Table (metadata for Supabase Storage)
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    storage_path TEXT NOT NULL UNIQUE,
    caption TEXT,
    uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_availability_user_id ON availability(user_id);
CREATE INDEX idx_availability_date ON availability(available_date);
CREATE INDEX idx_membership_requests_status ON membership_requests(status);
CREATE INDEX idx_photos_display_order ON photos(display_order);

-- Enable Row Level Security on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE membership_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- Row Level Security Policies

-- User Profiles: Users can read all profiles, but only admins can modify
CREATE POLICY "Public profiles are viewable by authenticated users"
    ON user_profiles FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can update their own profile"
    ON user_profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Admins can update any profile"
    ON user_profiles FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Membership Requests: Anyone can insert, only admins can view/update
CREATE POLICY "Anyone can submit membership requests"
    ON membership_requests FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

CREATE POLICY "Admins can view all membership requests"
    ON membership_requests FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can update membership requests"
    ON membership_requests FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can delete membership requests"
    ON membership_requests FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Availability: Authenticated users can view all, manage their own
CREATE POLICY "Authenticated users can view all availability"
    ON availability FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own availability"
    ON availability FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own availability"
    ON availability FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own availability"
    ON availability FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Photos: Authenticated users can view, only admins can manage
CREATE POLICY "Authenticated users can view photos"
    ON photos FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Admins can insert photos"
    ON photos FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can update photos"
    ON photos FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can delete photos"
    ON photos FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, name, is_admin)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        false
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create a storage bucket for photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('photos', 'photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for photos bucket
CREATE POLICY "Authenticated users can view photos"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (bucket_id = 'photos');

CREATE POLICY "Admins can upload photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'photos' AND
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can update photos"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'photos' AND
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can delete photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'photos' AND
        EXISTS (
            SELECT 1 FROM user_profiles
            WHERE id = auth.uid() AND is_admin = true
        )
    );
